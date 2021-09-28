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
        ReactTypeUtil<[Task]>.subAll( dispose: api.droneController?.disposeBag, observable: api.allTasksObservable){
            tasks in api.droneController?.getDroneTableSync()?.updateData({ old in old.updateTaskTable(activeTaskSet: Set(tasks))})
        }
        
        /**
         check if this drone is still responsible for all currentTasksId everytime a new TaskTable was received
         */
        ReactTypeUtil<TaskTable>.subAll(dispose: api.droneController?.disposeBag, observable: api.droneController?.getDroneTableSync()?.getDataObservable()) {
            table in self.checkResponsibilityForTask(taskTable: table)
        }
    }
    
    /**
     entry point
     */
    func scanForTask(){
        // TODO: Test this method
        api.droneController?.getDroneTableSync()?.getDataObservable()
            .skipWhile({ table in
                table.table.allSatisfy { entry in
                    entry.value.state != TaskTable.TaskState.available
                }
            })
            .take(1)
            .subscribe(onNext: { table in
                if (!self.currentTasksId.isEmpty){
                    return
                }
                DispatchQueue.global().async {
                    let unfinishedTaskIds = self.getUnfinishedTasksId()
                    self.claimTask(taskId: unfinishedTaskIds[0])
                }
            })
            .disposed(by: api.droneController!.disposeBag)
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
        
        currentTasksId.insert(taskId)
        api.droneController?.claimTask(taskId: taskId, droneId: droneId)
        
        // TODO: call drone team api to start task
        taskContext.runSampleTask()
    }    
    
    func checkResponsibilityForTask(taskTable: TaskTable){
        for taskId in currentTasksId {
            if let tableResult: TaskTable.DroneClaim = taskTable.table[taskId] {
                if (tableResult.state == .available || tableResult.droneId == droneId) {
                    print("keep task: " + taskId)
                    return
                }
                
                print("Giving up task \(taskId) to drone \(tableResult.droneId)")
            }
            
            
            // TODO: call drone team api to abort Task with taskId
            currentTasksId.remove(taskId)
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
