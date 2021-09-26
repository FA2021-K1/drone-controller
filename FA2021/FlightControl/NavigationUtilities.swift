//
//  NavigationUtilities.swift
//  FA2021
//
//  Created by Kevin Huang on 25.09.21.
//

import Foundation
import DJISDK

struct NavigationUtilities {
    static func addMetersToCoordinates(metersLat: Double, latitude: Double,
                                metersLng: Double, longitude: Double) -> CLLocationCoordinate2D {
        
        let earth = 6378.137
        let pi =  Double.pi
        let m = (1 / ((2 * pi / 360) * earth) ) / 1000
        let lat = latitude + (metersLat * m)
        let lon = longitude + (metersLng * m) / cos(latitude * (pi / 180))
        
        return CLLocationCoordinate2DMake(lat, lon)
    }
    
    static func createDJIWaypointMission() -> DJIMutableWaypointMission {
        let mission = DJIMutableWaypointMission()
        mission.maxFlightSpeed = 15
        mission.autoFlightSpeed = 8
        mission.finishedAction = .noAction
        mission.headingMode = .auto
        mission.flightPathMode = .normal
        mission.rotateGimbalPitch = true
        mission.exitMissionOnRCSignalLost = true
        mission.gotoFirstWaypointMode = .safely
        mission.repeatTimes = 1
        
        return mission
    }
    
    static func createWaypoint(coordinates: CLLocationCoordinate2D, altitude: Float = 15) -> DJIWaypoint {
        let waypoint = DJIWaypoint(coordinate: coordinates)
        waypoint.altitude = altitude
        waypoint.heading = 0
        waypoint.actionRepeatTimes = 1
        waypoint.actionTimeoutInSeconds = 60
        waypoint.cornerRadiusInMeters = 5
        waypoint.turnMode = DJIWaypointTurnMode.clockwise
        waypoint.gimbalPitch = 0
        
        return waypoint
    }
}
