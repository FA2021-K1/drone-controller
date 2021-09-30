//
//  Aircraft.swift
//  FA2021
//
//  Created by FA21 on 29.09.21.
//

import Foundation
import DJISDK

final class Aircraft: NSObject {
    
    var connectedAircraft: DJIAircraft? {
        get {
            guard let connectedAircraft = DJISDKManager.product() as? DJIAircraft else {
                Logger.getInstance().add(message: "DJI Aircraft is not available")
                return nil
            }
            return connectedAircraft
        }
    }
    
    lazy var status = AircraftStatus()
    
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
    
    func isFlying() -> Bool? {
        guard let key = DJIFlightControllerKey(param: DJIFlightControllerParamIsFlying)
        else {
            Logger.getInstance().add(message: "Cannot retrieve current flying status: Missing Controller Key")
            return nil
        }
        
        let value = DJISDKManager.keyManager()?.getValueFor(key)
        guard let isFlying = value?.value as? Bool else {
            Logger.getInstance().add(message: "Cannot retrieve current flying status")
            return nil
        }
        
        return isFlying
    }
    
    init(onReady: @escaping () -> Void) {
        super.init()
        
        let _ = AircraftConnection() {
            guard let missionControl = DJISDKManager.missionControl() else {
                Logger.getInstance().add(message: "Mission Control unavailable")
                return
            }
            self.setupTimelineListeners(for: missionControl)
            onReady()
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
        
        if !gpsSignalIsStrongEnough() {
            Logger.getInstance().add(message: "Warning: Please check that GPS Signal Level is strong enough!")
        }
        
        // Before setting up a new mission, any existing mission must be stopped and cleared.
        stopAndClearMission()
        
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
            Logger.getInstance().add(message: "Flight Radius set to 8 km: \(error?.localizedDescription ?? "No error")")
        })
        
        aircraft.flightController?.setGoHomeHeightInMeters(20, withCompletion: { error in
            Logger.getInstance().add(message: "Go Home Height in Meters set to 20 m: \(error?.localizedDescription ?? "No error")")
        })
        
        let takeOff = DJITakeOffAction()
        let goHome = DJIGoHomeAction()
        goHome.autoConfirmLandingEnabled = true
        
        let land = DJILandAction()
        land.autoConfirmLandingEnabled = true
        
        var elements = [DJIMissionControlTimelineElement]()
        
        if (self.isFlying() ?? false){
            elements.append(takeOff)
        }
        
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
    }
    
    /**
     Stops timeline / DJI Mission if it is running and then unschedules all actions.
     */
    func stopAndClearMission() {
        // if we don't check beforehand, there will be an error (timelines not running cannot be stopped)
        if(DJISDKManager.missionControl()?.isTimelineRunning ?? true){
            DJISDKManager.missionControl()?.stopTimeline()
        }
        DJISDKManager.missionControl()?.unscheduleEverything()
    }
    
    private func gpsSignalIsStrongEnough() -> Bool {
        switch status.gpsSignalLevel {
        case .level2, .level3, .level4, .level5:
            return true
        case .levelNone, .level0, .level1, .none, .some(_):
            return false
        }
    }
    
    /**
     Set up listeners on the timeline of a DJI Mission.
     */
    private func setupTimelineListeners(for missionControl: DJIMissionControl) {
        missionControl.addListener(self, toTimelineProgressWith: { (event: DJIMissionControlTimelineEvent, element: DJIMissionControlTimelineElement?, error: Error?, info: Any?) in
            
            // A general error logger for events.
            if error != nil {
                Logger.getInstance().add(message: error!.localizedDescription)
            }
            
            // https://github.com/dji-sdk/Mobile-SDK-iOS/issues/161#issuecomment-330616112 :
            // When element is nil, then the event refers to the whole timeline.
            // That is, iff element is not nil, the event is specific to the element.
            // Here in the following, we are setting up handlers specific to the start, stop, ... events of a specific timeline event.
            if element == nil {
                return
            }
            
            switch event {
            case .started:
                Logger.getInstance().add(message: "\(element?.debugDescription ?? "Timeline event:") started")
            case .stopped:
                Logger.getInstance().add(message: "\(element?.debugDescription ?? "Timeline event:") stopped")
            case .paused:
                Logger.getInstance().add(message: "\(element?.debugDescription ?? "Timeline event:") paused")
            case .resumed:
                Logger.getInstance().add(message: "\(element?.debugDescription ?? "Timeline event:") resumed")
            case .finished:
                Logger.getInstance().add(message: "\(element?.debugDescription ?? "Timeline event:") finished")
            case .unknown:
                Logger.getInstance().add(message: "\(element?.debugDescription ?? "Timeline event:") unknown status")
            case .progressed:
                //Logger.getInstance().add(message: "\(element?.debugDescription ?? "Timeline event:") progressed")
                break
            case .startError, .pauseError, .resumeError, .stopError:
                Logger.getInstance().add(message: "DJIMissionControl reported an error event")
            default:
                Logger.getInstance().add(message: "DJIMissionControl reported an event not included in the listener handlers")
                break
            }
        })
        
        missionControl.addListener(self, toTimelineProgressWith: { (event: DJIMissionControlTimelineEvent, element: DJIMissionControlTimelineElement?, error: Error?, info: Any?) in
            // See comment with the Github Link above
            // Since the element is nil, the events reported here are referring to the whole timeline
            if element == nil && event == .finished {
                Logger.getInstance().add(message: "FINISHED MISSION")
                self.stopAndClearMission()
            }
        })
    }
}

