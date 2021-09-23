import Foundation

class FirstComeFirstServe: TaskManager {
    var syncLib: SyncLibrary
    
    var currentTasks: [Task]
    var droneId: String // TODO: find out from where to get droneId
    
    init(droneId: String) {
        currentTasks = []
        // TODO: registerForUnfinishedTasks() // api call to syncLibrary
        self.droneId = droneId
        self.syncLib = SyncLibrary(droneId: droneId)
    }
    
    /**
     entry point
     */
    func scanForTask(){
            
        if (!currentTasks.isEmpty) {
            return
        }
        // note: we expect the query to only return unfinishedTasks
        // TODO: api call
        var unfinishedTasks: [Task] = syncLib.makeQuery()


        while unfinishedTasks.isEmpty {
            sleep(1)

            // TODO: api call
            unfinishedTasks = syncLib.makeQuery()
        }

        selectTaskFromAvailableTasks(unfinishedTasks: unfinishedTasks)
    }
    
    
    func selectTaskFromAvailableTasks(unfinishedTasks: [Task]){
        for task in unfinishedTasks {
            if (task.drone_id == nil) {
                
                // TODO: api call
                syncLib.registerForTask(taskId: task.id, function: checkTaskResponsibility)
                
                // TODO: api call
                syncLib.startTask(task: task)  // api call to drone team
                currentTasks.append(task)
                
                return
            }
        }
    }
    
    /**
     expected parameters:
     -[{taskId, droneId, timestamp}] where taskId is always the same (the one we registered for)
     --> we can filter for earliest timestamp, see if we currenlty to this task
     */
    func checkTaskResponsibility(taskRegistrations: [TaskRegistration]){
        
        let earliestTaskRegistration = getEarliestTaskRegistration(taskRegistrations: taskRegistrations)
        
        if (earliestTaskRegistration.droneId == droneId){
            // continue executing task
            return
        }
        
        // remove respective task from currentTasks when aborting
        currentTasks = currentTasks.filter { task in task.id != earliestTaskRegistration.taskId }
        
        // TODO: abort task execution // api call to drone team
        syncLib.abortTask()
        
        // TODO: start again searching for available tasks
        // scanForTask()
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
    
    
    // json parsing
    func parseJsonToTasks(json: String) -> [Task] {
        guard let data = json.data(using: .utf8) else {
            return []
        }
        var unknown_tasks: [UnknownTask] = []
        do {
            unknown_tasks = try! JSONDecoder().decode([UnknownTask].self, from: data)
        }
        var tasks: [Task] = []
        for unknown_task in unknown_tasks {
            tasks.append(parseTask(unknown: unknown_task))
        }
        
        return tasks
    }
    
    func parseTask(unknown: UnknownTask) -> Task {
        let id: String = unknown.id
        let name: String = unknown.name
        let type: TaskType = unknown.type
        let drone_id: String = unknown.drone_id
        let task: Task
        
        switch type {
        case .FlyToTask:
            task = FlyToTask(id: id, name: name, type: type, drone_id: drone_id,
                             latitude: unknown.latitude ?? 0,
                             longitude: unknown.longitude ?? 0,
                             altitude: unknown.altitude ?? 0)
            
        case .GetDataTask:
            task = GetDataTask(id: id, name: name, type: type, drone_id: drone_id)
            
        case .NonTerminalTask:
            var tasks: [Task] = []
            if let unknown_tasks: [UnknownTask] = unknown.tasks {
                for unknown_task in unknown_tasks {
                    tasks.append(parseTask(unknown: unknown_task))
                }
            } else {
                tasks = []
            }
            task = NonTerminalTask(id: id, name: name, type: type, drone_id: drone_id, tasks: tasks)
        }
        return task
    }
}
