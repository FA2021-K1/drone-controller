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
    @State private var showingInvalidPortAlert = false
    @State private var coatyStarted = false
    @State private var ip: String = ""
    @State private var portString: String = ""
    let defaults = UserDefaults.standard
    
    var body: some View {
        
        
        Text("Drone Controls")
            .fontWeight(.semibold)
            .foregroundColor(Color.init(red: 0, green: 101, blue: 189))
            .font(.title)
        
        if coatyStarted {
            HStack {
                Text("IP: \(ip)").font(.subheadline)
                Text("Port: \(portString)").font(.subheadline)
            }
        }
        
        Divider()
        
        if !coatyStarted {
            VStack {
                VStack {
                    let width: CGFloat = 50
                    HStack {
                        Text("IP:").frame(width: width, alignment: .center)
                        TextField("123.456.789.123", text: $ip)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                    HStack {
                        Text("Port:").frame(width: width, alignment: .center)
                        TextField("1234", text: $portString)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                }
                Button {
                    if !coatyStarted {
                        if let port: UInt16 = UInt16(portString) {
                        withAnimation {
                            coatyStarted.toggle()
                        }
                        
                        defaults.set(ip, forKey: "coaty_ip")
                        defaults.set(String(port), forKey: "coaty_port")
                        
                        /*
                         Potentialy the same iPhone could control different drones, meaning that the uuid of the iPhone might not always refer to the same drone.
                         In our use case, each drone is assigned to one iPhone, so we can assume that the iPhones to not differ.
                         */
                        
                        let coatyAPI: CoatyAPI = CoatyAPI(host_ip: ip, port: port)
                        let firstComeFirstServe: TaskManager = FirstComeFirstServe(api: coatyAPI, droneId: UIDevice.current.identifierForVendor!.uuidString, taskContext: viewModel.flightControl.taskContext, waitBeforeStarting: true)

                        // starts timer to send data in init()
                        let _: Telemetry = Telemetry(api: coatyAPI, taskmanager: firstComeFirstServe)


                        firstComeFirstServe.scanForTask()
                        
                    } else {
                        showingInvalidPortAlert = true
                    }
                        
                    }
                    
                } label: {
                    Text("Connect to Coaty").padding(20)
                }.contentShape(Rectangle())
                    .alert(isPresented: $showingInvalidPortAlert) {
                        Alert(title: Text("Error"), message: Text("Port needs to be an integer!"))
                    }
            }
            Divider()
            
        }
        
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
    
    init() {
        _ip = State(initialValue: defaults.string(forKey: "coaty_ip") ?? "")
        _portString = State(initialValue: defaults.string(forKey: "coaty_port") ?? "")
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
        
        private var subscription: AnyCancellable?
        
        init() {
            self.subscription = Logger.getInstance().$logEntries.sink(receiveValue: { entries in
                self.logEntries = entries
            })
        }
    }
}
