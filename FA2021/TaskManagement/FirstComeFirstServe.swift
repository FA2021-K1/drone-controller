import Foundation

class FirstComeFirstServe: TaskManager {
    var api: CoatyAPI
    var droneId: String
    
    init(droneId: String) {
        self.droneId = droneId
        self.api = CoatyAPI()
        api.start()
        api.allTasksObservable?.subscribe(onNext: { tasks in
            print(tasks)
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
        api.droneController?.claimTask(taskId: taskId, droneId: droneId)
        
        // TODO: call drone team api to start task
    }    
    
    func checkResponsibilityForTask(correctClaim: TaskTable.DroneClaim){
        
        if (correctClaim.droneId == droneId) {
            return
        }
        
        // TODO: call drone team api to abort task
        
    }
    
    func getCurrentTasksId() -> [String] {
        return getTable().filter {$0.value.droneId == droneId}.map {$0.key}
    }
    
}
