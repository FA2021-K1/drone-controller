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
    
    private let timestamp = Timestamp()
    
    func add(message: String) {
        logEntries.insert("[\(timestamp.currentTimestamp())] \(message)", at: 0)
        if logEntries.count > 100 {
            logEntries.removeLast()
        }
        
        self.objectWillChange.send()
    }
    
    func entries() -> [String] {
        return logEntries
    }
    
    func asString() -> String {
        return logEntries.joined(separator: "\n")
    }
}

// https://stackoverflow.com/a/51198997
class Timestamp {
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    func currentTimestamp() -> String {
        dateFormatter.string(from: Date())
    }
}

