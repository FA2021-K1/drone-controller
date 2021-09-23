//
//  TaskTable.swift
//  FA2021
//
//  Created by FA21 on 23.09.21.
//

import Foundation

class TaskTable: Encodable {
    enum TaskState: UInt8 {
        case available
        case claimed
        case finished
    }
    
    struct DroneClaim
    {
        var droneId: String
        var timestamp: TimeInterval
    }
    
    var table = [String : DroneClaim]()
    
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
        
    }
}
