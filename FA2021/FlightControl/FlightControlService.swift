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
    private var droneController: AircraftController
    private var taskContext: TaskContext
    
    init(log: Log) {
        self.log = log
        self.connectionManager = DroneConnectionManager(log: log)
        self.droneController = AircraftController(log: log, droneConnection: connectionManager)
        self.missionScheduler = MissionScheduler(log: log, droneController: droneController)
        self.taskContext = TaskContext(log: log, aircraftController: droneController)
        log.add(message: "FlightControlService initialized")
    }
    
    func takeOff() {
        self.droneController.takeOff()
    }
    
    func land() {
        self.droneController.land()
    }
    
    func flyNorth(meters: Double) {
        self.missionScheduler.flyDirection(direction: .north, meters: meters)
    }
    
    func sampleTask() {
        self.taskContext.runSampleTask()
    }
}