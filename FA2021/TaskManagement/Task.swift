import Foundation

enum TaskType: String, Decodable {
    case FlyToTask, GetDataTask, NonTerminalTask
}

class Task {
    let id: String
    let name: String
    let type: TaskType

    init(id: String, name: String, type: TaskType) {
        self.id = id
        self.name = name
        self.type = type
    }
}

class FlyToTask: Task {
    let latitude: Double
    let longitude: Double
    let altitude: Double

    init(id: String, name: String, type: TaskType, latitude: Double, longitude: Double, altitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        super.init(id: id, name: name, type: type)
    }
}

class NonTerminalTask: Task {
    let tasks: [Task]

    init(id: String, name: String, type: TaskType, tasks: [Task]) {
        self.tasks = tasks
        super.init(id: id, name: name, type: type)
    }
}

class GetDataTask: Task {
}

class UnknownTask: Decodable {
    let id: String
    let name: String
    let type: TaskType
    let latitude: Double?
    let longitude: Double?
    let altitude: Double?
    let tasks: [UnknownTask]?
}
