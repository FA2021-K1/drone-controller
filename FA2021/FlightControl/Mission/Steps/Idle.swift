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

class FlyTo: Step {
    func execute(missionScheduler: MissionScheduler) {
        DispatchQueue.main.async {
            missionScheduler.flyTo(latitude: self.latitudes, longitude: self.longitudes, altitude: self.altitudes, wait: self.waits) {
                self.done = true
            }
        }
    }
    
    let description: String = "Fly To Step"
    internal var done: Bool = false
    let latitudes: [Double]
    let longitudes: [Double]
    let altitudes: [Float]
    let waits: [Int]
    
    init(latitudes: [Double], longitudes: [Double], altitudes: [Float], waits: [Int]) {
        self.latitudes = latitudes
        self.longitudes = longitudes
        self.altitudes = altitudes
        self.waits = waits
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 15/*6*/, execute: {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 30/*5*/, execute: {
            self.done = true
        })
    }
}
