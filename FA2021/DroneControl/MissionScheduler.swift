//
//  MissionScheduler.swift
//  FA2021
//
//  Created by Kevin Huang on 20.09.21.
//

import Foundation
import DJISDK
import Combine

class MissionScheduler: NSObject, ObservableObject {
    
    private var missionControl: DJIMissionControl?
    private var product: DJIBaseProduct?
    private var missionSchedulerState: MissionSchedulerState
    private var logCancellable: AnyCancellable?
    
    @Published
    var log = Log()
    
    override init() {
        self.missionSchedulerState = .initializing
        super.init()
        self.logCancellable = log.$logEntries.sink(receiveValue: {_ in
            self.objectWillChange.send()
        })
        
        registerSDK()
        connectProductAndAnnounce()
        
        missionControl = DJISDKManager.missionControl()
        setupListeners()
    }
    
    func connectProductAndAnnounce() {
        self.log.add(message: "Connecting to product")
        DJISDKManager.startConnectionToProduct()
        
        self.log.add(message: "Creating connected key")
        guard let connectedKey = DJIProductKey(param: DJIParamConnection) else {
            self.log.add(message: "Error creating the connectedKey")
            return;
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            DJISDKManager.keyManager()?.startListeningForChanges(on: connectedKey, withListener: self, andUpdate: { (oldValue: DJIKeyedValue?, newValue : DJIKeyedValue?) in
                if newValue != nil {
                    if newValue!.boolValue {
                        // At this point, a product is connected so we can show it.
                        
                        // UI goes on MT.
                        DispatchQueue.main.async {
                            self.productConnected()
                        }
                    }
                }
            })
            DJISDKManager.keyManager()?.getValueFor(connectedKey, withCompletion: { (value:DJIKeyedValue?, error:Error?) in
                if let unwrappedValue = value {
                    if unwrappedValue.boolValue {
                        // UI goes on MT.
                        DispatchQueue.main.async {
                            self.productConnected()
                        }
                    }
                }
            })
        }
    }
    
    // MARK : Product connection UI changes
    
    func productConnected() {
        guard let newProduct = DJISDKManager.product() else {
            self.log.add(message: "Product is connected but DJISDKManager.product is nil -> something is wrong")
            self.connectProductAndAnnounce()
            return
        }
        //Updates the product's model
        self.log.add(message: "Model: \((newProduct.model)!)")
        
        //Updates the product's connection status
        self.log.add(message: "Status: Product Connected")
        
        product = newProduct
        missionSchedulerState = .ready
    }
    
    private func registerSDK() {
        log.add(message: "Registering SDK")
        let appKey = Bundle.main.object(forInfoDictionaryKey: SDK_APP_KEY_INFO_PLIST_KEY) as? String
        
        guard appKey != nil && appKey!.isEmpty == false else {
            log.add(message: "Please enter your app key in the info.plist")
            return
        }
        DJISDKManager.registerApp(with: self)
    }
    
