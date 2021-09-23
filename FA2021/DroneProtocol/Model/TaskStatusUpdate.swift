
//
//  TaskStatus.swift
//  iDroneControl
//
//  Created by FA21 on 22.09.21.
//
import Foundation
import CoatySwift

final class TaskStatusUpdate: CoatyObject{
    
    // MARK: - Class registration.
    override class var objectType: String {
        return register(objectType: "idrone.sync.taskmessage", with: self)
    }
    
    // MARK: - Properties.
    
    var droneId: String
    var taskId: String
    var state: TaskState
    var timestamp: TimeInterval
    
    
    // MARK: - Initializers.
    
    init(droneId: String, taskId: String, state: TaskState) {
        self.droneId = droneId
        self.taskId = taskId
        self.state = state
        self.timestamp = TimeUtil.getCurrentTime()
        super.init(coreType: .CoatyObject,
                   objectType: TaskStatusUpdate.objectType,
                   objectId: .init(),
                   name: "TaskMessage")
    }
    
    // MARK: Codable methods.
    
    enum TaskState: UInt8, Codable {
        case available
        case inProgress
        case finished
        case renew
        case dismissed
    }
    
    enum CodingKeys: String, CodingKey{
        case droneId
        case taskId
        case state
        case timestamp
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.droneId = try container.decode(String.self, forKey: .droneId)
        self.taskId = try container.decode(String.self, forKey: .taskId)
        self.state = try container.decode(TaskState.self, forKey: .state)
        self.timestamp = try container.decode(TimeInterval.self, forKey: .timestamp)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(droneId, forKey: .droneId)
        try container.encode(taskId, forKey: .taskId)
        try container.encode(state, forKey: .state)
        try container.encode(timestamp, forKey: .timestamp)
    }
}
