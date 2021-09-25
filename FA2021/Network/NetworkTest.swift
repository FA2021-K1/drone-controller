//
//  NetworkTest.swift
//  FA2021
//
//  Created by Ferienakademie on 22.09.21.
//

import Foundation
import SwiftUI
import DJISDK

class NetworkTest: ObservableObject {
    @Published var transceiver: MultipeerTransceiver
    private var configuration: MultipeerConfiguration?
    
    @Published var textMessage: String
    @Published var senderID: String
    @Published var coords: Coordinates?
    
    init(peerName: String) {
        //action
        configuration = MultipeerConfiguration.init(serviceType: "drone", peerName: peerName, defaults: .standard, security: .default, invitation: .automatic)
        self.transceiver = MultipeerTransceiver(configuration: configuration!)
        
        textMessage = ""
        senderID = ""
    }
    
    func receive(){
        
        transceiver.resume()
        
        transceiver.receive(Message.self) { [self] payload, sender in
        //print("Got my thing from \(sender.name)! \(payload)")
            self.textMessage = payload.message
            self.senderID = sender.name
            
            if payload.coords != nil{
                self.coords = payload.coords!
            }
        }
    }
    
    func send(){
        // Broadcast message to peers
        let payload = Message(message: "Fly to buoy 1!", coords: Coordinates(coordsArray: [10.07, 5.23]))
        transceiver.broadcast(payload)
    }
    
    func coordsPrint() -> String {
        var string = ""
        if self.coords != nil {
            string = "Coords: "
            for element in self.coords!.coordsArray {
                string += "\(element) "
            }
        }
        return string
    }
    
    func messagePrint() -> String {
        return "\(self.senderID): \(self.textMessage)"
    }
    func dronesPrint() -> String {
        return "Available drones: \(self.transceiver.availablePeers.count+1)"
    }
}

struct Message: Codable {
    var message: String
    var coords: Coordinates?
    
}


struct Coordinates: Codable {
    var coordsArray: [Double]
}

