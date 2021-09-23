//
//  DroneController.swift
//  iDroneControl
//
//  Created by FA21 on 22.09.21.
//
import CoatySwift
import Foundation
import RxSwift

/// A Coaty controller that invokes remote operations to control lights.
class DroneController: Controller {
    
    private let droneTable = TaskTable()
    
    override func onInit() {
        try! self.communicationManager
        .observeAdvertise(withObjectType: "idrone.sync.tasktable")
        .subscribe(onNext: { (advertiseEvent) in
            let otherTable = (advertiseEvent.data.object as! TaskTableMessage).table
            self.droneTable.updateTable(otherTable: otherTable)
        })
        .disposed(by: self.disposeBag)
        
        
        // Start RxSwift timer to publish the TaskTable every 5 seconds.
        _ = Observable
             .timer(RxTimeInterval.seconds(0),
                    period: RxTimeInterval.seconds(5),
                    scheduler: MainScheduler.instance)
            .subscribe(onNext: { (i: Int) in
                self.publishTaskDictionary()
             })
            .disposed(by: self.disposeBag)
    }
    
    func publishTaskDictionary() {
        let taskTableMessage = TaskTableMessage(droneTable)
        
        // Create the event.
        let event = try! AdvertiseEvent.with(object: taskTableMessage)

        // Publish the event by the communication manager.
        self.communicationManager.publishAdvertise(event)
    }
    
    func changeTaskState(taskId: String, droneId: String, timestamp: TimeInterval = Date().timeIntervalSinceReferenceDate, state: TaskTable.TaskState){
        droneTable.table[taskId] = TaskTable.DroneClaim(droneId: droneId, timestamp: timestamp, state: state)
    }
}
