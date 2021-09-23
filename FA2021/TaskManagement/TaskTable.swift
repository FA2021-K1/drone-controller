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
    
    func updateTable(otherTable: TaskTable){
        table.merge(otherTable.table) { claimOne, claimTwo in
            let correctClaim = claimOne.timestamp < claimTwo.timestamp ? claimOne : claimTwo
            onConflict(correctClaim: correctClaim)
            return correctClaim
        }
    }
    
    func onConflict(correctClaim: DroneClaim){
        //TODO...
    }
    
    func encode(to encoder: Encoder) throws {
        return try! table.encode(to: encoder)
    }
    
    required init(from decoder: Decoder) throws {
        table = [String : DroneClaim](from: decoder)
        try super.init(from: decoder)
    }
}
