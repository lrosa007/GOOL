//
//  GPRTrace.swift
//  gool
//
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation
import CoreLocation

class GPRTrace {
    var data : [UInt8]
    var location : CLLocation?
    var seqNumber, stackCount : Int
    
    init(sequenceNumber: Int, rawData: [UInt8], stacked: Int = 1) {
        seqNumber = sequenceNumber
        data = rawData
        stackCount = stacked
    }
    
    static func stack(traces : [GPRTrace]) ->GPRTrace {
        //guard traces.count > 0 else {
        //    throw something
        //}
        
        // optional: check that all seqNumbers match
        
        return GPRTrace(sequenceNumber: traces[0].seqNumber,
                        rawData: DSP.stackData(traces),
                        stacked: traces.count)
    }
}