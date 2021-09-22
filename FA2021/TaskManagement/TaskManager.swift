enum TaskType {
	case FlyToTask, GetDataTask, NonTerminalTask
}

struct TaskManager {

    
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
        let availableTask = retrieveAvailableTasks()
        for task in availableTask {
            
        }
    }
}
