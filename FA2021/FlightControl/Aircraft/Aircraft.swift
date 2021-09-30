//
//  Aircraft.swift
//  FA2021
//
//  Created by FA21 on 29.09.21.
//

import Foundation
import DJISDK

final class Aircraft: NSObject {
    /**
     The current location of the aircraft as a coordinate. `nil` if the location is invalid.
     
     [DJI SDK Documentation](https://developer.dji.com/api-reference/ios-api/Components/FlightController/DJIFlightController_DJIFlightControllerCurrentState.html#djiflightcontroller_djiflightcontrollercurrentstate_aircraftlocation_inline)
     */
    
    func getCurrentPosition() -> CLLocation? {
        guard let key = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation)
        else {
            Logger.getInstance().add(message: "Cannot retrieve current location: Missing Controller Key")
            return nil
        }
        
        let value = DJISDKManager.keyManager()?.getValueFor(key)
        guard let location = value?.value as? CLLocation else {
            Logger.getInstance().add(message: "Cannot retrieve current location")
            return nil
        }
        
        return location
    }

    
    override init() {
        super.init()
        
        let _ = AircraftConnection() {
            guard let missionControl = DJISDKManager.missionControl() else {
                Logger.getInstance().add(message: "Mission Control unavailable")
                return
            }
            self.setupTimelineListeners(for: missionControl)
        }
    }
    
    func initializeMission(mission: DJIMutableWaypointMission) {
        if DJISDKManager.product() == nil {
            Logger.getInstance().add(message: "Could not initialize mission: Product is nil")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                Logger.getInstance().add(message: "Restarting initializeMission()")
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
        
        guard let currentPosition = self.getCurrentPosition() else {
            Logger.getInstance().add(message: "Unable to get drone location.")
            return
        }
        
        aircraft.flightController?.setHomeLocation(currentPosition, withCompletion: { error in
            Logger.getInstance().add(message: "Home position set: \(error?.localizedDescription ?? "No error")")
        })
        
        missionControl.scheduleElements(elements)
        missionControl.startTimeline()
        
        missionControl.addListener(self, toTimelineProgressWith: { (event: DJIMissionControlTimelineEvent, element: DJIMissionControlTimelineElement?, error: Error?, info: Any?) in
            if element == nil && event == .finished {
                Logger.getInstance().add(message: "FINISHED")
                missionControl.stopTimeline()
                missionControl.unscheduleEverything()
                missionControl.scheduleElements(elements)
                missionControl.startTimeline()
            }
        })
    }
    
    private func setupTimelineListeners(for missionControl: DJIMissionControl) {
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
    }
}

