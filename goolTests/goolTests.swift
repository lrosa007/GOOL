//
//  goolTests.swift
//  goolTests
//
//  Created by Janet on 3/17/16.
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import XCTest
@testable import gool

class goolTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSmooth() {
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let original:[Float] = [1, 1, 1, 10, 10, 10, 1, 1, 1, 1]
        let smooth3:[Float] = [0, 1, 4, 7, 10, 7, 4, 1, 1, 0]
        let smoothed = DSP.smooth(original, width: 3)
        
        XCTAssert(smoothed.elementsEqual(smooth3))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
