//
//  DataAnalyzer.swift
//  gool
//
//  Analyzes filtered GPR data.
//
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation

class DataAnalyzer {
    
    //precondition: data is in distance/distance form
    static internal func analyze(data: [UInt8], mode: GPRMode) -> Double {
        //TODO: stub
        return drand48()
    }
    
    // Analyzes several traces at once; may provide better 
    // ideally 2D and 3D situations can be differentiated
    static func analyze(traces: [GPRTrace], mode: GPRMode) -> [Double] {
        var scores = [Double]()
        
        // should not actually do this, but synthesize multiple traces:
        for trace in traces {
            scores.append(DataAnalyzer.analyze(trace.data, mode: mode))
        }
        
        return scores
    }
}