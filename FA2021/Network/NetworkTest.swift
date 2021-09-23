//
//  NetworkTest.swift
//  FA2021
//
//  Created by Ferienakademie on 22.09.21.
//

import Foundation
import SwiftUI


class NetworkTest: ObservableObject {
    @Published var transceiver: MultipeerTransceiver
    private var configuration: MultipeerConfiguration?
    
    @Published var textMessage: String
    @Published var senderID: String
    
    init(peerName: String) {
        //action
        configuration = MultipeerConfiguration.init(serviceType: "drone", peerName: peerName, defaults: .standard, security: .default, invitation: .automatic)
        self.transceiver = MultipeerTransceiver(configuration: configuration!)
        
        textMessage = ""
        senderID = ""
    }
    
    func receive(){
        
        transceiver.resume()
        
        transceiver.receive(Message.self) { payload, sender in
        //print("Got my thing from \(sender.name)! \(payload)")
            self.textMessage = payload.message
            self.senderID = sender.name
        }
    }
    
    func send(){
        // Broadcast message to peers
        let payload = Message(message: "I am flying to drone 1!")
        transceiver.broadcast(payload)
    }
}

struct Message: Codable {
    var message: String
}

