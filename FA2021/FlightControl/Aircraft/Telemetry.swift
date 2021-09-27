//
//  Telemetry.swift
//  FA2021
//
//  Created by FA21 on 26.09.21.
//

import Foundation
import RxSwift

class Telemetry {
    let api: CoatyAPI
    let taskmanager: TaskManager
    
    init(api: CoatyAPI, taskmanager: TaskManager){
        self.taskmanager = taskmanager
        self.api = api
        
        // sending mock data currently
        _ = Observable
            .timer(RxTimeInterval.seconds(0),
                   period: RxTimeInterval.seconds(1),
                   scheduler: MainScheduler.instance)
            .subscribe(onNext: { (i: Int) in
                
                // Convert and encode claimed and finished tasks into telemetry json format
                var telemetry_tasks: [TaskTelemetry] = taskmanager.currentTasksId.map{task_id in TaskTelemetry(task_id: task_id, status: "claimed")}
                telemetry_tasks += taskmanager.finishedTasksId.map{task_id in TaskTelemetry(task_id: task_id, status: "finished")}
                let task_json_string = try! String(data: JSONEncoder().encode(telemetry_tasks), encoding: .utf8) ?? "[]"
                
                self.api.postLiveData(data: """
                    {
                        "position":{
                            "latitude":\(46.74588+0.0005*sin(Float(i)/5)),
                            "longitude":\(11.35683+0.0005*cos(Float(i)/5)),
                            "altitude":\(26+(i%50))
                        },
                        "speed":5,
                        "batteryLevel":\(100-((i/4)%100)),
                        "tasks":\(task_json_string),
                        "drone_id": "\(taskmanager.droneId)"
                    }
                """)
            })
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
