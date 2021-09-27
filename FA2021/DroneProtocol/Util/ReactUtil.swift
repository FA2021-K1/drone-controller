//
//  ReactUtil.swift
//  FA2021
//
//  Created by FA21 on 27.09.21.
//

import RxSwift
import CoatySwift
import Foundation

final class ReactUtil{
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
}
