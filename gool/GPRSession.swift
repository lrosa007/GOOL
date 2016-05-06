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

class GPRSession: NSObject, NSStreamDelegate {
    enum GPRSessionStatus {
        case Unstarted
        case Active
        case Finished
        case Interrupted
        case Error
    }
    
    // MARK: Properties
    var status: GPRSessionStatus
    var settings: GPRSettings
    var gprFrequency: UInt
    var graveLocations: [CLLocation]
    var origin: CLLocation
    var startingTime: NSDate
    var gprReadings: [GPRTrace]
    var traceByLocation: [CLLocation: GPRTrace]
    var locationBySeqNo: [Int: CLLocation]
    var gprResults: [Int: Double] // seqNo -> score
    
    var dataSource: GPRDataSource?
    
    var seqNoQueue = [Int]()
    var mainDisplay: MapViewController?
    
    
    // MARK: Initialization
    init(origin: CLLocation, frequency: UInt, startTime: NSDate) {
        status = .Unstarted
        settings = GPRSettings()
        self.origin = origin
        gprFrequency = frequency
        startingTime = NSDate()
        
        graveLocations = [CLLocation]()
        gprReadings = [GPRTrace]()
        traceByLocation = [CLLocation: GPRTrace]()
        locationBySeqNo = [Int: CLLocation]()
        gprResults = [Int: Double]()
        //TODO: proper assignment of dataSource
        // this will be a GPR datafile source, unless we write a new constructor for that case
        //dataSource = NetworkGPRDevice()
    }
    
    convenience init(origin: CLLocation, frequency: UInt) {
        self.init(origin: origin, frequency: frequency, startTime: NSDate())
    }
    
    convenience init(device: GPRDataSource) {
        self.init(origin: CLLocation(), frequency: UInt(1e9), startTime: NSDate())
        dataSource = device
    }
    
//    convenience init(mock: MockDataSource) {
//        self.init(origin: CLLocation(), frequency: UInt(1e9), startTime: NSDate())
//        dataSource = mock
//        mock.inputStream.delegate = self
//        mock.outputStream.delegate = self
//    }
    
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
            case NSStreamEvent.HasBytesAvailable :
                if dataSource!.hasFullMessage() {
                    // process dataSource.getMessage()
                    if (dataSource!.getMessage() == "") {
                        let seqNo = dataSource!.runTrace()
                        seqNoQueue.insert(seqNo, atIndex: 0)
                    } else {
                        // handle trace data
                        var buffer = [UInt8]()
                        
                        var rawdata = [UInt8]()
                        
                        let iStream = dataSource!.dataStream
                        
                        while (iStream.hasBytesAvailable) {
                            let len = iStream.read(&buffer, maxLength: 1)
                            
                            if len == 0 {
                                print("Whoops")
                                return
                            } else if buffer[0] == 1 { //SOH
                                break;
                            }
                        }
                        
                        while(iStream.hasBytesAvailable) {
                            let len = iStream.read(&buffer, maxLength: 1)
                            
                            if(len == 0) {
                                //fail -- should send bad message response
                                return;
                            }
                            rawdata.append(buffer[0])
                            if(buffer[0] == 4) { //EOT
                                //check for ETX DONE
                                let tail = rawdata.dropFirst(rawdata.count-6)
                                if(tail.elementsEqual(Constants.kTraceTailBuf)) {
                                    // create trace
                                    let seqNo = seqNoQueue.popLast()!
                                    let trace = GPRTrace(sequenceNumber: seqNo, rawData: [UInt8](rawdata.dropLast(6)))
                                    // fucking do something with the trace
                                    gprReadings.append(trace)
                                    traceByLocation[trace.location!] = trace
                                    
                                    // replace with delegate stuff
//                                    let score = DataAnalyzer.analyze(trace, settings: settings)
//                                    
//                                    gprResults[trace.seqNumber] = score
//                                    
//                                    // UI display score
//                                    NSLog("\(score)")
                                    
                                    break
                                }
                                
                            }
                        }
                    }
                }
            default :
                //TODO: fill out other events
                break;
        }
    }
     var counter = 0
    func receiveData(rawdata: [UInt8]) {
        
        let tail = rawdata.dropFirst(rawdata.count-6)
        if(tail.elementsEqual(Constants.kTraceTailBuf) || true) {
            // create trace
            let seqNo = counter
            counter = counter+1//seqNoQueue.popLast()!
            let trace = GPRTrace(sequenceNumber: seqNo, rawData: [UInt8](rawdata.dropLast(6)))
            // fucking do something with the trace
            gprReadings.append(trace)
            traceByLocation[trace.location!] = trace
            
            // replace with delegate stuff
//            let score = DataAnalyzer.analyze(trace, settings: settings)
//            
//            gprResults[seqNo] = score
//            
//            // UI display score
//            NSLog("\(score)")
        }
    }
    
    
    func addTrace(rawData: [UInt16], traceNumber: Int, location: CLLocation, analyze: Bool = true) -> GPRTrace {
        let trace = GPRTrace(sequenceNumber: traceNumber, rawData: rawData)
        trace.location = location
        
        if analyze {
            DataAnalyzer.analyzeAsync(trace, settings: settings, delegate: mainDisplay!)
        }
        
        traceByLocation[location] = trace
        locationBySeqNo[traceNumber] = location
        gprReadings.append(trace)
        
        return trace
    }
    
    func updateScore(trace: GPRTrace, score: Double) {
        gprResults[trace.seqNumber] = score
    }
    
    // MARK: Functions
    
    // returns sequence number for trace requested by this call
    func runTrace() ->Int {
        let seqNo = dataSource!.runTrace()
        
        locationBySeqNo[seqNo] = mainDisplay?.locationManager?.location
        
        return seqNo
    }
    
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
    
    func writeToFile(dest: GPRSessionStore) {
        dest.writeSession(self)
    }

    
    private func readGprData(inout buf: [UInt8]) -> Int {
        if(!dataSource!.dataStream.hasBytesAvailable) {
            return 0
        }
        
        return dataSource!.dataStream.read(&buf, maxLength: buf.capacity)
    }
    
    // other version of function seems better
    private func readGprData(nBytes: Int) -> [UInt8] {
        var buffer = [UInt8](count: nBytes, repeatedValue: 0)
        dataSource!.dataStream.read(&buffer, maxLength: nBytes)
        return buffer
    }
}