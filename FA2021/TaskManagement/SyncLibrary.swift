//
//  SyncLibrary.swift
//  FA2021
//
//  Created by FA21 on 23.09.21.
//

// This is a mock class!!
// TODO: delete this file when real Library is available

import Foundation


class SyncLibrary {
        
    internal init(droneId: String) {
        self.droneId = droneId
    }
    
    
    let droneId: String
    
    func makeQuery() -> [Task] {
        let task = Task(id: "abcd", name: "DOIT", type: .FlyToTask, drone_id: nil )
        let taskList = [task]
        
        return taskList
    }
    
    static var taskRegistratons: [TaskRegistration] = []
    var functionToCall: (([TaskRegistration]) -> ())? = nil
    
    func registerForTask(taskId: String, function: @escaping ([TaskRegistration]) -> ()){
        functionToCall = function
        let tmst: TimeInterval = TimeInterval(Date().timeIntervalSince1970)
        let registration: TaskRegistration = TaskRegistration(taskId: taskId, droneId: droneId, timestamp: tmst, status: "hi")
        print("Drone " + droneId + " has timestamp: " + String(tmst))
        SyncLibrary.taskRegistratons.append(registration)
        return
    }
    
    func startTask(task: Task){
        print("Drone " + droneId + " is starting Task " + task.id)
    }
    
    func receivedClaim(){
        functionToCall!(SyncLibrary.taskRegistratons)
    }
    
    func abortTask(){
        print("Too Late :(. Drone " + droneId + " is aborting Task")
    }
    
}
