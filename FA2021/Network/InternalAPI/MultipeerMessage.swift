//
//  MultipeerMessage.swift
//  FA2021
//
//  Created by Ferienakademie on 22.09.21.
//

import Foundation

struct MultipeerMessage: Codable {
    static let senderUserInfoKey = CodingUserInfoKey(rawValue: "sender")!
    
    let type: String
    let payload: Any?

    init(type: String, payload: Any) {
        self.type = type
        self.payload = payload
    }

    enum CodingKeys: String, CodingKey {
        case type
        case payload
    }

    private typealias MessageDecoder = (KeyedDecodingContainer<CodingKeys>, Peer) throws -> Any
    private typealias MessageEncoder = (Any, inout KeyedEncodingContainer<CodingKeys>) throws -> Void

    private static var decoders: [String: MessageDecoder] = [:]
    private static var encoders: [String: MessageEncoder] = [:]

    static func register<T: Codable>(_ type: T.Type, for typeName: String, closure: @escaping (T, Peer) -> Void) {
        decoders[typeName] = { container, peer in
            let payload = try container.decode(T.self, forKey: .payload)

            DispatchQueue.main.async { closure(payload, peer) }

            return payload
        }

        register(T.self, for: typeName)
    }

    static func register<T: Encodable>(_ type: T.Type, for typeName: String) {
        encoders[typeName] = { payload, container in
            try container.encode(payload as! T, forKey: .payload)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        
        let sender = decoder.userInfo[MultipeerMessage.senderUserInfoKey]! as! Peer

        if let decode = Self.decoders[type] {
            payload = try decode(container, sender)
        } else {
            payload = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(type, forKey: .type)

        if let payload = self.payload {
            guard let encode = Self.encoders[type] else {
                let context = EncodingError.Context(codingPath: [], debugDescription: "Invalid payload type: \(type).")
                throw EncodingError.invalidValue(self, context)
            }

            try encode(payload, &container)
        } else {
            try container.encodeNil(forKey: .payload)
        }
    }

}
