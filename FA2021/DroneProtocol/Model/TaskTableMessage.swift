//
//  TaskStatus.swift
//  iDroneControl
//
//  Created by FA21 on 22.09.21.
//
import Foundation
import CoatySwift

final class TaskTableMessage: CoatyObject{
    
    // MARK: - Class registration.
    override class var objectType: String {
        return register(objectType: "idrone.sync.tasktable", with: self)
    }
    
    // MARK: - Properties.
    
    var table: TaskTable
    
    
    // MARK: - Initializers.
    
    init(_ table:TaskTable) {
        self.table = table
        super.init(coreType: .CoatyObject,
                   objectType: TasksDetails.objectType,
                   objectId: .init(),
                   name: "TaskTableMessage")
    }
    
    enum CodingKeys: String, CodingKey{
        case table
    }
    
    // MARK: Codable methods.
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.table = try container.decode(TaskTable.self, forKey: .table)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(table, forKey: .table)
    }
}
