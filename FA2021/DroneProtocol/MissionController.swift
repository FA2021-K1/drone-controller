//
//  MissionController.swift
//  iDroneControl
//
//  Created by FA21 on 22.09.21.
//

import CoatySwift
import Foundation

/// A Coaty controller that invokes remote operations to control lights.
class MissionController: Controller {
    private var droneTableSync: Sync<TaskTable>?
    
    override func onInit() {
        droneTableSync = Sync<TaskTable>(controller: self, initialValue: TaskTable(), mergeFunction: { local, other in
            local.updateTable(otherTable: other)
        })
    }
    
    func postNewMission(taskId: String){
        droneTableSync?.setData(newData: droneTableSync!.value.changeTaskState(taskId: taskId, droneId: "", state: TaskTable.TaskState.available))
    }
    
    func dismissMission(taskId: String){
        droneTableSync?.setData(newData: droneTableSync!.value.changeTaskState(taskId: taskId, droneId: "", state: TaskTable.TaskState.finished))
    }
}
