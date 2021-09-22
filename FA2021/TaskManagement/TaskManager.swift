import Foundation

enum TaskType {
    case FlyToTask, GetDataTask, NonTerminalTask
}

struct TaskRegistration {
    let taskId: String
    let droneId: String
    let timestamp: TimeInterval
    let status: Any
    
    internal init(taskId: String, droneId: String, timestamp: TimeInterval, status: Any) {
        self.taskId = taskId
        self.droneId = droneId
        self.timestamp = timestamp
        self.status = status
    }
}

class TaskManager {
    
    let currentTasks: [Task]
    
    init() {
        currentTasks = []
        // TODO: registerForUnfinishedTasks() // api call to syncLibrary
    }
    
    func unfinishedTasksChanged(unfinishedTasks: [Task]){
        if (!currentTasks.isEmpty) {
            return
        }
        
        for task in unfinishedTasks {
            if (task.drone_id == nil) {
                
                // TODO: registerForTask(task.id, checkTaskResponsibility)
                
                //TODO: startTask(task)  // api call to drone team
                
                return
            }
        }
    }
    
    /**
     expected parameters:
     -[{taskId, droneId, timestamp}] where taskId is always the same (the one we registered for)
        --> we can filter for earliest timestamp, see if we currenlty to this task
     */
    func checkTaskResponsibility(){
        
        
        
    }
    
    
    /**
     @return tasks waiting to be assigned
     */
    func retrieveAvailableTasks() -> [Task] {
        // allTasksAvilableOrInProgress   coaty?: get/observe all tasks in network
        // dronesWorkingOnTaskSinceTimestamp    coaty? (if not coaty add to json): get all drones that work on task with timestamp
        // filter allTasksAvilableOrInProgress with dronesWorkingOnTaskSinceTimestamp
        return [];
    }
    
    /**
     gets called while tasks available
     */
    func aquireTask(){
        let availableTask = retrieveAvailableTasks() // call synchronization library
        for task in availableTask {
            
        }
    }
}
