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
    
    func taskStateUpdate(droneId: String, taskId: String, state: TaskStatusUpdate.TaskState) {
        let taskMessage = TaskStatusUpdate(droneId: droneId, taskId: taskId, state: state)
        
        // Create the event.
        let event = try! AdvertiseEvent.with(object: taskMessage)

        // Publish the event by the communication manager.
        self.communicationManager.publishAdvertise(event)
    }
    
    func retrieveAvailableTasks(callback:((TaskD))) {
        let query = QueryEvent.with(objectTypes: [TaskControlResponse.objectType])
        
        self.communicationManager.publishQuery(query)
            .subscribe(onNext: { (resolveEvent) in
                
        })
        .disposed(by: self.disposeBag)
    }
}
