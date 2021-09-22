//
//  MissionScheduler.swift
//  FA2021
//
//  Created by Kevin Huang on 20.09.21.
//

import Foundation
import DJISDK

class MissionScheduler: NSObject {
    
    private var missionControl: DJIMissionControl?
    private var registered = false
    
    override init() {
        super.init()
        registerSDK()
    }
    
    private func registerSDK() {
        let appKey = Bundle.main.object(forInfoDictionaryKey: SDK_APP_KEY_INFO_PLIST_KEY) as? String
        
        guard appKey != nil && appKey!.isEmpty == false else {
            print("Please enter your app key in the info.plist")
            return
        }
        DJISDKManager.registerApp(with: self)
        registered = true
    }
    
    func clearScheduleAndExecute(actions: [DJIMissionControlTimelineElement]) {
        if !registered {
            print("Warning, SDK is not registered!")
            return
        }
        
        missionControl?.unscheduleEverything()
        missionControl?.scheduleElements(actions)
        missionControl?.startTimeline()
    }
    
    func takeOff() {
        clearScheduleAndExecute(actions: [DJITakeOffAction()])
    }
    
    func land() {
        clearScheduleAndExecute(actions: [DJILandAction()])
    }
    
    func executeMission() {
        guard let mission = createDemoMission()
        else {
            print("Mission could not be created")
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
