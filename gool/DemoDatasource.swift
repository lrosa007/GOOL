//
//  DemoDatasource.swift
//  gool
//
//  Reads trace values directly from prerecorded data for demo purposes
//

import Foundation

class DemoDatasource: NSObject, GPRDataSource {
    var dataStream: NSInputStream {get {return stream} }
    private var stream = NSInputStream()
    private var traceNum = 0, totalTraces: Int
    private var readings: [[UInt16]]
    var deltaT, baseRDP, deltaX: Double
    
    
    init(demo: Int) {
        
        totalTraces = DemoDatasource.traceCounts[demo]
        baseRDP = DemoDatasource.baseRDPs[demo]
        deltaT = DemoDatasource.deltaTs[demo]
        deltaX = DemoDatasource.dxs[demo]
        readings = [[UInt16]]()
        
        
        //open appropriate file
        let fileName = DemoDatasource.fileNames[demo]
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(fileName)
            
            do {
                let lines = try NSString(contentsOfURL: path, encoding: NSUTF8StringEncoding).componentsSeparatedByString("\n")
                for line in lines {
                    var trace = [UInt16]()
                    let samples = line.componentsSeparatedByString("\t")
                    for sample in samples {
                        trace.append(UInt16(sample)!)
                    }
                    readings.append(trace)
                }
            }
            catch {}
        }
    }
    
    // MARK: GPRDataSource functions
    func runTrace() -> Int {
        let res = traceNum
        traceNum += 1
        //copy data into stream
        return res
    }
    
    func start() -> Bool {
        return true
    }
    func stop() { }
    func setFrequency(hertz: UInt) {}
    
    
    func hasFullMessage() -> Bool {return linesRead < readings.count}
    func getMessage() -> String {return ""}
    private var linesRead = 0
    func getReadings() -> [UInt16] {
        let ind = linesRead
        linesRead += 1
        return readings[ind]
    }
    
    
    // MARK: Sample file info
    static let fileNames = ["5line07","copipes","darea","fivetanks","flvoids","rebar","twopipes"]
    static let traceCounts = [813, 380, 472, 461, 1, 290, 329]
    static let baseRDPs = [9.0, 12.0, 9.0, 9.463, 7.0, 7.0, 7.9] // uncertain about first two
    //Each file has 512 samples per trace, so given range in ns, we can calculate dt between successive samples
    static let deltaTs = [102.0/512.0, 49.9/512.0, 100.0/512.0, 60.0/512.0, 15.0/512.0, 12.4366/512.0, 30.0/512.0]
    // dx is distance in meters between successive traces. 0 if unknown
    static let dxs = [0.0, 0.0, 0.04, 0.0, 0.0, 0.0254, 0.04]
}