//
//  Step.swift
//  FA2021
//
//  Created by Kevin Huang on 26.09.21.
//

import Foundation

protocol Step: CustomStringConvertible {
    var done: Bool { get set }
    
    func execute(missionScheduler: MissionScheduler)
}
