import Foundation

struct TaskManager {
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
        let task: Task

        switch type {
        case .FlyToTask:
            task = FlyToTask(id: id, name: name, type: type,
                    latitude: unknown.latitude ?? 0,
                    longitude: unknown.longitude ?? 0,
                    altitude: unknown.altitude ?? 0)

        case .GetDataTask:
            task = GetDataTask(id: id, name: name, type: type)

        case .NonTerminalTask:
            var tasks: [Task] = []
            if let unknown_tasks: [UnknownTask] = unknown.tasks {
                for unknown_task in unknown_tasks {
                    tasks.append(parseTask(unknown: unknown_task))
                }
            } else {
                tasks = []
            }
            task = NonTerminalTask(id: id, name: name, type: type, tasks: tasks)
        }
        return task
    }

    /**
     gets called while tasks available
     */
    func acquireTask() {
        let availableTask = retrieveAvailableTasks()
        for task in availableTask {

        }
    }

    /**
    @return tasks waiting to be assigned
    */
    func retrieveAvailableTasks() -> [Task] {
        // allTasksAvailableOrInProgress   coaty?: get/observe all tasks in network
        // dronesWorkingOnTaskSinceTimestamp    coaty? (if not coaty add to json): get all drones that work on task with timestamp
        // filter allTasksAvailableOrInProgress with dronesWorkingOnTaskSinceTimestamp
        return [];
    }
}