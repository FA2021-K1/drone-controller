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
//        try! print(JSONEncoder().encode(newTable).prettyPrintedJSONString!)
        return newTable
    }
    
    init(taskSet: Set<Task> = [], table: [String : DroneClaim] = [String : DroneClaim]()) {
        self.taskSet = taskSet
        self.table = table
    }
    
    /**
     Returns a new TaskTable with the same table, but different TaskSet.
     */
    func withTaskSet(_ taskSet: Set<Task>) -> TaskTable{
        return TaskTable(taskSet: taskSet, table: self.table)
    }
    
    /**
     gets called when another TaskList was received
     */
    func updateTaskTable(activeTaskSet: Set<Task>) -> TaskTable {
        let newTasksSet: Set<Task> = activeTaskSet.symmetricDifference(taskSet)
        
        if newTasksSet.isEmpty {
            return self
        }
        
        var newTable = self.withTaskSet(newTasksSet)
        
        for task in newTasksSet {
            print("Add task to TaskTable, task_id: \(task.id)")
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
