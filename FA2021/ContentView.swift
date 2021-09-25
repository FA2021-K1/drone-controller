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
    @StateObject var network = NetworkTest(peerName: UIDevice.current.name)
    
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
                network.receive()
            } label: {
                Text("Connect to Network").padding(20)
            }.contentShape(Rectangle())
            
            
            Button {
                network.send()
            } label: {
                Text("Send message").padding(20)
            }.contentShape(Rectangle())
            
            Text(network.dronesPrint())
            
            Text(network.messagePrint())
            
            Text(network.coordsPrint())
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
