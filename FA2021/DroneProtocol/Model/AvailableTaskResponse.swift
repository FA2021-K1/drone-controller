//
//  AvailableTaskResponse.swift
//  FA2021
//
//  Created by FA21 on 23.09.21.
//
import Foundation
import CoatySwift

final class AvailableTaskResponse: CoatyObject{
    
    // MARK: - Class registration.
    override class var objectType: String {
        return register(objectType: "idrone.sync.availableTaskResponse", with: self)
    }
    
    // MARK: - Properties.
    
    var availableTasks: [TasksDetails]
    
    
    // MARK: - Initializers.
    
    init() {
        self.availableTasks=[]
        super.init(coreType: .CoatyObject,
                   objectType: TasksDetails.objectType,
                   objectId: .init(),
                   name: "Task")
    }
    
    enum CodingKeys: String, CodingKey{
        case availableTasks
    }
    
    // MARK: Codable methods.
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.jsonDetails = try container.decode(String.self, forKey: .availableTasks)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonDetails, forKey: .jsonDetails)
    }
}
