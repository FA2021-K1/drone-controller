enum TaskType {
	case FlyToTask, GetDataTask, NonTerminalTask
}

struct TaskManager {

    func retrieveAvailableTasks() -> [Task] {
	 return [Task()];
	}

    
    func aquireTask(tasks: [Task]){
        
        for task in tasks {
            
        }
        
    }
    
}
