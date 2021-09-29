import Foundation
import RxSwift
class FirstComeFirstServe: TaskManager {
    var taskContext: TaskContext
    var api: CoatyAPI
    var droneId: String
    var currentTasksId: Set<String>
    var finishedTasksId: Set<String>
    var waitBeforeStarting: Bool

    init(api: CoatyAPI, droneId: String, taskContext: TaskContext, waitBeforeStarting: Bool) {
        self.droneId = droneId
        self.api = api
        self.taskContext = taskContext
        api.start()
        currentTasksId = []
        finishedTasksId = []
        self.waitBeforeStarting = waitBeforeStarting
        
        /**
         updateTaskTable everytime a new TaskList was received (server sends TaskList every 10 secconds or so)
         */
        ReactTypeUtil<[Task]>.subAll( dispose: api.droneController?.disposeBag, observable: api.allTasksObservable){
            tasks in api.droneController?.getDroneTableSync()?.updateData({ old in old.updateTaskTable(activeTaskSet: Set(tasks))})
        }
        
        /**
         check if this drone is still responsible for all currentTasksId everytime a new TaskTable was received
         */
        ReactTypeUtil<TaskTable>.subAll(dispose: api.droneController?.disposeBag, observable: api.droneController?.getDroneTableSync()?.getDataObservable()) {
            table in self.checkResponsibilityForTask(taskTable: table)
        }
    }
    
    func scanForTask(){
        // TODO: Test this method
        api.droneController?.getDroneTableSync()?.getDataObservable()
            .observeOn(MainScheduler.asyncInstance)
            .skipWhile({ table in
                table.table.allSatisfy { entry in
                    entry.value.state != TaskTable.TaskState.available
                }
            })
            .take(1)
            .subscribe(onNext: { table in
                if (!self.currentTasksId.isEmpty){
                    return
                }
                
                let unfinishedTaskIds = self.getUnfinishedTasksId()
                if !unfinishedTaskIds.isEmpty {
                    self.claimTask(taskId: unfinishedTaskIds[0])
                }
            })
            .disposed(by: api.droneController!.disposeBag)
    }
    
    
    /**
     looks at current TaskTable
     @return List of tasks that are available
     */
    func getUnfinishedTasksId() -> [String] {
        return getTable().filter {$0.value.state == TaskTable.TaskState.available}.map {$0.key}
    }
    
    func getTable() -> [String: TaskTable.DroneClaim] {
        return api.droneController?.getDroneTableSync()?.value.table ?? [:]
    }
    
    
    func claimTask(taskId: String) {
        
        Logger.getInstance().add(message: "Claim task, task_id: \(taskId)")
        
            self.currentTasksId.insert(taskId)
            self.api.droneController?.claimTask(taskId: taskId, droneId: self.droneId)

        // TODO: call drone team api to start task
        let taskSet = api.droneController?.getDroneTableSync()?.value.taskSet
        let taskClaimed = taskSet?.filter({
            task in
            task.id == taskId
        }).first
        let steps = taskClaimed?.getTerminalTasksList()
//        taskContext.add(steps: steps)
//        taskContext.startTask()
        
        if(waitBeforeStarting){
            // wait 5 seconds in order to prevent drones from starting simultaniously
            let seconds = 5.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                if (!self.currentTasksId.isEmpty){
                    self.taskContext.runSampleTask()
                }else{
                    Logger.getInstance().add(message: "don't start task \(taskId) because too late")
                }
            }
        }else {
            self.taskContext.runSampleTask()
        }
    }
    
    func checkResponsibilityForTask(taskTable: TaskTable){
        for taskId in currentTasksId {
            if let tableResult: TaskTable.DroneClaim = taskTable.table[taskId] {
                if (tableResult.state == .available || tableResult.droneId == droneId) {
                    Logger.getInstance().add(message: "keep task: " + taskId)
                    return
                }
                
                Logger.getInstance().add(message: "Giving up task \(taskId) to drone \(tableResult.droneId)")
            }
            
            // abort task and land
            currentTasksId.remove(taskId)
            taskContext.stopAndClearTask()
            taskContext.add(step: Landing())
            taskContext.startTask()
        }
    }
}


extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return prettyPrintedString
    }
}
