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
    let comManager: CommunicationManager
    let mergeFunction: (T, T) -> T
    
    init(initialValue: T, updateIntervalSeconds: Int = 5, mergeFunction: @escaping (T, T) -> T, comManager: CommunicationManager, disposeBag: DisposeBag) {
        precondition(updateIntervalSeconds > 0, "UpdateInterval needs to be positive.")
        
        localInstance = initialValue
        self.comManager = comManager
        self.mergeFunction = mergeFunction
        
        try! self.comManager
        .observeAdvertise(withObjectType: "idrone.sync.syncmessage")
        .subscribe(onNext: { (advertiseEvent) in
            if (advertiseEvent.data.object is SyncMessage<T>)
            {
                let eventMessage = advertiseEvent.data.object as! SyncMessage<T>
                self.localInstance = mergeFunction(self.localInstance, eventMessage.object)
            }
        })
        .disposed(by: disposeBag)
        
        
        // Start RxSwift timer to publish the TaskTable every 5 seconds.
        _ = Observable
             .timer(RxTimeInterval.seconds(0),
                    period: RxTimeInterval.seconds(5),
                    scheduler: MainScheduler.instance)
            .subscribe(onNext: { (i: Int) in
                self.publishTaskDictionary()
             })
            .disposed(by: disposeBag)
    }
    
    func publishTaskDictionary(){
        let syncMessage = SyncMessage(localInstance)
        
        // Create the event.
        let event = try! AdvertiseEvent.with(object: syncMessage)

        // Publish the event by the communication manager.
        self.comManager.publishAdvertise(event)
    }
    
    
}
