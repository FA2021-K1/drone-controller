//
//  FA2021Tests.swift
//  FA2021Tests
//
//  Created by Kevin Huang on 19.09.21.
//

import XCTest
@testable import FA2021


class FA2021Tests: XCTestCase {
    
    func testFCFS(){
        
        let group = DispatchGroup()
        
        for i in 0...1 {
            group.enter()
            
            DispatchQueue.global().async {
                let tm: TaskManager = FirstComeFirstServe(droneId: "d" + String(i))
                tm.scanForTask()
                
                
                let sleepVal = Int.random(in: 10..<1000)
                usleep(useconds_t(sleepVal))

                
                tm.syncLib.receivedClaim()
                
                
                group.leave()
            }
        }
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
