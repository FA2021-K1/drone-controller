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
    private var altitude: Float
    
    let description: String = "Taking Off Step"
    internal var done: Bool = false
    
    init(altitude: Float) {
        self.altitude = altitude
    }
    
    func execute(missionScheduler: MissionScheduler) {
        DispatchQueue.main.async {
            missionScheduler.takeOff(altitude: self.altitude) {
                self.done = true
            }
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 15/*6*/, execute: {
//            self.done = true
//        })
    }
}


class Landing: Step {
    let description: String = "Landing Step"
    internal var done: Bool = false
    
    func execute(missionScheduler: MissionScheduler) {
        DispatchQueue.main.async {
            missionScheduler.land()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 30/*5*/, execute: {
            self.done = true
        })
    }
}
