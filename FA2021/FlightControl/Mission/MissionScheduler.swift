//
//  MissionScheduler.swift
//  FA2021
//
//  Created by Kevin Huang on 20.09.21.
//

import Foundation
import DJISDK

class MissionScheduler: NSObject, ObservableObject {
    private(set) var aircraftController: AircraftController
    private var log: Log
    
    var missionActive: Bool {
        get {
            guard let missionControl = DJISDKManager.missionControl()
            else {
                log.add(message: "Warning: Mission Control is unavailable! Could not safely determine mission state!")
                return false
            }
            
            return missionControl.isTimelineRunning
        }
    }
    
    var aircraftState: DroneState {
        get {
            return aircraftController.state
        }
    }
    
    init(log: Log, aircraftController: AircraftController) {
        self.aircraftController = aircraftController
        self.log = log
        super.init()
        
        setupListeners()
    }
    
    func clearScheduleAndExecute(mission: DJIWaypointMission) {
        clearScheduleAndExecute(actions: [mission])
    }
    
    func clearScheduleAndExecute(actions: [DJIMissionControlTimelineElement]) {
        log.add(message: "clear schedule and execute")
        actions.forEach { action in
            log.add(message: "Action: \(action.debugDescription ?? "[No debug description]")")
        }
        guard let missionControl = DJISDKManager.missionControl()
        else {
            log.add(message: "Failed to schedule: Mission Control is unavailable")
            return
        }
        
        DispatchQueue.main.async {
            if missionControl.isTimelineRunning {
                self.log.add(message: "Timeline is already running, retrying in 1 second")
                self.stopAndClearMissionIfRunning()
                self.retryAfter(seconds: 1) {
                    self.clearScheduleAndExecute(actions: actions)
                }
                
            } else {
                if let error = missionControl.scheduleElements(actions) {
                    self.log.add(message: "Failed to schedule: \(String(describing: error))")
                    self.retryAfter(seconds: 1, task: {
                        self.clearScheduleAndExecute(actions: actions)
                    })
                    return
                }
                
                self.log.add(message: "Starting timeline")
                missionControl.currentTimelineMarker = 0
                missionControl.startTimeline()
            }
        }
    }
    
    private func createWaypointMissionTo(coordinates: CLLocationCoordinate2D) -> DJIWaypointMission? {
        let mission = NavigationUtilities.createDJIWaypointMission()

        if !CLLocationCoordinate2DIsValid(coordinates) {
            log.add(message: "Invalid coordinates")
            return nil
        }
        
        let waypoint = NavigationUtilities.createWaypoint(coordinates: coordinates, altitude: 15)
        mission.add(waypoint)
        
        return DJIWaypointMission(mission: mission)
    }
    
    private func retryAfter(seconds: Double, task: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: task)
    }
    
    func stopAndClearMissionIfRunning() {
        log.add(message: "Stop and clear mission if running")
        guard let missionControl = DJISDKManager.missionControl()
        else {
            log.add(message: "Failed to stop mission: Mission Control is unavailable")
            return
        }
        
        if missionActive {
            self.log.add(message: "Stopping current mission and unscheduling everything...")
            missionControl.stopTimeline()
            missionControl.unscheduleEverything()
        } else {
            self.log.add(message: "No mission to stop")
        }
    }
    
    func takeOff(altitude: Float) {
        log.add(message: "Ordered takeoff")
        aircraftController.takeOff {
            self.log.add(message: "Mission Control reported Take off")
            self.retryAfter(seconds: 4, task: {
                self.flyTo(altitude: altitude)
            })
        }
    }
    
    func land() {
        log.add(message: "Ordered land")
        aircraftController.land()
    }
    
    func flyTo(altitude: Float) {
        self.log.add(message: "Flying to altitude \(altitude)")
        let mission = NavigationUtilities.createDJIWaypointMission()
        let currentPosition = aircraftController.aircraftPosition!
        let currentAltitude = aircraftController.aircraftAltitude!
        self.log.add(message: "Current position: \(currentPosition), current altitude: \(currentAltitude)")
        
        if !CLLocationCoordinate2DIsValid(currentPosition) {
            log.add(message: "Invalid coordinates")
            return
        }
        
        let waypointStart = NavigationUtilities.createWaypoint(coordinates: currentPosition, altitude: Float(currentAltitude))
        let waypointDestination = NavigationUtilities.createWaypoint(coordinates: currentPosition, altitude: altitude)
        
        mission.add(waypointStart)
        mission.add(waypointDestination)
        clearScheduleAndExecute(mission: mission)
    }
    
    func flyTo(direction: Direction, meters: Double) {
        guard let position = aircraftController.aircraftPosition
        else {
            return
        }
        
        let coordinates : CLLocationCoordinate2D
        
        switch direction {
        case .north:
            coordinates = NavigationUtilities.addMetersToCoordinates(metersLat: meters, latitude: position.latitude, metersLng: 0, longitude: position.longitude)
        case .south:
            coordinates = NavigationUtilities.addMetersToCoordinates(metersLat: (-1) * meters, latitude: position.latitude, metersLng: 0, longitude: position.longitude)
        case .east:
            coordinates = NavigationUtilities.addMetersToCoordinates(metersLat: 0, latitude: position.latitude, metersLng: meters, longitude: position.longitude)
        case .west:
            coordinates = NavigationUtilities.addMetersToCoordinates(metersLat: 0, latitude: position.latitude, metersLng: (-1) * meters, longitude: position.longitude)
        }
        
        guard let mission = createWaypointMissionTo(coordinates: coordinates)
        else {
            log.add(message: "Mission is nil. Abort.")
            return
        }
        clearScheduleAndExecute(mission: mission)
    }
    
}

extension MissionScheduler {
    private func setupListeners() {
        DJISDKManager.missionControl()?.addListener(self, toTimelineProgressWith: { (event: DJIMissionControlTimelineEvent, element: DJIMissionControlTimelineElement?, error: Error?, info: Any?) in
            
            if error != nil {
                self.log.add(message: error!.localizedDescription)
            }
            
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
                self.log.add(message: "DJIMissionControl reported Event \(event.self)")
                break
            }
        })
    }
    
    private func didStart() {
        self.log.add(message: "Mission Scheduler started mission")
    }
    
    private func didStop() {
        self.log.add(message: "Mission Scheduler is ready")
    }
    
    private func didPause() {
        self.log.add(message: "Mission Scheduler paused mission")
    }
    
    private func didResume() {
        self.log.add(message: "Mission Scheduler resumed mission")
    }
}

enum Direction: String {
    case north
    case south
    case east
    case west
}
