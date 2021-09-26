import Foundation
import RxSwift
class FirstComeFirstServe: TaskManager {

    var api: CoatyAPI
    var droneId: String
    var currentTasksId: Set<String>

    init(api: CoatyAPI, droneId: String) {
        self.droneId = droneId
        self.api = api
        api.start()
        currentTasksId = []
        
        /**
         updateTaskTable everytime a new TaskList was received
        */
        api.allTasksObservable?.subscribe(onNext: { tasks in                     api.droneController?.getDroneTableSync()?.setData(newData:  (api.droneController?.getDroneTableSync()?.value.updateTaskTable(activeTaskList: tasks))!)
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
        return api.droneController?.getDroneTableSync()?.value.table ?? [:]
    }
    
    
    func claimTask(taskId: String) {
        
        print("claim Task")
        
        api.droneController?.claimTask(taskId: taskId, droneId: droneId)
        currentTasksId.insert(taskId)
        
        // TODO: call drone team api to start task
    }    
    
    func checkResponsibilityForTask(taskTable: TaskTable){
                
        for taskId in currentTasksId {
      
            if let tableResult: TaskTable.DroneClaim = taskTable.table[taskId] {
             
                if (tableResult.state == .available || tableResult.droneId == droneId) {
                    print("keep task: " + taskId)
                    try! print(JSONEncoder().encode(taskTable).prettyPrintedJSONString!)
                    return
                }
            }
            
            print("giving up task: " + taskId)
            // TODO: call drone team api to abort Task with taskId
            currentTasksId.remove(taskId)
            scanForTask()
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