    func clearScheduleAndExecute(actions: [DJIMissionControlTimelineElement]) {
        switch self.missionSchedulerState {
        case .initializing, .initialized:
            log.add(message: "Mission Scheduler is not ready, abort. Current state: \(String(describing: missionSchedulerState))")
            return
        case .starting, .started, .pausing, .paused, .stopping:
            DispatchQueue.main.async {
                self.log.add(message: "Stopping mission and unscheduling everything...")
                self.missionSchedulerState = .stopping
                self.missionControl?.stopTimeline()
                self.missionControl?.unscheduleEverything()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.clearScheduleAndExecute(actions: actions)
                }
            }
        case .ready:
            DispatchQueue.main.async {
                if let error = self.missionControl?.scheduleElements(actions) {
                    self.log.add(message: "error scheduling mission elments: \(String(describing: error))")
                    return
                }
                
                self.log.add(message: "Starting timeline")
                self.missionSchedulerState = .starting
                self.missionControl?.currentTimelineMarker = 0
                self.missionControl?.startTimeline()
            }
        }
    }
    
    func takeOff() {
        log.add(message: "Taking off!")
        clearScheduleAndExecute(actions: [DJITakeOffAction()])
    }
    
    func land() {
        log.add(message: "Landing")
        clearScheduleAndExecute(actions: [DJIGoHomeAction()])
    }
    
    func addMetersToCoordinates(metersLat: Double, latitude: Double,
                                metersLng: Double, longitude: Double) -> CLLocationCoordinate2D {
        
        let earth = 6378.137
        let pi =  Double.pi
        let m = (1 / ((2 * pi / 360) * earth) ) / 1000
        let lat = latitude + (metersLat * m)
        let lon = longitude + (metersLng * m) / cos(latitude * (pi / 180))
        
        return CLLocationCoordinate2DMake(lat, lon)
    }
    
    func getCurrentPos() -> CLLocationCoordinate2D? {
        guard let key = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation)
        else {
            log.add(message: "Missing controller key")
            return nil;
        }
        let value = DJISDKManager.keyManager()?.getValueFor(key)
        
        let loc = value?.value as! CLLocation
        return loc.coordinate
    }
    
    func flyDirection(direction: Direction, meters: Double) {
        guard let pos = getCurrentPos()
        else {
            log.add(message: "Cannot retrieve current location")
            return
        }
        
        let coordinates : CLLocationCoordinate2D
        
        switch direction {
            case Direction.north:
                coordinates = addMetersToCoordinates(metersLat: meters, latitude: pos.latitude, metersLng: 0, longitude: pos.longitude)
            case Direction.south:
                coordinates = addMetersToCoordinates(metersLat: (-1) * meters, latitude: pos.latitude, metersLng: 0, longitude: pos.longitude)
            case Direction.east:
                coordinates = addMetersToCoordinates(metersLat: 0, latitude: pos.latitude, metersLng: meters, longitude: pos.longitude)
            case Direction.west:
                coordinates = addMetersToCoordinates(metersLat: 0, latitude: pos.latitude, metersLng: (-1) * meters, longitude: pos.longitude)
        }
        
        guard let action = createWaypointMissionTo(coordinates: coordinates)
        else {
            log.add(message: "Mission is nil. Abort.")
            return
        }
        clearScheduleAndExecute(actions: [action])
    }
    
    func createWaypointMissionTo(coordinates: CLLocationCoordinate2D) -> DJIMissionControlTimelineElement? {
        let mission = DJIMutableWaypointMission()
        mission.maxFlightSpeed = 15
        mission.autoFlightSpeed = 8
        mission.finishedAction = .noAction
        mission.headingMode = .auto
        mission.flightPathMode = .normal
        mission.rotateGimbalPitch = true
        mission.exitMissionOnRCSignalLost = true
        mission.gotoFirstWaypointMode = .pointToPoint
        mission.repeatTimes = 1
        
        guard let key = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation)
        else {
            log.add(message: "Missing controller key")
            return nil
        }
        let value = DJISDKManager.keyManager()?.getValueFor(key)
        
        let currentLoc = value?.value as! CLLocation
        let currentCoor = currentLoc.coordinate
        
        if !CLLocationCoordinate2DIsValid(coordinates) || !CLLocationCoordinate2DIsValid(currentCoor) {
            log.add(message: "Invalid coordinates")
            return nil
        }
        
        let waypoint = DJIWaypoint(coordinate: coordinates)
        waypoint.altitude = 25
        waypoint.heading = 0
        waypoint.actionRepeatTimes = 1
        waypoint.actionTimeoutInSeconds = 60
        waypoint.cornerRadiusInMeters = 5
        waypoint.turnMode = DJIWaypointTurnMode.clockwise
        waypoint.gimbalPitch = 0
        
        mission.add(waypoint)
        
        return DJIWaypointMission(mission: mission)
    }
    
    private func createDemoMission() -> DJIMissionControlTimelineElement? {
        let startingCoordinates = CLLocationCoordinate2DMake(46.746102, 11.359648)
        let endingCoordinates = CLLocationCoordinate2DMake(46.776097, 11.359169)
        
        let mission = DJIMutableWaypointMission()
        mission.maxFlightSpeed = 15
        mission.autoFlightSpeed = 8
        mission.finishedAction = .noAction
        mission.headingMode = .auto
        mission.flightPathMode = .normal
        mission.rotateGimbalPitch = true
        mission.exitMissionOnRCSignalLost = true
        mission.gotoFirstWaypointMode = .pointToPoint
        mission.repeatTimes = 1
        
        guard let droneLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation) else {
            return nil
        }
        
        guard let droneLocationValue = DJISDKManager.keyManager()?.getValueFor(droneLocationKey) else {
            return nil
        }
        
        let droneLocation = droneLocationValue.value as! CLLocation
        let droneCoordinates = droneLocation.coordinate
        
        if !CLLocationCoordinate2DIsValid(droneCoordinates) {
            return nil
        }
        
        let waypoint1 = DJIWaypoint(coordinate: startingCoordinates)
        waypoint1.altitude = 25
        waypoint1.heading = 0
        waypoint1.actionRepeatTimes = 1
        waypoint1.actionTimeoutInSeconds = 60
        waypoint1.cornerRadiusInMeters = 5
        waypoint1.turnMode = DJIWaypointTurnMode.clockwise
        waypoint1.gimbalPitch = 0
        
        let waypoint2 = DJIWaypoint(coordinate: endingCoordinates)
        waypoint2.altitude = 26
        waypoint2.heading = 0
        waypoint2.actionRepeatTimes = 1
        waypoint2.actionTimeoutInSeconds = 60
        waypoint2.cornerRadiusInMeters = 5
        waypoint2.turnMode = DJIWaypointTurnMode.clockwise
        waypoint2.gimbalPitch = 0
        
        mission.add(waypoint1)
        mission.add(waypoint2)
        
        return DJIWaypointMission(mission: mission)
    }
    
    // only for demo mission
    func executeMission() {
        log.add(message: "Executing Mission")
        guard let mission = createDemoMission()
        else {
            log.add(message: "Mission could not be created. Abort.")
            return
        }
        clearScheduleAndExecute(actions: [mission])
    }
}

