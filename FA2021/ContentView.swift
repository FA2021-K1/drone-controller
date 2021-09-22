//
//  ContentView.swift
//  FA2021
//
//  Created by Kevin Huang on 19.09.21.
//

import SwiftUI
import DJISDK

struct ContentView: View {
    @StateObject
    var missionScheduler = MissionScheduler()
    
    var body: some View {
        // app crashes if no product is connected
        // let connectedProduct = DJISDKManager.product()
        
        // Text("Connected aircraft:" + (connectedProduct?.model ?? "Not connected"))
        ScrollView {
            VStack {
                ForEach(missionScheduler.log.logEntries, id: \.self) { logEntry in
                    Text(logEntry)
                        .padding()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        
        List {
            Button {
                missionScheduler.takeOff()
            } label: {
                Text("Takeoff").padding(20)
            }.contentShape(Rectangle())
            
            Button {
                missionScheduler.executeMission()
            } label: {
                Text("Start Mission").padding(20)
            }.contentShape(Rectangle())
            
            
            Button {
                missionScheduler.land()
            } label: {
                Text("Land").padding(20)
            }.contentShape(Rectangle())
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
