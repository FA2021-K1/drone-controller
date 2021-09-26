//
//  ContentView.swift
//  FA2021
//
//  Created by Kevin Huang on 19.09.21.
//

import SwiftUI
import DJISDK
import Combine

struct ContentView: View {
    
    @ObservedObject private var viewModel = ViewModel()
    
    var body: some View {
        Text("Drone Controls")
            .fontWeight(.semibold)
            .foregroundColor(Color.init(red: 0, green: 101, blue: 189))
        
        Divider()
        
        // logger
        ScrollView {
            VStack {
                ForEach(viewModel.logEntries, id: \.self) { logEntry in
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
                viewModel.flightControl.takeOff()
            } label: {
                Text("Takeoff").padding(20)
            }.contentShape(Rectangle())
            
            Button {
                viewModel.flightControl.flyNorth(meters: 5)
            } label: {
                Text("Fly 5m North").padding(20)
            }.contentShape(Rectangle())
            
            Button {
                viewModel.flightControl.land()
            } label: {
                Text("Land").padding(20)
            }.contentShape(Rectangle())
            
            
            Button {
                viewModel.flightControl.sampleTask()
            } label: {
                Text("Sample Task").padding(20)
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

extension ContentView {
    class ViewModel: ObservableObject {
        @Published
        var logEntries = [String]()

        let flightControl: FlightControlService
        
        private let log: Log
        private var subscription: AnyCancellable?
        
        init() {
            let log = Log()
            self.log = log
            self.flightControl = FlightControlService(log: log)
            
            subscription = log.$logEntries.sink(receiveValue: { entries in
                self.logEntries = entries
            })
        }
        
    }
}
