//
//  FA2021App.swift
//  FA2021
//
//  Created by Kevin Huang on 19.09.21.
//

import SwiftUI

@main
struct FA2021App: App {
    var body: some Scene {
        WindowGroup {
            ContentView().onAppear {
                DispatchQueue.global().async {
                    /*
                     Potentialy the same iPhone could control different drones, meaning that the uuid of the iPhone might not always refer to the same drone.
                     In our use case, each drone is assigned to one iPhone, so we can assume that the iPhones to not differ.
                    */
                    
                    let coatyAPI: CoatyAPI = CoatyAPI()
                    let firstComeFirstServe: TaskManager = FirstComeFirstServe(api: coatyAPI, droneId: UIDevice.current.identifierForVendor!.uuidString)
                    
                    // starts timer to send data in init()
                    let _: Telemetry = Telemetry(api: coatyAPI, taskmanager: firstComeFirstServe)
                    
                    
                    firstComeFirstServe.scanForTask()
                }
            }
        }
    }
}
