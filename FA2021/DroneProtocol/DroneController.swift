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
    private var droneTableSync: Sync<TaskTable>?
    
    override func onInit() {
        droneTableSync = Sync<TaskTable>(controller: self, initialValue: TaskTable(), mergeFunction: { local, other in
            local.updateTable(otherTable: other)
        })
    }
    
    func claimTask(taskId: String, droneId: String){
        droneTableSync?.localInstance.changeTaskState(taskId: taskId, droneId: droneId, state: TaskTable.TaskState.claimed)
    }
}
