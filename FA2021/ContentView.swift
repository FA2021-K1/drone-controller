//
//  ContentView.swift
//  FA2021
//
//  Created by Kevin Huang on 19.09.21.
//

import SwiftUI
import DJISDK

struct ContentView: View {
    var missionControl = MissionScheduler()
    
    var body: some View {
        
        // app crashes if no product is connected
        let connectedProduct = DJISDKManager.product()!
        
        Text("Connected aircraft:" + (connectedProduct.model!))
        
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
