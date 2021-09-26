//
//  Log.swift
//  FA2021
//
//  Created by Kevin Huang on 22.09.21.
//

import Foundation

class Log: ObservableObject {
    @Published
    var logEntries = [String]()
    
    func add(message: String) {
        logEntries.insert(message, at: 0)
        self.objectWillChange.send()
    }
    
    func entries() -> [String] {
        return logEntries
    }
    
    func asString() -> String {
        return logEntries.joined(separator: "\n")
    }
}
