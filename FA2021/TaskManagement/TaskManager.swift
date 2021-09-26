import Foundation

struct TaskRegistration {
    let taskId: String
    let droneId: String
    let timestamp: TimeInterval
    let status: Any
}

protocol TaskManager {
    var api: CoatyAPI { get }
    var currentTasksId: Set<String> { get }

    func scanForTask()
}
