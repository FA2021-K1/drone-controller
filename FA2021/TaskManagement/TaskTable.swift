//
//  TaskTable.swift
//  FA2021
//
//  Created by FA21 on 23.09.21.
//

import Foundation

struct TaskTable: Codable, Equatable {
    enum TaskState: UInt8, Codable{
        case available
        case claimed
        case finished
    }
    
    struct DroneClaim: Codable, Equatable
    {
        var droneId: String
        var timestamp: TimeInterval
        var state: TaskState
    }
    
    var table: [String : DroneClaim] = [String : DroneClaim]()
    
    func changeTaskState(taskId: String, droneId: String, timestamp: TimeInterval = TimeUtil.getCurrentTime(), state: TaskTable.TaskState) -> TaskTable{
        // Dictionaries are structs and therefore copy by value
        var newTable = self
        newTable.table[taskId] = TaskTable.DroneClaim(droneId: droneId, timestamp: timestamp, state: state)
        return newTable
    }
    
    func updateTable(otherTable: TaskTable) -> TaskTable {
        var newTable = self
        newTable.table.merge(otherTable.table) { claimOne, claimTwo in
            claimOne.timestamp < claimTwo.timestamp ? claimOne : claimTwo
        }
        return newTable
    }
    
    init() {}
    
    enum CodingKeys: String, CodingKey{
        case table
    }
    // MARK: Codable methods.
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.table = try container.decode([String : DroneClaim].self, forKey: .table)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(table, forKey: .table)
    }
}
