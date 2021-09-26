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
    
    init(log: Log, aircraftController: AircraftController) {
        self.aircraftController = aircraftController
        self.log = log
        super.init()
        
        setupListeners()
    }
    
    private func clearScheduleAndExecute(actions: [DJIMissionControlTimelineElement]) {
        guard let missionControl = DJISDKManager.missionControl()
        else {
            log.add(message: "Failed to schedule: Mission Control is unavailable")
            return
        }
        
        DispatchQueue.main.async {
            if missionControl.isTimelineRunning {
                self.stopMissionIfRunning()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.clearScheduleAndExecute(actions: actions)
                }
                
            } else {
                if let error = missionControl.scheduleElements(actions) {
                    self.log.add(message: "Failed to schedule: \(String(describing: error))")
                    return
                }
                
                self.log.add(message: "Starting timeline")
                missionControl.currentTimelineMarker = 0
                missionControl.startTimeline()
            }
        }
    }
    
    private func createWaypointMissionTo(coordinates: CLLocationCoordinate2D) -> DJIMissionControlTimelineElement? {
        let mission = NavigationUtilities.createDJIWaypointMission()
        let currentCoor = aircraftController.aircraftPosition!
        
        if !CLLocationCoordinate2DIsValid(coordinates) || !CLLocationCoordinate2DIsValid(currentCoor) {
            log.add(message: "Invalid coordinates")
            return nil
        }
        
        let waypoint = NavigationUtilities.createWaypoint(coordinates: coordinates, altitude: 15)
        let waypoint2 = NavigationUtilities.createWaypoint(coordinates: coordinates, altitude: 6)
        let starting = NavigationUtilities.createWaypoint(coordinates: currentCoor, altitude: 15)
        
        mission.add(starting)
        mission.add(waypoint)
        mission.add(waypoint2)
        mission.add(waypoint)
        mission.add(starting)
        
        return DJIWaypointMission(mission: mission)
    }
    
    func stopMissionIfRunning() {
        guard let missionControl = DJISDKManager.missionControl()
        else {
            log.add(message: "Failed to stop mission: Mission Control is unavailable")
            return
        }
        
        
        if missionControl.isTimelineRunning {
            self.log.add(message: "Stopping current mission and unscheduling everything...")
            missionControl.stopTimeline()
            missionControl.unscheduleEverything()
        } else {
            self.log.add(message: "No mission to stop")
        }
    }
    
    func missionIsActive() -> Bool? {
        guard let missionControl = DJISDKManager.missionControl()
        else {
            return nil
        }
        
        return missionControl.isTimelineRunning
    }
    
    func takeOff() {
        aircraftController.takeOff()
    }
    
    func land() {
        aircraftController.land()
    }
    
    func flyTo(altitude: Double) {
        
    }
    
    func flyDirection(direction: Direction, meters: Double) {
        guard let pos = aircraftController.aircraftPosition
        else {
            return
        }
        
        let coordinates : CLLocationCoordinate2D
        
        switch direction {
        case Direction.north:
            coordinates = NavigationUtilities.addMetersToCoordinates(metersLat: meters, latitude: pos.latitude, metersLng: 0, longitude: pos.longitude)
        case Direction.south:
            coordinates = NavigationUtilities.addMetersToCoordinates(metersLat: (-1) * meters, latitude: pos.latitude, metersLng: 0, longitude: pos.longitude)
        case Direction.east:
            coordinates = NavigationUtilities.addMetersToCoordinates(metersLat: 0, latitude: pos.latitude, metersLng: meters, longitude: pos.longitude)
        case Direction.west:
            coordinates = NavigationUtilities.addMetersToCoordinates(metersLat: 0, latitude: pos.latitude, metersLng: (-1) * meters, longitude: pos.longitude)
        }
        
        guard let action = createWaypointMissionTo(coordinates: coordinates)
        else {
            log.add(message: "Mission is nil. Abort.")
            return
        }
        clearScheduleAndExecute(actions: [action])
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
