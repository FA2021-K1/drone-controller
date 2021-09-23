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
        Text("Drone Controls")
            .fontWeight(.semibold)
            .foregroundColor(Color.init(red: 0, green: 101, blue: 189))
        
        Divider()
        
        // logger
        ScrollView {
            VStack {
                ForEach(missionScheduler.log.logEntries, id: \.self) { logEntry in
                    Text(logEntry)
                        .padding()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        
        Divider()
        
        // steering
        List {
            Button {
                missionScheduler.takeOff()
            } label: {
                Text("Takeoff").padding(20)
            }.contentShape(Rectangle())
            
            Button {
                missionScheduler.flyDirection(direction: .north, meters: 5)
            } label: {
                Text("Fly 5m North").padding(20)
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
        
        Divider()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
