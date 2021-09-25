import Foundation

class FirstComeFirstServe: TaskManager {
    
    var api: CoatyAPI
    var currentTasks: [Task]
    var droneId: String // TODO: find out from where to get droneId
    
    init(droneId: String) {
        currentTasks = []
        
        self.droneId = droneId
        self.api = CoatyAPI()
        api.start()
    }
    
    /**
     entry point
     */
    func scanForTask(){
        var unfinishedTasIds: [String] = getUnfinishedTasksId()
        
        
        while (unfinishedTasIds.isEmpty) {
            sleep(1)
            
            unfinishedTasIds = getUnfinishedTasksId()
            
        }
    }
    
    
    /**
     looks at current TaskTable
     @return all tasks that 
     */
    func getUnfinishedTasksId() -> [String] {
        
        var table: [String: TaskTable.DroneClaim] = (api.droneController?.getDroneTableSync()?.localInstance.table)!
        
        var unfinishedTasksId: [String] = []
        for (taskId, droneClaim) in table {
            if (droneClaim.state == TaskTable.TaskState.available) {
                unfinishedTasksId.append(taskId)
            }
        }
        return unfinishedTasksId
    }
    

    
    /**
     expected parameters:
     -[{taskId, droneId, timestamp}] where taskId is always the same (the one we registered for)
     --> we can filter for earliest timestamp, see if we currenlty to this task
     */
    func checkTaskResponsibility(taskRegistrations: [TaskRegistration]){
        
    }
    
    func getEarliestTaskRegistration(taskRegistrations:[TaskRegistration]) -> TaskRegistration{
        var earliestTaskRegistration: TaskRegistration = taskRegistrations[0]
        for taskRegistration in taskRegistrations {
            if (taskRegistration.timestamp < earliestTaskRegistration.timestamp){
                earliestTaskRegistration = taskRegistration
            }
        }
        
        return earliestTaskRegistration
    }
}
