import Foundation
import DroneProtocol

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
