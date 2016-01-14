//
//  GPRSession.swift
//  ghoul
//
//  Created by Student on 1/14/16.
//  Copyright (c) 2016 deadsquad. All rights reserved.
//

import Foundation
import CoreLocation

class GPRSession {
    enum GPRSessionStatus {
        case Unstarted
        case Active
        case Finished
        case Interrupted
        case Error
    }
    
    // MARK: Properties
    var status: GPRSessionStatus
    var gprFrequency: UInt
    var graveLocations: [Displacement]
    //operationMode: some enum
    var origin: CLLocation
    var startingTime: NSDate
    var gprReadings: [Displacement: Double]
    
    
    // MARK: Initialization
    init(origin: CLLocation, frequency: UInt, startTime: NSDate) {
        status = .Unstarted
        self.origin = origin
        gprFrequency = frequency
        startingTime = NSDate()
        
        graveLocations = [Displacement]()
        gprReadings = [Displacement: Double]()
    }
    
    convenience init(origin: CLLocation, frequency: UInt) {
        self.init(origin: origin, frequency: frequency, startTime: NSDate())
    }
    
    
    // MARK: Functions
    
    func start() -> Bool {
        if(status == .Unstarted) {
            status = .Active
            return true
        }
        
        return false
    }
    
    func stop() -> Bool {
        if(status == .Active) {
            status = .Finished
            return true
        }
        
        return false
    }

    // following depend on as-yet undefined types
    
//    func writeToFile(dest: GPRSessionOutput) {
//        
//    }
//    
//    private func readGprData(bytes: Int) -> [Byte] {
//        
//    }
//    
//    private func filterGprData(raw: [Byte]) -> [Byte] {
//        
//    }
//    
//    private func scoreGprData(data: [Byte], displacement: Displacement) -> Double {
//        
//    }
}