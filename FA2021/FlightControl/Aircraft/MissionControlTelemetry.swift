//
//  Telemetry.swift
//  FA2021
//
//  Created by FA21 on 26.09.21.
//

import Foundation
import RxSwift

class MissionControlTelemetry {
    let aircraft: Aircraft
    let api: CoatyAPI
    let taskmanager: TaskManager
    
    init(aircraft: Aircraft, api: CoatyAPI, taskmanager: TaskManager){
        self.aircraft = aircraft
        self.taskmanager = taskmanager
        self.api = api
        
        ReactUtil.infiniteTimer(interval: 1) { i in
            // Convert and encode claimed and finished tasks into telemetry json format
            var telemetry_tasks: [TaskTelemetry] = taskmanager.currentTasksId.map{task_id in TaskTelemetry(task_id: task_id, status: "claimed")}
            telemetry_tasks += taskmanager.finishedTasksId.map{task_id in TaskTelemetry(task_id: task_id, status: "finished")}
            let task_json_string = try! String(data: JSONEncoder().encode(telemetry_tasks), encoding: .utf8) ?? "[]"
            
            self.api.postLiveData(data: """
                {
                    "position":{
                        "latitude":\(self.aircraft.status.currentPosition?.coordinate.latitude ?? 0),
                        "longitude":\(self.aircraft.status.currentPosition?.coordinate.longitude ?? 0),
                        "altitude":\(self.aircraft.status.currentPosition?.altitude ?? 0)
                    },
                    "speed":5,
                    "batteryLevel":\(self.aircraft.status.batteryLevel ?? 0),
                    "tasks":\(task_json_string),
                    "drone_id": "\(taskmanager.droneId)"
                }
            """)
        }
    }
}

class TaskTelemetry: Codable {
    let task_id: String
    let status: String
    
    init(task_id: String, status: String) {
        self.task_id = task_id
        self.status = status
    }
}
