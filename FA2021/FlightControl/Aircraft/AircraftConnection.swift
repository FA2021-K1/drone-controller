//
//  AircraftConnection.swift
//  FA2021
//
//  Created by FA21 on 29.09.21.
//

import Foundation
import DJISDK

final class AircraftConnection: NSObject {
    let onConnected: () -> Void
    
    init(onConnected: @escaping () -> Void) {
        self.onConnected = onConnected
        super.init()
        registerApp()
        connectToProduct()
    }
    
    private func registerApp() {
        DJISDKManager.registerApp(with: self)
    }
    
    /**
     https://github.com/dji-sdk/Mobile-SDK-iOS/blob/master/Sample%20Code/SwiftSampleCode/DJISDKSwiftDemo/StartupViewController.swift#L30
     */
    private func connectToProduct() {
        guard let connectedKey = DJIProductKey(param: DJIParamConnection) else {
            NSLog("Error creating the connectedKey")
            return;
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            DJISDKManager.keyManager()?.startListeningForChanges(on: connectedKey, withListener: self, andUpdate: { (oldValue: DJIKeyedValue?, newValue : DJIKeyedValue?) in
                if newValue != nil {
                    if newValue!.boolValue {
                        // At this point, a product is connected so we can show it.
                        
                        // UI goes on MT.
                        DispatchQueue.main.async {
                            self.productConnected(DJISDKManager.product())
                        }
                    }
                }
            })
            DJISDKManager.keyManager()?.getValueFor(connectedKey, withCompletion: { (value:DJIKeyedValue?, error:Error?) in
                if let unwrappedValue = value {
                    if unwrappedValue.boolValue {
                        // UI goes on MT.
                        DispatchQueue.main.async {
                            self.productConnected(DJISDKManager.product())
                        }
                    }
                }
            })
        }
    }
}

extension AircraftConnection: DJISDKManagerDelegate {
    /**
     https://developer.dji.com/mobile-sdk/documentation/ios-tutorials/ActivationAndBinding.html#introduction
     */
    func appRegisteredWithError(_ error: Error?) {
        Logger.getInstance().add(message: error == nil ? "SDK registered successfully" : "SDK registered with Error: \(error!.localizedDescription)")
        
        if error == nil {
            Logger.getInstance().add(message: "Start connection to product")
            DJISDKManager.startConnectionToProduct()
        }
    }
    
    /**
     https://github.com/DJI-Mobile-SDK-Tutorials/iOS-ImportAndActivateSDKInXcode-Swift/blob/master/ImportSDKDemo/ViewController.swift#L29
     */
    func productConnected(_ product: DJIBaseProduct?) {
        Logger.getInstance().add(message: "Product connected: \(product?.debugDescription ?? "No product")")
        self.onConnected()
    }
    
    func productChanged(_ product: DJIBaseProduct?) {
        Logger.getInstance().add(message: "Product changed: \(product?.debugDescription ?? "No product")")
    }
    
    func productDisconnected() {
        Logger.getInstance().add(message: "Product disconnected")
    }
    
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        
    }
}
