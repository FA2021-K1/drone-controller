//
//  FlightControlService.swift
//  FA2021
//
//  Created by Kevin Huang on 25.09.21.
//

import Foundation
import Combine

class FlightControlService {
    private var log: Log
    private var missionScheduler: MissionScheduler
    private var connectionManager: DroneConnectionManager
    private var aircraftController: AircraftController
    private var taskContext: TaskContext
    
    init(log: Log) {
        self.log = log
        self.connectionManager = DroneConnectionManager(log: log)
        self.aircraftController = AircraftController(log: log, droneConnection: connectionManager)
        self.missionScheduler = MissionScheduler(log: log, aircraftController: aircraftController)
        self.taskContext = TaskContext(log: log, aircraftController: aircraftController)
        log.add(message: "FlightControlService initialized")
    }
    
    func takeOff() {
        self.aircraftController.takeOff()
    }
    
    func land() {
        self.aircraftController.land()
    }
    
    func flyNorth(meters: Double) {
        self.missionScheduler.flyDirection(direction: .north, meters: meters)
    }
    
    func sampleTask() {
        self.taskContext.runSampleTask()
    }
}
