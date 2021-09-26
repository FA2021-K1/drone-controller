//
//  Idle.swift
//  FA2021
//
//  Created by Kevin Huang on 26.09.21.
//

import Foundation

class Idling: Step {
    
    private var duration: Double
    
    let description: String = "Idling Step"
    internal var done: Bool = false
    
    init(duration: Double) {
        self.duration = duration
    }
    
    func execute(missionScheduler: MissionScheduler) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
            self.done = true
        })
    }
    
}

class TakingOff: Step {
    private var altitude: Double
    
    let description: String = "Taking Off Step"
    internal var done: Bool = false
    
    init(altitude: Double) {
        self.altitude = altitude
    }
    
    func execute(missionScheduler: MissionScheduler) {
        DispatchQueue.main.async {
            missionScheduler.takeOff()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.done = true
        })
    }
}


class Landing: Step {
    let description: String = "Landing Step"
    internal var done: Bool = false
    
    func execute(missionScheduler: MissionScheduler) {
        DispatchQueue.main.async {
            missionScheduler.land()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.done = true
        })
    }
}
