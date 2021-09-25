import Foundation

enum TaskType: String, Decodable {
    case FlyTask, SearchTask, IdleTask, NonTerminalTask
}

class Task {
    let id: String
    let name: String
    
    internal init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    func getTerminalTasksList() -> [Task] {
        if let nonTerminalTask = self as? NonTerminalTask {
            return nonTerminalTask.tasks.flatMap { $0.getTerminalTasksList() }
        } else if self is TerminalTask  {
            return [self]
        } else {
            fatalError("Unexpected task type: Aborting")
        }
    }
    
    static func parseJsonToTasks(json: String) throws -> [Task] {
        guard let data = json.data(using: .utf8) else {
            return []
        }
        var unknown_tasks: [UnknownTask] = []
        do {
            unknown_tasks = try! JSONDecoder().decode([UnknownTask].self, from: data)
        }
        return unknown_tasks.map {(utask) -> Task in parseTask(unknownTask: utask)}
    }
    
    static func parseTask(unknownTask: UnknownTask) -> Task {
        let id: String = unknownTask.id
        let name: String = unknownTask.name
        let type: TaskType = unknownTask.type
        let task: Task

        switch type {
        case .FlyTask:
            task = FlyTask(id: id, name: name, coordinate:
                Coordinate(
                    latitude: unknownTask.latitude ?? 0,
                    longitude: unknownTask.longitude ?? 0,
                    altitude: unknownTask.altitude ?? 0)
            )

        case .SearchTask:
            task = SearchTask(id: id, name: name, coordinate:
                Coordinate(
                    latitude: unknownTask.latitude ?? 0,
                    longitude: unknownTask.longitude ?? 0,
                    altitude: unknownTask.altitude ?? 0),
                radius: unknownTask.radius ?? 0)
            
        case .IdleTask:
            task = IdleTask(id: id, name: name, delay: unknownTask.delay ?? 0)
        
        case .NonTerminalTask:
            var tasks: [Task] = []
            if let unknown_tasks: [UnknownTask] = unknownTask.tasks {
                tasks = unknown_tasks.map {(utask) -> Task in parseTask(unknownTask: utask)}
            } else {
                tasks = []
            }
            task = NonTerminalTask(id: id, name: name, tasks: tasks)
        }
        return task
    }
    
}

class NonTerminalTask: Task {
    let tasks: [Task]

    init(id: String, name: String, tasks: [Task]) {
        self.tasks = tasks
        super.init(id: id, name: name)
    }
}

class TerminalTask: Task {
}

class FlyTask: TerminalTask {
    let coordinate: Coordinate
    
    init(id: String, name: String, coordinate: Coordinate) {
        self.coordinate = coordinate
        super.init(id: id, name: name)
    }
}

class SearchTask: TerminalTask {
    let coordinate: Coordinate
    let radius: Double
    
    init(id: String, name: String, coordinate: Coordinate, radius: Double) {
        self.radius = radius
        self.coordinate = coordinate
        super.init(id: id, name: name)
    }
}

class IdleTask: TerminalTask {
    let delay: Double
    
    init(id: String, name: String, delay: Double) {
        self.delay = delay
        super.init(id: id, name: name)
    }
}

class UnknownTask: Decodable {
    let id: String
    let name: String
    let type: TaskType
    let latitude: Double?
    let longitude: Double?
    let altitude: Double?
    let tasks: [UnknownTask]?
    let radius: Double?
    let delay: Double?
}
