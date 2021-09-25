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
            try! print(String(JSONSerializer.toJson(tasks)))
        })
        api.droneController?.getDroneTableSync()?.getDataObservable().subscribe(onNext: {
            table in self.checkResponsibilityForTask(taskTable: table)
        })
    }
    
    /**
     entry point
     */
    func scanForTask(){
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
