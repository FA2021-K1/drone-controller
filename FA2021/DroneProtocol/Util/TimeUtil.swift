//
//  TimeUtil.swift
//  iDroneControl
//
//  Created by FA21 on 22.09.21.
//
import Foundation

struct TimeUtil{
    static func getCurrentTime() -> TimeInterval {
        return Date().timeIntervalSinceReferenceDate
    }
}
