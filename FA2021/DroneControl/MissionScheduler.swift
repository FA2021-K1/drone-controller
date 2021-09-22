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
    private var registered = false
    private var logCancellable: AnyCancellable?
    
    @Published
    var log = Log()
    
    override init() {
        super.init()
        self.logCancellable = log.$logEntries.sink(receiveValue: {_ in
            self.objectWillChange.send()
        })
        registerSDK()
        DJISDKManager.startConnectionToProduct()
        test()
    }
    
    func test() {
        log.add(message: "Creating connected key")
        guard let connectedKey = DJIProductKey(param: DJIParamConnection) else {
            log.add(message: "Error creating the connectedKey")
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
            return;
        }

        //Updates the product's model
        self.log.add(message: "Model: \((newProduct.model)!)")
        
        //Updates the product's connection status
        self.log.add(message: "Status: Product Connected")
        
        product = newProduct
    }
    
    private func registerSDK() {
        log.add(message: "Registering SDK")
        let appKey = Bundle.main.object(forInfoDictionaryKey: SDK_APP_KEY_INFO_PLIST_KEY) as? String
        
        guard appKey != nil && appKey!.isEmpty == false else {
            log.add(message: "Please enter your app key in the info.plist")
            return
        }
        DJISDKManager.registerApp(with: self)
        registered = true
    }
    
    func clearScheduleAndExecute(actions: [DJIMissionControlTimelineElement]) {
        if !registered {
            log.add(message: "Warning, SDK is not registered! Abort.")
            return
        }
        
        log.add(message: "Unscheduling everything and adding to mission...")
        
        missionControl?.stopTimeline()
        missionControl?.unscheduleEverything()
    
        
        if let error = missionControl?.scheduleElements(actions) {
            log.add(message: "error scheduling mission elments: \(String(describing: error))")
            return
        }
        
        log.add(message: "Starting timeline")
        missionControl?.currentTimelineMarker = 0
        missionControl?.startTimeline()
    }
    
    func takeOff() {
        log.add(message: "Taking off!")
        
        clearScheduleAndExecute(actions: [DJITakeOffAction()])
    }
    
    func land() {
        log.add(message: "Landing")
        clearScheduleAndExecute(actions: [DJILandAction()])
    }
    
    func executeMission() {
        log.add(message: "Executing Mission")
        guard let mission = createDemoMission()
        else {
            log.add(message: "Mission could not be created. Abort.")
            return
        }
        clearScheduleAndExecute(actions: [mission])
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
}

extension MissionScheduler: DJISDKManagerDelegate {
    func appRegisteredWithError(_ error: Error?) {
        
    }
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        
    }
}
