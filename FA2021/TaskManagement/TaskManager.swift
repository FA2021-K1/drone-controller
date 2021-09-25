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
    var api: CoatyAPI { get }
    var currentTasksId: Set<String> { get }

    func scanForTask()
}
