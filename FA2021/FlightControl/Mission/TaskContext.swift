//
//  TaskContext.swift
//  FA2021
//
//  Created by Kevin Huang on 26.09.21.
//

import Foundation

class TaskContext {
    private let missionScheduler: MissionScheduler
    private var currentStepIndex: Int = -1
    private var steps = [Step]()
    private var currentStep: Step? {
        get {
            if steps.isEmpty || currentStepIndex < 0 || currentStepIndex >= steps.endIndex {
                return nil
            }
            return steps[currentStepIndex]
        }
    }
    private let log: Log
    
    init(log: Log, aircraftController: AircraftController) {
        self.missionScheduler = MissionScheduler(log: log, droneController: aircraftController)
        self.log = log
    }
    
    func runSampleTask() {
        self.add(steps: [TakingOff(altitude: 5), Idling(duration: 8), Landing()])
        self.startTask()
    }
    
    /**
     Adds a step to a Task that should be executed by the Aircraft. The step is appended to the end.
     
     A step can be added even when a task has already started, but new steps are only executed if the task has not completed yet.
     */
    func add(step: Step) {
        self.steps.append(step)
    }
    
    /**
     Adds multiple steps to a Task that should be executed by the Aircraft. The steps are appended to the end.
     
     A step can be added even when a task has already started, but new steps are only executed if the task has not completed yet.
     */
    func add(steps: [Step]) {
        self.steps.append(contentsOf: steps)
    }
    
    /**
     Sets the pointer to the first step of a Task and begins the execution of the task.
     */
    func startTask() {
        log.add(message: "Starting Task")
        reset()
        executeNextStep()
    }
    
    func stopTask() {
        missionScheduler.stopMissionIfRunning()
        reset()
    }
    
    func stopAndClearTask() {
        stopTask()
        steps.removeAll()
    }
    
    /**
     Resets the step pointer and marks all steps as "not done". Any steps that are currently executed will NOT be cancelled.
     Call stopTask() instead.
     */
    private func reset() {
        log.add(message: "Resetting Task Steps")
        
        currentStepIndex = -1
        for var step in steps {
            step.done = false
        }
    }
    
    private func executeNextStep() {
        log.add(message: "Incrementing step counter")
        currentStepIndex += 1
        
        guard let currentStep = currentStep
        else {
            log.add(message: "No step to execute")
            return
        }
        
        log.add(message: currentStep.description)
        currentStep.execute(missionScheduler: missionScheduler)
        checkDone()
    }
    
    private func checkDone() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            if self.currentStep == nil {
                return
            }
            
            if self.currentStep!.done {
                self.executeNextStep()
            }
            self.checkDone()
        })
    }
}