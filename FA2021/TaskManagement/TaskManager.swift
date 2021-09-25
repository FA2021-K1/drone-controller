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

protocol TaskManager {
    var currentTasks: [Task] { get set }
    var api: CoatyAPI { get }

    func scanForTask()
}

extension TaskManager {

    func getAvailableTasks(callback: @escaping ([Task])->Void) {

                /*api.droneController?.retrieveAvailableTasks().subscribe(onNext:{r in
                    callback(self.parseJsonToTasks(json: r.json))
                }).dispose()*/
        }
}
