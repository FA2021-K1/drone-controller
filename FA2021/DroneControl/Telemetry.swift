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
                var task_json: String = "["
                var json_needs_comma: Bool = false
                for task_id in taskmanager.currentTasksId {
                    if json_needs_comma {
                        task_json += ","
                    } else {json_needs_comma = true}
                    task_json += """
                    {
                        "task_id": "\(task_id)",
                        "status": "claimed"
                    }
                    """
                }
                for task_id in taskmanager.finishedTasksId {
                    if !json_needs_comma {
                        task_json += ","
                    }
                    task_json += """
                    {
                        "task_id": "\(task_id)",
                        "status": "finished"
                    }
                    """
                }
                task_json += "]"
                print(task_json)
                self.api.postLiveData(data: """
                    {
                        "position":{
                            "latitude":\(46.74588+0.0005*sin(Float(i)/5)),
                            "longitude":\(11.35683+0.0005*cos(Float(i)/5)),
                            "altitude":\(26+(i%50))
                        },
                        "speed":5,
                        "batteryLevel":\(100-((i/4)%100)),
                        "tasks":\(task_json),
                        "drone_id": "\(taskmanager.droneId)"
                    }
                """)
             })
    }
}

