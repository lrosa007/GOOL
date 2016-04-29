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
    
    
    // TODO: add delegate parameter
    static internal func analyzeAsync(trace: GPRTrace, settings: GPRSettings, delegate: MapViewController) {
        var signal = DSP.dataAsDoubles(trace)
        var score = 0.0
        var description = ""
        
        // filter/adjust based on settings, etc
        
        
        let dx = DSP.dDepth(trace, settings: settings)
        
        // peaks indicate material interfaces
        let interfaces = DSP.findPeaks(signal, dx: dx, minSlope: 1.0, minAmplitude: Double(1<<14))
                            .filter( {(peak: DSP.Peak) -> Bool in
                                       peak.position >= settings.minTargetDepth
                                    && peak.position <= settings.maxTargetDepth} )
        
        let baseIntensity = Double(1<<16)
        var guesses = [[Material]]()
        for peak in interfaces {
            let reflection = signal[peak.sampleNumber]
            let mats = DSP.guessMaterials(peak, settings: settings, base: baseIntensity, reflection: reflection)
            
            if mats.count == 0 {
                description += "At depth \(peak.position) m, unknown material\n"
            }
            else {
                description += "At depth \(peak.position) m, possible object:\n"
            }
            
            for material in mats {
                description += "\(material)\n"
                if (material.casketMaterial || material.remains) {
                    if score >= 80.0 {
                        score = (100.0+score)/2.0
                    }
                    else {
                        score = 80.0
                    }
                }
                else {
                    if score < 10.0 {
                        score = 60.0
                    }
                    else {
                        score += 5.0
                    }
                }
            }
            guesses.append(mats)
        }
        
        // TODO: callback
    }
    
    
    
    //precondition: data is in distance/distance form
    static internal func analyze(trace: GPRTrace, settings: GPRSettings) -> Double {
        //TODO: stub
        return drand48()
    }
    
    // Analyzes several traces at once; may provide better 
    // ideally 2D and 3D situations can be differentiated
    static func analyze(traces: [GPRTrace], settings: GPRSettings) -> [Double] {
        var scores = [Double]()
        
        // should not actually do this, but synthesize multiple traces:
        for trace in traces {
            scores.append(DataAnalyzer.analyze(trace, settings: settings))
        }
        
        return scores
    }
}