//
//  ReactUtil.swift
//  FA2021
//
//  Created by FA21 on 27.09.21.
//

import RxSwift
import CoatySwift
import Foundation
import UIKit

final class ReactUtil {
    static func infiniteTimer(interval: Int = 5, timerTask: @escaping ((Int) -> Void)) {
        _ = Observable
             .timer(RxTimeInterval.seconds(0),
                    period: RxTimeInterval.seconds(interval),
                    scheduler: MainScheduler.instance)
            .subscribe(onNext: { (i: Int) in
                timerTask(i)
             })
        // No need to dispose here as the timer runs infinitely
    }
    
    static func advertise(comManager: CommunicationManager?, object: CoatyObject){
        // Create the event.
        let event = try! AdvertiseEvent.with(object: object)

        // Publish the event by the communication manager.
        comManager?.publishAdvertise(event)
    }
}

final class ReactTypeUtil<T> {
    static func subAll(dispose: DisposeBag?, observable: Observable<T>?, onNext: @escaping ((T) -> Void)){
        // Prevent memory leaks
        guard let disposeBag = dispose else {
            print("Could not subscribe to observable as the given DisposeBag was nil.")
            return
        }
        
        observable?.subscribe(onNext: { t in
            onNext(t)
        })
        .disposed(by: disposeBag)
    }
    
    static func observeAdvertise(controller: Controller?, objectType: String, onNext: @escaping ((T) -> Void)) {
        // Prevent memory leaks
        guard let control = controller else {
            print("Could not observe advertisements as the given Controller was nil.")
            return
        }
        
        try! control.communicationManager
        .observeAdvertise(withObjectType: objectType)
        .filter({ event in event.data.object is T })
        .subscribe(onNext: { (advertiseEvent) in
            let eventMessage = advertiseEvent.data.object as! T
            onNext(eventMessage)
        }).disposed(by: control.disposeBag)
    }
}
