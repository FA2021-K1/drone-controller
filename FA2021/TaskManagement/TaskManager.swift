import Foundation

struct TaskRegistration {
    let taskId: String
    let droneId: String
    let timestamp: TimeInterval
    let status: Any
}

protocol TaskManager {
    var api: CoatyAPI { get }
    var droneId: String { get }
    var currentTasksId: Set<String> { get }
    var finishedTasksId: Set<String> { get }
    var taskContext: TaskContext { get }

    func scanForTask()
}
