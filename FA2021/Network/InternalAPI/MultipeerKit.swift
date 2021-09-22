//
//  MultipeerKit.swift
//  FA2021
//
//  Created by Ferienakademie on 22.09.21.
//

import Foundation
import os.log

struct MultipeerKit {
    static let subsystemName = "codes.rambo.MultipeerKit"

    static func log(for type: AnyClass) -> OSLog {
        OSLog(subsystem: subsystemName, category: String(describing: type))
    }
}
