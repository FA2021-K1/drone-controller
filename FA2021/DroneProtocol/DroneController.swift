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
    
    let droneTable = TaskTable()
    
    override func onInit() {
        try! self.communicationManager
        .observeAdvertise(withObjectType: "idrone.sync.tasktable")
        .subscribe(onNext: { (advertiseEvent) in
            let otherTable = advertiseEvent.data.object as! TaskTable

            self.droneTable.updateTable(otherTable: otherTable)
        })
        .disposed(by: self.disposeBag)
    }
    
    func publishTaskDictionary(table: TaskTable) {
        let taskTableMessage = TaskTableMessage(table)
        
        // Create the event.
        let event = try! AdvertiseEvent.with(object: taskTableMessage)

        // Publish the event by the communication manager.
        self.communicationManager.publishAdvertise(event)
    }
}
