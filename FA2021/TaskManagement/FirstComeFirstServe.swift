import Foundation
import RxSwift
class FirstComeFirstServe: TaskManager {
    var taskContext: TaskContext
    var api: CoatyAPI
    var droneId: String
    var currentTasksId: Set<String>
    var finishedTasksId: Set<String>

    init(api: CoatyAPI, droneId: String, taskContext: TaskContext) {
        self.droneId = droneId
        self.api = api
        self.taskContext = taskContext
        api.start()
        currentTasksId = []
        finishedTasksId = []
        
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
                self.claimTask(taskId: unfinishedTaskIds[0])
                
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
        
        print("Claim task, task_id: \(taskId)")
        
            self.currentTasksId.insert(taskId)
            self.api.droneController?.claimTask(taskId: taskId, droneId: self.droneId)

        // TODO: call drone team api to start task
        let taskSet = api.droneController?.getDroneTableSync()?.value.taskSet
        let taskClaimed = taskSet?.filter({
            task in
            task.id == taskId
        }).first
        let tasks = taskClaimed?.getTerminalTasksList() ?? []
        
        var latitudes: [Double] = []//[46.74605780354491,46.74617979657177,46.74653357442833,46.74646037763764,46.74610660044984]
        var longitudes: [Double] = []//[11.358515723354026,11.358072872389046,11.358226424637898,11.358704885078991,11.358531301375377]
        var altitudes: [Float] = []//[10,10,10,10,10]
        var waits: [Int] = []//[0,0,10,0,0]
        
        for task: Task in tasks {
            if task is FlyTask {
                let flyTask = task as! FlyTask
                latitudes.append(flyTask.coordinate.latitude)
                longitudes.append(flyTask.coordinate.longitude)
                altitudes.append(Float(flyTask.coordinate.altitude))
                waits.append(0)
            } else if task is IdleTask {
                let idleTask = task as! IdleTask
                if let _: Int = waits.last {
                    waits[waits.endIndex-1] += Int(idleTask.delay)
                }
            }
        }
        
        taskContext.add(steps: [TakingOff(altitude: 10), FlyTo(latitudes: latitudes, longitudes: longitudes, altitudes: altitudes, waits: waits), Landing()])
        taskContext.startTask()
        taskContext.runSampleTask()
    }
    
    func checkResponsibilityForTask(taskTable: TaskTable){
        for taskId in currentTasksId {
            if let tableResult: TaskTable.DroneClaim = taskTable.table[taskId] {
                if (tableResult.state == .available || tableResult.droneId == droneId) {
                    print("keep task: " + taskId)
                    return
                }
                
                print("Giving up task \(taskId) to drone \(tableResult.droneId)")
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
