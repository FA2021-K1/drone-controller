//
//  SyncAPI.swift
//  FA2021
//
//  Created by FA21 on 25.09.21.
//

import CoatySwift
import Foundation
import RxSwift
import RxCocoa

class Sync<T: Codable & Equatable>{
    let controller: Controller
    let mergeFunction: (T, T) -> T
    private var dataObservable: BehaviorRelay<T>
    
    var value: T {
        get{
            return self.dataObservable.value
        }
    }
    
    init(controller: Controller, initialValue: T, updateIntervalSeconds: Int = 5, mergeFunction: @escaping (T, T) -> T) {
        precondition(updateIntervalSeconds > 0, "UpdateInterval needs to be positive.")
        
        self.controller = controller
        self.mergeFunction = mergeFunction
        
        self.dataObservable = BehaviorRelay<T>(value: initialValue)
        
        ReactTypeUtil<SyncMessage<T>>.observeAdvertise(controller: self.controller, objectType: "idrone.sync.syncmessage") { eventMessage in
            self.updateData { old in mergeFunction(old, eventMessage.object)}
        }
        
        // Start RxSwift timer to publish the TaskTable every 5 seconds.
        ReactUtil.infiniteTimer(interval: updateIntervalSeconds) { i in
            self.publishTaskDictionary()
        }
    }
    
    func updateData(_ updateFunction:((_ old: T) -> T)){
        let newData = updateFunction(self.dataObservable.value)
        setData(newData: newData)
    }
    
    func setData(newData: T){
        if newData != self.dataObservable.value {
            self.dataObservable.accept(newData)
        }
    }
    
    func getDataObservable() -> Observable<T>{
        return self.dataObservable.asObservable()
    }
    
    func publishTaskDictionary(){
        ReactUtil.advertise(comManager: self.controller.communicationManager, object: SyncMessage(self.dataObservable.value))
    }
}
