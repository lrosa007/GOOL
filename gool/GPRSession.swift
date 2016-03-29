//
//  GPRSession.swift
//  gool
//
//  Represents a translational displacement in two dimensions.
//  Units are not specified within the type
//
//  Created by Janet on 3/17/16.
//  Copyright © 2016 Dead Squad. All rights reserved.
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
    var operationMode: GPRMode
    var gprFrequency: UInt
    var graveLocations: [Displacement]
    var origin: CLLocation
    var startingTime: NSDate
    var gprReadings: [GPRTrace]
    var traceByLocation: [CLLocation: GPRTrace]
    var gprResults: [Double]
    
    var dataSource: GPRDataSource
    
    
    // MARK: Initialization
    init(origin: CLLocation, frequency: UInt, startTime: NSDate) {
        status = .Unstarted
        operationMode = .Standard
        self.origin = origin
        gprFrequency = frequency
        startingTime = NSDate()
        
        graveLocations = [Displacement]()
        gprReadings = [GPRTrace]()
        traceByLocation = [CLLocation: GPRTrace]()
        gprResults = [Double]()
        //TODO: proper assignment of dataSource
        dataSource = NetworkGPRDevice()
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
    
    func writeToFile(dest: GPRSessionOutput) {
        dest.writeSession(self)
    }
    
    private func readGprData(inout buf: [UInt8]) -> Int {
        if(!dataSource.dataStream.hasBytesAvailable) {
            return 0
        }
        
        return dataSource.dataStream.read(&buf, maxLength: buf.capacity)
    }
    
    // other version of function seems better
    private func readGprData(nBytes: Int) -> [UInt8] {
        var buffer = [UInt8](count: nBytes, repeatedValue: 0)
        dataSource.dataStream.read(&buffer, maxLength: nBytes)
        return buffer
    }
    
    private func filterGprData(raw: [UInt8]) -> [UInt8] {
        return DSP.filter(raw, mode: operationMode)
    }
    
    private func scoreGprData(data: [UInt8], displacement: Displacement) -> Double {
        return DataAnalyzer.analyze(data, mode: operationMode)
    }
}