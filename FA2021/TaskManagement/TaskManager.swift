import Foundation

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
    let api:CoatyAPI
    init() {
        currentTasks = []
        api=CoatyAPI()
    }

    func unfinishedTasksChanged(unfinishedTasks: [Task]){
        if (!currentTasks.isEmpty) {
            return
        }

        for task in unfinishedTasks {
            /*if (task.drone_id == nil) {

                // TODO: registerForTask(task.id, checkTaskResponsibility)

                //TODO: startTask(task)  // api call to drone team

                return
            }*/
        }
    }

    /**
     expected parameters:
     -[{taskId, droneId, timestamp}] where taskId is always the same (the one we registered for)
        --> we can filter for earliest timestamp, see if we currenlty to this task
     */
    func checkTaskResponsibility(taskId:String) {

    }

    func getAvailableTasks(callback: @escaping ([Task])->Void) {
        
            /*api.droneController?.retrieveAvailableTasks().subscribe(onNext:{r in
                callback(self.parseJsonToTasks(json: r.json))
            }).dispose()*/
    }

}