extension MissionScheduler: DJISDKManagerDelegate {
    func appRegisteredWithError(_ error: Error?) {
        if (error != nil) {
            log.add(message: "Registering SDK failed")
        } else {
            log.add(message: "Registering SDK successful")
            missionSchedulerState = .initialized
        }
    }
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        
    }
}

extension MissionScheduler {
    func setupListeners() {
        missionControl?.addListener(self, toTimelineProgressWith: { (event: DJIMissionControlTimelineEvent, element: DJIMissionControlTimelineElement?, error: Error?, info: Any?) in
            
            self.log.add(message: error?.localizedDescription ?? "Mission Control Listener reported Element nil")
            
            // https://github.com/dji-sdk/Mobile-SDK-iOS/issues/161#issuecomment-330616112
            switch event {
            case .started:
                self.didStart()
            case .stopped:
                self.didStop()
            case .paused:
                self.didPause()
            case .resumed:
                self.didResume()
            default:
                self.log.add(message: "This should not happen! \(event)")
                break
            }
        })
    }
    
    func didStart() {
        self.log.add(message: "Mission Scheduler started mission")
        missionSchedulerState = .started
    }
    
    func didStop() {
        self.log.add(message: "Mission Scheduler is ready")
        missionSchedulerState = .ready
    }
    
    func didPause() {
        self.log.add(message: "Mission Scheduler paused mission")
        missionSchedulerState = .paused
    }
    
    func didResume() {
        self.log.add(message: "Mission Scheduler resumed mission")
        missionSchedulerState = .started
    }
}

enum MissionSchedulerState: String {
    case initializing
    case initialized
    case ready
    case starting
    case started
    case pausing
    case paused
    case stopping
}

enum Direction: String {
    case north
    case south
    case east
    case west
}
