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
            
            DispatchQueue.main.async {
                self.subscription = log.$logEntries.sink(receiveValue: { entries in
                    self.logEntries = entries
                })
            }
        }
        
        func startTaskAssignmentThread(){
            /**
             start new Thread for TaskAssignment
             */
            DispatchQueue.global().async {
                /*
                 Potentialy the same iPhone could control different drones, meaning that the uuid of the iPhone might not always refer to the same drone.
                 In our use case, each drone is assigned to one iPhone, so we can assume that the iPhones to not differ.
                 */
                
                let coatyAPI: CoatyAPI = CoatyAPI()
                let firstComeFirstServe: TaskManager = FirstComeFirstServe(api: coatyAPI, droneId: UIDevice.current.identifierForVendor!.uuidString, taskContext: self.flightControl.taskContext)
                
                // starts timer to send data in init()
                let _: Telemetry = Telemetry(api: coatyAPI, taskmanager: firstComeFirstServe)
                
                
                firstComeFirstServe.scanForTask()
            }
        }
    }
}
