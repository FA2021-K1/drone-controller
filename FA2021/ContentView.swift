//
//  ContentView.swift
//  FA2021
//
//  Created by Kevin Huang on 19.09.21.
//

import SwiftUI
import UIKit
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
                        if viewModel.aircraft.connectedAircraft == nil {
                            Logger.getInstance().add(message: "Aircraft is unavailable, abort! Please try again later.")
                            return
                        }
                        
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
                            let firstComeFirstServe: TaskManager = FirstComeFirstServe(api: coatyAPI, droneId: UIDevice.current.identifierForVendor!.uuidString,
                                                                                       waitBeforeStarting: true,
                                                                                       
                                                                                       aircraft: viewModel.aircraft)
                            // starts timer to send data in init()
                            let _: MissionControlTelemetry = MissionControlTelemetry(aircraft: viewModel.aircraft, api: coatyAPI, taskmanager: firstComeFirstServe)
                            
                            
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
                let point1 = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(46.74685695584437, 11.358539437386618))
                let point2 = DJIWaypoint(coordinate: CLLocationCoordinate2DMake(46.74661592553349, 11.358415773941866))
                
                point1.altitude = 10
                point1.add(DJIWaypointAction.init(actionType: DJIWaypointActionType.stay, param: 1000))
                point2.altitude = 20
                // Wait at point 2 for 6000 ms.
                point2.add(DJIWaypointAction.init(actionType: .stay, param: 6000))
                
                let mission = DJIMutableWaypointMission()
                mission.add(point1)
                mission.add(point2)
                viewModel.aircraft.initializeMission(mission: mission)
            } label: {
                Text("Takeoff").padding(20)
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
        
        let aircraft: Aircraft
        
        private var subscription: AnyCancellable?
        
        init() {
            UIApplication.shared.isIdleTimerDisabled = true
            self.aircraft = Aircraft() {
                
            }
            self.subscription = Logger.getInstance().$logEntries.sink(receiveValue: { entries in
                self.logEntries = entries
            })
        }
    }
}
