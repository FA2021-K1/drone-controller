//
//  TaskStatus.swift
//  iDroneControl
//
//  Created by FA21 on 22.09.21.
//
import Foundation
import CoatySwift

final class TasksDetails: CoatyObject{
    
    // MARK: - Class registration.
    override class var objectType: String {
        return register(objectType: "idrone.sync.task", with: self)
    }
    
    // MARK: - Properties.
    
    var jsonDetails: String
    
    
    // MARK: - Initializers.
    
    init(json:String) {
        self.jsonDetails=json
        super.init(coreType: .CoatyObject,
                   objectType: TasksDetails.objectType,
                   objectId: .init(),
                   name: "Task")
    }
    
    enum CodingKeys: String, CodingKey{
        case jsonDetails
    }
    
    // MARK: Codable methods.
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.jsonDetails = try container.decode(String.self, forKey: .jsonDetails)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonDetails, forKey: .jsonDetails)
    }
}
