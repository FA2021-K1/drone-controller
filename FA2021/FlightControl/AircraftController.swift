//
//  DroneController.swift
//  FA2021
//
//  Created by Kevin Huang on 25.09.21.
//

import Foundation
import DJISDK
import Combine

class DroneController {
    private var log: Log
    private var aircraft: DJIAircraft?
    private var droneConnection: DroneConnectionManager
    private var state: DroneState
    
    private var droneConnectionCancellable: AnyCancellable?
    
    init(log: Log, droneConnection: DroneConnectionManager) {
        self.log = log
        self.state = .onGround
        self.droneConnection = droneConnection
    }
    
    func getCurrentDronePosition() -> CLLocationCoordinate2D? {
        guard let key = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation)
        else {
            log.add(message: "Missing controller key")
            return nil;
        }
        let value = DJISDKManager.keyManager()?.getValueFor(key)
        
        guard let location = value?.value as? CLLocation else {
            return nil
        }
        return location.coordinate
    }
    
    func takeOff() {
        log.add(message: "Taking off!")
        droneConnection.aircraft?.flightController?.startTakeoff {_ in
            self.log.add(message: "Takeoff completed")
            self.state = .inAir
        }
    }
    
    func land() {
        log.add(message: "Landing")
        droneConnection.aircraft?.flightController?.startLanding {_ in
            self.log.add(message: "Landing completed")
            self.state = .onGround
        }
    }
}

enum DroneState {
    case inAir
    case onGround
}
