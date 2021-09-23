//
//  MissionController.swift
//  iDroneControl
//
//  Created by FA21 on 22.09.21.
//

import CoatySwift
import Foundation
import RxSwift

/// A Coaty controller that invokes remote operations to control lights.
class MissionController: Controller {
    
    override func onInit() {
        try! self.communicationManager
            .observeQuery()
            .filter({ query in
                let types = query.data.objectTypes ?? []
                return types.contains(TaskControlResponse.objectType)
            })
            .subscribe({ query in
                // TODO: Get tasks
                let response = TaskControlResponse()
            
            })
            .disposed(by: self.disposeBag)
    }
    
    func publishMissionTimeout(retry: Bool = true){
        
    }
    
    func postNewMission(){
        
    }
    
    func observeResultDataEvent(){
        
    }
}
