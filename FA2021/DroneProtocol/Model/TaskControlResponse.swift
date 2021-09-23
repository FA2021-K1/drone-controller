//
//  AvailableResponse.swift
//  iDroneControl
//
//  Created by FA21 on 22.09.21.
//
import Foundation
import CoatySwift

final class AvailableTasksResponse: CoatyObject{
    
     let availableTasksIDs:[String]
    // MARK: - Class registration.
    override class var objectType: String {
        return register(objectType: "idrone.sync.availables", with: self)
    }
    
    enum CodingKeys: String, CodingKey{
        case availableTasksIDs
    }
    
    // MARK: Codable methods.
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.availableTasksIDs = try container.decode([String].self, forKey: .availableTasksIDs)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(availableTasksIDs, forKey: .availableTasksIDs)
    }
}
