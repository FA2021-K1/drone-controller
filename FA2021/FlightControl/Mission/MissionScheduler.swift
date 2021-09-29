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
    
    var missionActive: Bool {
        get {
            guard let missionControl = DJISDKManager.missionControl()
            else {
                Logger.getInstance().add(message: "Warning: Mission Control is unavailable! Could not safely determine mission state!")
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
    
    init(aircraftController: AircraftController) {
        self.aircraftController = aircraftController
        super.init()
        
        setupListeners()
    }
    
    func clearScheduleAndExecute(mission: DJIWaypointMission) {
        clearScheduleAndExecute(actions: [mission])
    }
    
    func clearScheduleAndExecute(actions: [DJIMissionControlTimelineElement]) {
        guard let missionControl = DJISDKManager.missionControl()
        else {
            Logger.getInstance().add(message: "Failed to schedule: Mission Control is unavailable")
            return
        }
        
        DispatchQueue.main.async {
            if missionControl.isTimelineRunning {
                self.stopAndClearMissionIfRunning()
                self.retryAfter(seconds: 1) {
                    self.clearScheduleAndExecute(actions: actions)
                }
                
            } else {
                if let error = missionControl.scheduleElements(actions) {
                    Logger.getInstance().add(message: "Failed to schedule: \(error.localizedDescription)")
                    self.retryAfter(seconds: 1, task: {
                        self.clearScheduleAndExecute(actions: actions)
                    })
                    return
                }
                
                Logger.getInstance().add(message: "Starting timeline")
                missionControl.currentTimelineMarker = 0
                missionControl.startTimeline()
            }
        }
    }
    
    private func createWaypointMissionTo(coordinates: CLLocationCoordinate2D) -> DJIWaypointMission? {
        let mission = NavigationUtilities.createDJIWaypointMission()

        if !CLLocationCoordinate2DIsValid(coordinates) {
            Logger.getInstance().add(message: "Invalid coordinates")
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
        guard let missionControl = DJISDKManager.missionControl()
        else {
            Logger.getInstance().add(message: "Failed to stop mission: Mission Control is unavailable")
            return
        }
        
        if missionActive {
            Logger.getInstance().add(message: "Stopping current mission and unscheduling everything...")
            missionControl.stopTimeline()
            missionControl.unscheduleEverything()
        } else {
            Logger.getInstance().add(message: "No mission to stop")
        }
    }
    
    func takeOff(altitude: Float) {
        aircraftController.takeOff {
            Logger.getInstance().add(message: "Mission Control reported Take off")
            self.retryAfter(seconds: 4, task: {
                self.flyTo(altitude: altitude)
            })
        }
    }
    
    func land() {
        aircraftController.land()
    }
    
    func flyTo(altitude: Float) {
        Logger.getInstance().add(message: "Flying to altitude \(altitude)")
        let mission = NavigationUtilities.createDJIWaypointMission()
        let currentPosition = aircraftController.aircraftPosition!
        let currentAltitude = aircraftController.aircraftAltitude!
        
        if !CLLocationCoordinate2DIsValid(currentPosition) {
            Logger.getInstance().add(message: "Invalid coordinates")
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
            Logger.getInstance().add(message: "Mission is nil. Abort.")
            return
        }
        clearScheduleAndExecute(mission: mission)
    }
    
}

extension MissionScheduler {
    private func setupListeners() {
        DJISDKManager.missionControl()?.addListener(self, toTimelineProgressWith: { (event: DJIMissionControlTimelineEvent, element: DJIMissionControlTimelineElement?, error: Error?, info: Any?) in
            
            if error != nil {
                Logger.getInstance().add(message: error!.localizedDescription)
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
                Logger.getInstance().add(message: "DJIMissionControl reported Event \(event.self)")
                break
            }
        })
    }
    
    private func didStart() {
        Logger.getInstance().add(message: "Mission Scheduler started mission")
    }
    
    private func didStop() {
        Logger.getInstance().add(message: "Mission Scheduler is ready")
    }
    
    private func didPause() {
        Logger.getInstance().add(message: "Mission Scheduler paused mission")
    }
    
    private func didResume() {
        Logger.getInstance().add(message: "Mission Scheduler resumed mission")
    }
}

enum Direction: String {
    case north
    case south
    case east
    case west
}
