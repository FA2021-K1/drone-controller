import Foundation
import RxSwift
class FirstComeFirstServe: TaskManager {

    var api: CoatyAPI
    var droneId: String
    var currentTasksId: Set<String>

    init(droneId: String) {
        self.droneId = droneId
        self.api = CoatyAPI()
        api.start()
        currentTasksId = []
        api.allTasksObservable?.subscribe(onNext: { tasks in
            print(tasks)
        })
        api.droneController?.getDroneTableSync()?.getDataObservable().subscribe(onNext: {
                     table in self.checkResponsibilityForTask(taskTable: table)
                 })
        // TODO: Move this to a proper place
        _ = Observable
             .timer(RxTimeInterval.seconds(0),
                    period: RxTimeInterval.seconds(1),
                    scheduler: MainScheduler.instance)
            .subscribe(onNext: { (i: Int) in
                self.api.postLiveData(data: """
                    {
                        "position":{
                            "latitude":\(46.74588+0.0005*sin(Float(i)/5)),
                            "longitude":\(11.35683+0.0005*cos(Float(i)/5)),
                            "altitude":\(26+(i%50))
                        },
                        "speed":5,
                        "batteryLevel":\(100-((i/4)%100)),
                        "tasks":[
                            {
                                "task_id":22,
                                "status": "claimed"
                            },
                            {
                                "task_id":28,
                                "status": "finished"
                            }
                        ],
                        "drone_id": 123
                    }
                """)
             })
        
    }
    
    /**
     entry point
     */
    func scanForTask(){
        
        /**
         TODO: remove this
         */
        claimTask(taskId: "DOIT")
        claimTask(taskId: "DOTHAT")
        /**/
        
        
        var unfinishedTaskIds: [String] = getUnfinishedTasksId()
                
        while (unfinishedTaskIds.isEmpty) {
            sleep(1)
            unfinishedTaskIds = getUnfinishedTasksId()
        }
        
        claimTask(taskId: unfinishedTaskIds[0])
    }
    
    
    /**
     looks at current TaskTable
     @return List of tasks that are available
     */
    func getUnfinishedTasksId() -> [String] {
        return getTable().filter {$0.value.state == TaskTable.TaskState.available}.map {$0.key}
    }
    
    func getTable() -> [String: TaskTable.DroneClaim] {
        // TODO: insert semaphor or something similar
       return (api.droneController?.getDroneTableSync()?.localInstance.table)!
    }
    
    
    func claimTask(taskId: String) {
        
        print("claim Task")
        
        api.droneController?.claimTask(taskId: taskId, droneId: droneId)
        currentTasksId.insert(taskId)
        
        // TODO: call drone team api to start task
    }    
    
    func checkResponsibilityForTask(taskTable: TaskTable){
        
        try! print(String(data: JSONEncoder().encode(taskTable), encoding: .utf8))
        
        for taskId in currentTasksId {
      
            if let tableResult: TaskTable.DroneClaim = taskTable.table[taskId] {
             
                if (tableResult.droneId == droneId) {
                    return
                }
            }
            
            // TODO: call drone team api to abort Task with taskId
            currentTasksId.remove(taskId)
        }
    }
    
}
