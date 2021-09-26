//
//  TaskTable.swift
//  FA2021
//
//  Created by FA21 on 23.09.21.
//

import Foundation

struct TaskTable: Codable, Equatable {
    
    let taskSet: Set<Task>
    var table: [String : DroneClaim]
    
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
    
    func changeTaskState(taskId: String, droneId: String, timestamp: TimeInterval = TimeUtil.getCurrentTime(), state: TaskTable.TaskState) -> TaskTable{
        // Dictionaries are structs and therefore copy by value
        var newTable = self
        newTable.table[taskId] = TaskTable.DroneClaim(droneId: droneId, timestamp: timestamp, state: state)
        return newTable
    }
    
    /**
     gets called when another TaskTable was received
     */
    func updateTable(otherTable: TaskTable) -> TaskTable {
        var newTable = self
        newTable.table.merge(otherTable.table) { claimOne, claimTwo in
            if (claimOne.state == .available){
                return claimTwo
            }
            if (claimTwo.state == .available) {
                return claimOne
            }
            return claimOne.timestamp < claimTwo.timestamp ? claimOne : claimTwo
        }
        
        return newTable
    }
    
    init(taskSet: Set<Task> = [], table: [String : DroneClaim] = [String : DroneClaim]()) {
        self.taskSet = taskSet
        self.table = table
    }
    
    /**
     gets called when another TaskList was received
     */
    func updateTaskTable(activeTaskList: [Task]) -> TaskTable {
        
        let activeTaskSet: Set<Task> = Set(activeTaskList)
        let newTasksSet: Set<Task> = activeTaskSet.symmetricDifference(taskSet)
        
        if newTasksSet.isEmpty {
            return self
        }
        
        var newTable = TaskTable(taskSet: newTasksSet, table: self.table)
        for task in newTasksSet {
            print("add new task to tasktable")
            // TODO: initialize with something better
        
            newTable.table[task.id] = DroneClaim(droneId: "", timestamp: 0, state: TaskState.available)
        }
        
        return newTable
    }
    
    enum CodingKeys: String, CodingKey{
        case table
    }
    // MARK: Codable methods.
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.table = try container.decode([String : DroneClaim].self, forKey: .table)
        taskSet = []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(table, forKey: .table)
    }
}
