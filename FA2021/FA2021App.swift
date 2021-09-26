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
                    // TODO: how to get droneId
                    let firstComeFirstServe: TaskManager = FirstComeFirstServe(droneId: "placeholder")
                    firstComeFirstServe.scanForTask()
                }
            }
        }
    }
}
