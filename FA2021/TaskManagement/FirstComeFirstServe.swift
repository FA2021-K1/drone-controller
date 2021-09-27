import Foundation
import RxSwift
class FirstComeFirstServe: TaskManager {
    var taskContext: TaskContext
    var api: CoatyAPI
    var droneId: String
    var currentTasksId: Set<String>
    var finishedTasksId: Set<String>

    init(api: CoatyAPI, droneId: String, taskContext: TaskContext) {
        self.droneId = droneId
        self.api = api
        self.taskContext = taskContext
        api.start()
        currentTasksId = []
        finishedTasksId = []
        
        /**
         updateTaskTable everytime a new TaskList was received
         */
        api.allTasksObservable?.subscribe(onNext: { tasks in api.droneController?.getDroneTableSync()?.setData(newData:  (api.droneController?.getDroneTableSync()?.value.updateTaskTable(activeTaskSet: Set(tasks)))!)
        })
        
        /**
         check if this drone is still responsible for all currentTasksId everytime a new TaskTable was received
         */
        api.droneController?.getDroneTableSync()?.getDataObservable().subscribe(onNext: {
            table in self.checkResponsibilityForTask(taskTable: table)
        })
    }
    
    /**
     entry point
     */
    func scanForTask(){
        print("Starting scan")
        // TODO: Test this method.
        api.droneController?.getDroneTableSync()?.getDataObservable()
            .skipWhile({ table in
                table.table.allSatisfy { entry in
                    entry.value.state != TaskTable.TaskState.available
                }
            })
            .take(1)
            .subscribe(onNext: { table in
                let unfinishedTaskIds = self.getUnfinishedTasksId()
                self.claimTask(taskId: unfinishedTaskIds[0])
                print("Scan sub")
            })
        print("Scan end")
    }
    
    
    /**
     looks at current TaskTable
     @return List of tasks that are available
     */
    func getUnfinishedTasksId() -> [String] {
        return getTable().filter {$0.value.state == TaskTable.TaskState.available}.map {$0.key}
    }
    
    func getTable() -> [String: TaskTable.DroneClaim] {
        return api.droneController?.getDroneTableSync()?.value.table ?? [:]
    }
    
    
    func claimTask(taskId: String) {
        
        print("Claim task, task_id: \(taskId)")
        
        api.droneController?.claimTask(taskId: taskId, droneId: droneId)
        currentTasksId.insert(taskId)
        
        // TODO: call drone team api to start task
        taskContext.runSampleTask()
        
        // TODO: remove this timer
        // it is only for testing purpose
        let _ = Timer.scheduledTimer(withTimeInterval: 45, repeats: false) {
            _ in self.currentTasksId.remove(taskId)
            print("timer ended")
            DispatchQueue.global().async {
                self.scanForTask()
            }
        }
        RunLoop.current.run()
    }    
    
    func checkResponsibilityForTask(taskTable: TaskTable){
        for taskId in currentTasksId {
            if let tableResult: TaskTable.DroneClaim = taskTable.table[taskId] {
                if (tableResult.state == .available || tableResult.droneId == droneId) {
                    print("keep task: " + taskId)
                    try! print(JSONEncoder().encode(taskTable).prettyPrintedJSONString!)
                    return
                }
                
                print("Giving up task \(taskId) to drone \(tableResult.droneId)")
            }
            
            
            // TODO: call drone team api to abort Task with taskId
            currentTasksId.remove(taskId)
            
            // Scan needs to be started in another thread because this one doesn't belong to us but to the Sync control flow
            DispatchQueue.global().async {
                self.scanForTask()
            }
        }
    }
}


extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return prettyPrintedString
    }
}
