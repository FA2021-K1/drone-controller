//
//  CameraFeed.swift
//  FA2021
//
//  Created by Nathalie on 22.09.21.
//

import Foundation
import DJISDK

class CameraFeed : NSObject {

    let product = DJISDKManager.product()
    
    let cam : DJICamera
    let feeder : DJIVideoFeeder
    
    override init() {
        cam = (product?.camera)!
        feeder = (product?.videoFeeder)!
            
        super.init()
    }

    func streamVideo() {
        //feeder.primaryVideoFeed
    }
}


