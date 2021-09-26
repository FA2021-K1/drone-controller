//
//  LiveData.swift
//  FA2021
//
//  Created by FA21 on 25.09.21.
//

import Foundation
import CoatySwift

final class LiveData: CoatyObject{
    
    // MARK: - Class registration.
    override class var objectType: String {
        return register(objectType: "idrone.sync.livedata", with: self)
    }
    
    // MARK: - Properties.
    
    var jsonDetails: String
    
    
    // MARK: - Initializers.
    
    init(json:String) {
        self.jsonDetails=json
        super.init(coreType: .CoatyObject,
                   objectType: LiveData.objectType,
                   objectId: .init(),
                   name: "LiveData")
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
