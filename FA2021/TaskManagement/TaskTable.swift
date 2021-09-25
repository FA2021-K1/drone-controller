//
//  TaskTable.swift
//  FA2021
//
//  Created by FA21 on 23.09.21.
//

import Foundation

class TaskTable: Codable {
    enum TaskState: UInt8, Codable{
        case available
        case claimed
        case finished
    }
    
    struct DroneClaim: Codable
    {
        var droneId: String
        var timestamp: TimeInterval
        var state: TaskState
    }
    
    var table: [String : DroneClaim]
    
    init() {
        table = [String : DroneClaim]()
    }
    
    func updateTable(otherTable: TaskTable) -> TaskTable {
        table.merge(otherTable.table) { claimOne, claimTwo in
            let correctClaim = claimOne.timestamp < claimTwo.timestamp ? claimOne : claimTwo
            onConflict(correctClaim: correctClaim)
            return correctClaim
        }
        
        return self
    }
    
    func onConflict(correctClaim: DroneClaim){
        //TODO...
    }
    
    enum CodingKeys: String, CodingKey{
        case table
    }
    
    // MARK: Codable methods.
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.table = try container.decode([String : DroneClaim].self, forKey: .table)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(table, forKey: .table)
    }
}
