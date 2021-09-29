//
//  Aircraft.swift
//  FA2021
//
//  Created by FA21 on 29.09.21.
//

import Foundation
import DJISDK

final class Aircraft: NSObject {
    override init() {
        super.init()
        let point1 = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(46.74599747777796, 11.358470588842453))
        let point2 = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(46.746195, 11.358094))
        
        point1.altitude = 10
        point2.altitude = 20
        
        let mission = DJIMutableWaypointMission()
        mission.add(point1)
        mission.add(point2)
        
        initializeMission(mission: mission)
    }
    
    func initializeMission(mission: DJIMutableWaypointMission) {
        if DJISDKManager.product() == nil {
            Logger.getInstance().add(message: "Product is nil")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                Logger.getInstance().add(message: "Restarting initializeMission")
                self.initializeMission(mission: mission)
            })
            return
        }
        
        if mission.waypointCount < 2 {
            Logger.getInstance().add(message: "Waypoint validation failed. Count: \(mission.waypointCount) < 2")
            return
        }
        
        guard let missionControl = DJISDKManager.missionControl() else {
            Logger.getInstance().add(message: "Mission Control unavailable")
            return
        }
        
        missionControl.addListener(self, toTimelineProgressWith: { (event: DJIMissionControlTimelineEvent, element: DJIMissionControlTimelineElement?, error: Error?, info: Any?) in
            
            if error != nil {
                Logger.getInstance().add(message: error!.localizedDescription)
            }
            
            // https://github.com/dji-sdk/Mobile-SDK-iOS/issues/161#issuecomment-330616112
            switch event {
            case .started:
                Logger.getInstance().add(message: "Mission started")
            case .stopped:
                Logger.getInstance().add(message: "Mission stopped")
            case .paused:
                Logger.getInstance().add(message: "Mission paused")
            case .resumed:
                Logger.getInstance().add(message: "Mission resumed")
            case .finished:
                Logger.getInstance().add(message: "Mission Scheduler finished a mission \(String(describing: element))")
            case .unknown:
                Logger.getInstance().add(message: "Mission Scheduler unknown status")
            case .progressed:
                //Logger.getInstance().add(message: "Mission Scheduler progressed status")
                break
            case .startError, .pauseError, .resumeError, .stopError:
                Logger.getInstance().add(message: "DJIMissionControl reported an error event")
            default:
                Logger.getInstance().add(message: "DJIMissionControl reported an event not included in the enum")
                break
            }
        })
        
        // let missionOperator = missionControl.waypointMissionOperator()
        
        mission.finishedAction = .noAction
        mission.autoFlightSpeed = 2
        mission.maxFlightSpeed = 4
        mission.headingMode = .auto
        mission.flightPathMode = .normal
        
        if let error = mission.checkParameters() {
            Logger.getInstance().add(message: "Waypoint Mission parameters are invalid: \(error.localizedDescription)")
            return
        }
        
        guard let aircraft = DJISDKManager.product() as? DJIAircraft else {
            return
        }
        
        aircraft.flightController?.setMaxFlightRadius(8000, withCompletion: { error in
            Logger.getInstance().add(message: "Flight Radius set: \(error?.localizedDescription ?? "No error")")
        })
        
        let takeOff = DJITakeOffAction()
        let goHome = DJIGoHomeAction()
        goHome.autoConfirmLandingEnabled = true
        
        let land = DJILandAction()
        land.autoConfirmLandingEnabled = true
        
        var elements = [DJIMissionControlTimelineElement]()
        elements.append(takeOff)
        elements.append(mission)
        elements.append(goHome)
        elements.append(land)
        
        
        missionControl.scheduleElements(elements)
        missionControl.startTimeline()
        
        missionControl.addListener(self, toTimelineProgressWith: { (event: DJIMissionControlTimelineEvent, element: DJIMissionControlTimelineElement?, error: Error?, info: Any?) in
            
            if error != nil {
                Logger.getInstance().add(message: error!.localizedDescription)
            }
            
            if element == nil && event == .finished {
                Logger.getInstance().add(message: "FINISHED")
                missionControl.stopTimeline()
                missionControl.unscheduleEverything()
                missionControl.scheduleElements(elements)
                missionControl.startTimeline()
            }
        })
    }
}

