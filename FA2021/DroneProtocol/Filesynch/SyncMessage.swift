//
//  TaskStatus.swift
//  iDroneControl
//
//  Created by FA21 on 22.09.21.
//
import Foundation
import CoatySwift

final class SyncMessage<T: Codable>: CoatyObject{
    
    // MARK: - Class registration.
    override class var objectType: String {
        return register(objectType: "idrone.sync.syncmessage", with: self)
    }
    
    // MARK: - Properties.
    
    var object: T
    
    
    // MARK: - Initializers.
    
    init(_ object: T) {
        self.object = object
        super.init(coreType: .CoatyObject,
                   objectType: TasksDetails.objectType,
                   objectId: .init(),
                   name: "SyncMessage")
    }
    
    enum CodingKeys: String, CodingKey{
        case object
    }
    
    // MARK: Codable methods.
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.object = try container.decode(T.self, forKey: .object)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(object, forKey: .object)
    }
}
