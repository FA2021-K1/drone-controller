import Foundation

enum TaskType: String, Decodable {
    case FlyToTask, GetDataTask, NonTerminalTask
}

class Task {
    let id: String
    let name: String
    let type: TaskType
    let drone_id: String?
    
    internal init(id: String, name: String, type: TaskType, drone_id: String) {
        self.id = id
        self.name = name
        self.type = type
        self.drone_id = drone_id
    }
}

class FlyToTask: Task {
    let latitude: Double
    let longitude: Double
    let altitude: Double

    internal init(id: String, name: String, type: TaskType, drone_id: String, latitude: Double, longitude: Double, altitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        super.init(id: id, name: name, type: type, drone_id: drone_id)
    }
}

class NonTerminalTask: Task {
    let tasks: [Task]

    init(id: String, name: String, type: TaskType, drone_id: String, tasks: [Task]) {
        self.tasks = tasks
        super.init(id: id, name: name, type: type, drone_id: drone_id)
    }
}

class GetDataTask: Task {
}

class UnknownTask: Decodable {
    let id: String
    let name: String
    let type: TaskType
    let drone_id: String
    let latitude: Double?
    let longitude: Double?
    let altitude: Double?
    let tasks: [UnknownTask]?
}