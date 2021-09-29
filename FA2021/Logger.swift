//
//  Logger.swift
//  FA2021
//
//  Created by FA21 on 29.09.21.
//

import Foundation

final class Logger{
    private static let instance = Log()
    
    public static func getInstance() -> Log {
        return instance
    }
}
