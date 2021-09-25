//
//  Coordinate.swift
//  FA2021
//
//  Created by Gabriel Dengler on 25.09.21.
//

import Foundation

class Coordinate {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    
    init(latitude: Double, longitude: Double, altitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
    }
}
