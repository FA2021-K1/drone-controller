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
