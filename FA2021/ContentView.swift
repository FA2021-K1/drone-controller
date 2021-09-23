//
//  ContentView.swift
//  FA2021
//
//  Created by Kevin Huang on 19.09.21.
//

import SwiftUI
import DJISDK
import Network
import MultipeerConnectivity

struct ContentView: View {
    
    var missionControl = MissionScheduler()
    
    @StateObject var networkTest1 = NetworkTest(peerName: UIDevice.current.name)

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        List {
            Button {
                DJISDKManager.missionControl()?.scheduleElement(DJITakeOffAction())
                
                DJISDKManager.missionControl()?.startTimeline()
                
            } label: {
                Text("Takeoff").padding(20)
            }.contentShape(Rectangle())
            
            Button {
                guard let mission = missionControl.createDemoMission()
                else {
                    return
                }
                
                DJISDKManager.missionControl()?.scheduleElement(mission)
                
            } label: {
                Text("Start Mission").padding(20)
            }.contentShape(Rectangle())
            
            
            Button {
                DJISDKManager.missionControl()?.scheduleElement(DJILandAction())
                
                DJISDKManager.missionControl()?.startTimeline()
                
            } label: {
                Text("Land").padding(20)
            }.contentShape(Rectangle())
            
            
            Button {
                DJISDKManager.missionControl()?.unscheduleEverything()
                DJISDKManager.missionControl()?.scheduleElement(DJILandAction())
                
                DJISDKManager.missionControl()?.startTimeline()
                
            } label: {
                Text("Force Land").padding(20)
            }.contentShape(Rectangle())
            
            
            Button {
                networkTest1.receive()
            } label: {
                Text("Connect to Network").padding(20)
            }.contentShape(Rectangle())
            
            
            Button {
                networkTest1.send()
            } label: {
                Text("Send message").padding(20)
            }.contentShape(Rectangle())
            
            Text("Available drones: \(networkTest1.transceiver.availablePeers.count+1)").padding(20)
            Text("\(networkTest1.senderID): \(networkTest1.textMessage)").padding(20)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
