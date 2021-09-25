//
//  SyncAPI.swift
//  FA2021
//
//  Created by FA21 on 25.09.21.
//

import CoatySwift
import Foundation
import RxSwift

class Sync<T: Codable>{
    var localInstance: T
    let controller: Controller
    let mergeFunction: (T, T) -> T
    
    init(controller: Controller, initialValue: T, updateIntervalSeconds: Int = 5, mergeFunction: @escaping (T, T) -> T) {
        precondition(updateIntervalSeconds > 0, "UpdateInterval needs to be positive.")
        
        localInstance = initialValue
        self.controller = controller
        self.mergeFunction = mergeFunction
        
        try! self.controller.communicationManager
        .observeAdvertise(withObjectType: "idrone.sync.syncmessage")
        .subscribe(onNext: { (advertiseEvent) in
            if (advertiseEvent.data.object is SyncMessage<T>)
            {
                let eventMessage = advertiseEvent.data.object as! SyncMessage<T>
                self.localInstance = mergeFunction(self.localInstance, eventMessage.object)
            }
        }).disposed(by: controller.disposeBag)
        
        
        // Start RxSwift timer to publish the TaskTable every 5 seconds.
        _ = Observable
             .timer(RxTimeInterval.seconds(0),
                    period: RxTimeInterval.seconds(updateIntervalSeconds),
                    scheduler: MainScheduler.instance)
            .subscribe(onNext: { (i: Int) in
                self.publishTaskDictionary()
             })
            .disposed(by: controller.disposeBag)
    }
    
    func publishTaskDictionary(){
        let syncMessage = SyncMessage(localInstance)
        
        // Create the event.
        let event = try! AdvertiseEvent.with(object: syncMessage)

        // Publish the event by the communication manager.
        self.controller.communicationManager.publishAdvertise(event)
    }
    
    
}
