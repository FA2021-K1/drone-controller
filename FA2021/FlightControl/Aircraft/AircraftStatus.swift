//
//  AircraftStatus.swift
//  FA2021
//
//  Created by FA21 on 30.09.21.
//

import Foundation
import DJISDK

class AircraftStatus {
    /**
     The current location of the aircraft as a coordinate. `nil` if the location is invalid.
     
     [DJI SDK Documentation](https://developer.dji.com/api-reference/ios-api/Components/FlightController/DJIFlightController_DJIFlightControllerCurrentState.html#djiflightcontroller_djiflightcontrollercurrentstate_aircraftlocation_inline)
     */
    var currentPosition: CLLocation? {
        get {
            return AircraftStatus.getValueForParameter(label: "Location", parameter: DJIFlightControllerParamAircraftLocation, castTo: CLLocation.self)
        }
    }
    
    var batteryLevel: Int? {
        get {
            return AircraftStatus.getBatteryValueForParameter(label: "Remaining Battery Level", parameter: DJIBatteryParamChargeRemainingInPercent, castTo: Int.self)
        }
    }
    
    var gpsSignalLevel: DJIGPSSignalLevel? {
        get {
            return AircraftStatus.getValueForParameter(label: "GPS Signal Level", parameter: DJIFlightControllerParamGPSSignalStatus, castTo: DJIGPSSignalLevel.self)
        }
    }
    
    private static func getValueForParameter<T>(label: String, parameter: String, castTo: T.Type) -> T? {
        guard let key = DJIFlightControllerKey(param: parameter)
        else {
            Logger.getInstance().add(message: "Cannot retrieve \(label): Missing Controller Key")
            return nil
        }
        
        let serializedValue = DJISDKManager.keyManager()?.getValueFor(key)
        
        guard let value = serializedValue?.value as? T
        else {
            Logger.getInstance().add(message: "Cannot retrieve \(label): Value could not be serialized")
            return nil
        }
        
        return value
    }
    
    private static func getBatteryValueForParameter<T>(label: String, parameter: String, castTo: T.Type) -> T? {
        guard let key = DJIBatteryKey(param: DJIBatteryParamChargeRemainingInPercent)
        else {
            Logger.getInstance().add(message: "Cannot retrieve \(label): Missing Battery Key")
            return nil
        }
        
        let serializedValue = DJISDKManager.keyManager()?.getValueFor(key)
        
        guard let value = serializedValue?.value as? T
        else {
            Logger.getInstance().add(message: "Cannot retrieve \(label): Value could not be serialized")
            return nil
        }
        
        return value
    }
}
