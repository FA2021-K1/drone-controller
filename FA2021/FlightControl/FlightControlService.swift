//
//  FlightControlService.swift
//  FA2021
//
//  Created by Kevin Huang on 25.09.21.
//

import Foundation
import Combine

class FlightControlService {
    private var missionScheduler: MissionScheduler
    private var connectionManager: DroneConnectionManager
    private var aircraftController: AircraftController
    private(set) var taskContext: TaskContext
    
    init() {
        self.connectionManager = DroneConnectionManager()
        self.aircraftController = AircraftController(droneConnection: connectionManager)
        self.missionScheduler = MissionScheduler(aircraftController: aircraftController)
        self.taskContext = TaskContext(aircraftController: aircraftController)
        Logger.getInstance().add(message: "FlightControlService initialized")
    }
    
    func takeOff() {
        self.aircraftController.takeOff {
            Logger.getInstance().add(message: "FlightControlService reported takeoff")
        }
    }
    
    func land() {
        self.aircraftController.land()
    }
    
    func flyNorth(meters: Double) {
        self.missionScheduler.flyTo(direction: .north, meters: meters)
    }
    
    func sampleTask() {
        self.taskContext.runSampleTask()
    }
}
