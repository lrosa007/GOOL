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
    
    // Analyzes several traces at once; may provide better
    // ideally 2D and 3D situations can be differentiated
    //
    // Precondition: all traces have locations set -or- each trace taken at a distance of dx from previous (all colinear)
    //
    static internal func analyzeAsync(traces: [GPRTrace], settings: GPRSettings, delegate: MapViewController, dx: Double = 0.0) {
        var isEdge =  [[Bool]]() // row:trace  col:depth
        
        var data = [[Double]]()
        for trace in traces {
            data.append(DSP.dataAsDoubles(trace))
        }
        
        // for each depth, subtract average of all traces to suppress noise
        DSP.subAvg2D(&data)
        
        for (i, _) in traces.enumerate() {
            let signal = data[i]
            //var signal = DSP.dataAsDoubles(trace)
            //DSP.subAvg(&signal)
            
//            var traceEdges = [Bool](count: signal.count, repeatedValue: false)
//            
//            let dx = DSP.dDepth(trace, settings: settings)
//            
//            let peaks = DSP.findPeaks(signal, dx: dx, minSlope: 1.0, minAmplitude: Double(1<<12))
//                                       .filter( {(peak: Peak) -> Bool in
//                                                 peak.position >= settings.minTargetDepth
//                                                 && peak.position <= settings.maxTargetDepth} )
//            
//            for peak in peaks {
//                traceEdges[peak.sampleNumber] = true
//            }
//            isEdge.append(traceEdges)
            
            let traceEdges = DSP.findEdges(signal, minAmp: Double((1<<15) - (1<<7)))
            isEdge.append(traceEdges)
        }
        
        var interfaces = [Peak]()
        
        let rows = isEdge.count
        for i in 0...rows-1 {
            for j in 0...isEdge[i].count-1 {
                if(isEdge[i][j]) {
                    var edge = Edge(minJ: j, maxJ: j, minI: i, maxI: i)
                    var points = [Int]()
                    
                    getEdge(&isEdge, i: i, j: j, edge: &edge, incl: &points, peaked: false)
                    var width = 0.0
                    if dx == 0.0 {
                        width = traces[edge.maxI].location!.distanceFromLocation((traces[edge.minI].location!))
                    }
                    else {
                        width = dx * Double(1 + edge.maxI - edge.minI)
                    }
                    
                    
                    //only target objects of width >= 25 cm  width >= 0.25
                    if edge.maxI - edge.minI > 4 {
                        let mid = (edge.minI+edge.maxI)/2
                        let dDepth = DSP.dDepth(traces[mid], settings: settings)
                        let depth = dDepth * Double(edge.minJ)
                        let height = dDepth * Double(1 + edge.maxJ - edge.minJ)
                        if height >= 0.1 {
                            interfaces.append(Peak(sample: edge.minJ, pos: depth, h: height, w: width, tr: traces[mid]))
                        }
                        else {
                            for pt in points {
                                isEdge[pt%rows][pt/rows] = true
                            }
                        }
                    }
                }
            }
        }
        
        
        let baseIntensity = Double(1<<16)
        let potential = interfaces.count
        var flagged = 0
        for peak in interfaces {
            if peak.position < settings.minTargetDepth {
                continue
            }
            
            var description = ""
            var score = 0.0
            var guesses = [[Material]]()
            let trace = peak.trace!
            var signal = DSP.dataAsDoubles(trace)
            DSP.subAvg(&signal)
            let reflection = signal[peak.sampleNumber]
            let mats = DSP.guessMaterials(peak, settings: settings, base: baseIntensity, reflection: reflection)
            
            if mats.count == 0 {
                description += String(format: "At depth %.2f m, unknown material\n", peak.position)
                score = max(7.5, 50.0 - 27.0*(peak.width-2.0)*(peak.width-2.0))
                score += max(7.5, 50.0 - 36.0*(peak.position-1.5)*(peak.position-1.5))
                // depend on peak.width and peak.height and depth
            }
            else {
                // updated to just list best guess; overwhelming otherwise
                description += String(format: "At depth %.2f m, possible object: \(mats[0])\n", peak.position)
            }
            
            for material in mats {
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
                        score += (100.0 - score)/8.0
                    }
                }
            }
            guesses.append(mats)
            
            var mult = max(7.5, 50.0 - 25.0*(peak.width-2.0)*(peak.width-2.0))
            mult += max(7.5, 50.0 - 33.3*(peak.position-1.5)*(peak.position-1.5))
            score *= mult/100.0
            
            delegate.reportResults(trace, score: score, guesses: guesses, desc: description)
            if score >= 60.0 {
                flagged += 1
            }
        }
        
        delegate.reportFinished(flagged, possible: potential)
    }
    
    private struct Edge {
        var minJ, maxJ: Int
        var minI, maxI: Int
    }
    
    private static func check(grid: [[Bool]], i: Int, j: Int) -> Bool {
        return !(i >= grid.count || j < 0 || j >= grid[i].count || !grid[i][j])
    }
    
    private static func getEdge(inout grid: [[Bool]], i: Int, j: Int, inout edge: Edge, inout incl: [Int], peaked: Bool) -> Bool {
        if j < 0 || i >= grid.count || j >= grid[i].count || !grid[i][j] {
            return false
        }
        
        grid[i][j] = false
        incl.append(i + j*grid.count)
        
        if !peaked && j < edge.minJ {
            edge.minJ = j
        }
        else if j > edge.maxJ {
            edge.maxJ = j
        }
        if i > edge.maxI {
            edge.maxI = i
        }
        
        var hit = false
        
        if !peaked {
            if check(grid, i: i+1, j: j-2) {
                hit = getEdge(&grid, i: i+1, j: j-2, edge: &edge, incl: &incl, peaked: false)
            }
            if !hit && check(grid, i: i+1, j: j-1) {
                hit = hit || getEdge(&grid, i: i+1, j: j-1, edge: &edge, incl: &incl, peaked: false)
            }
            if !hit {
                hit = hit || getEdge(&grid, i: i+1, j: j, edge: &edge, incl: &incl, peaked: false)
            }
        }
        
        if peaked || !hit {
            hit = hit || getEdge(&grid, i: i+1, j: j, edge: &edge, incl: &incl, peaked: true)
            if !hit {
                hit = hit || getEdge(&grid, i: i+1, j: j+1, edge: &edge, incl: &incl, peaked: true)
            }
            if !hit {
                hit = hit || getEdge(&grid, i: i+1, j: j+2, edge: &edge, incl: &incl, peaked: true)
            }
        }
        
        //getEdge(&grid, i: i, j: j+1, edge: &edge, incl: &incl, peaked: peaked)
        
        return hit
    }
    
    static internal func analyzeAsync(trace: GPRTrace, settings: GPRSettings, delegate: MapViewController) {
        var signal = DSP.dataAsDoubles(trace)
        DSP.subAvg(&signal)
        var score = 0.0
        var description = ""
        
        // filter/adjust based on settings, etc
        
        
        let dx = DSP.dDepth(trace, settings: settings)
        
        // !!! numeric parameters to findPeaks need some work
        // peaks indicate material interfaces
        let interfaces = DSP.findPeaks(signal, dx: dx, minSlope: 1.0, minAmplitude: Double(1<<14))
                            .filter( {(peak: Peak) -> Bool in
                                       peak.position >= settings.minTargetDepth
                                    && peak.position <= settings.maxTargetDepth} )
        
        let baseIntensity = Double(1<<16)
        var guesses = [[Material]]()
        for peak in interfaces {
            let reflection = signal[peak.sampleNumber]
            let mats = DSP.guessMaterials(peak, settings: settings, base: baseIntensity, reflection: reflection)
            
            if mats.count == 0 {
                description += String(format: "At depth %.2f m, unknown material\n", peak.position)
            }
            else {
                // updated to just list best guess; overwhelming otherwise
                description += String(format: "At depth %.2f m, possible object: \(mats[0])\n", peak.position)
            }
            
            for material in mats {
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
                        score += (100.0 - score)/8.0
                    }
                }
            }
            guesses.append(mats)
        }
        
        delegate.reportResults(trace, score: score, guesses: guesses, desc: description)
    }
    
    //precondition: data is in distance/distance form
    static internal func analyze(trace: GPRTrace, settings: GPRSettings) -> [[Material]] {
        var signal = DSP.dataAsDoubles(trace)
        DSP.subAvg(&signal)
        var score = 0.0
        var description = ""
        
        // filter/adjust based on settings, etc
        
        
        let dx = DSP.dDepth(trace, settings: settings)
        
        // !!! numeric parameters to findPeaks need some work
        // peaks indicate material interfaces
        let interfaces = DSP.findPeaks(signal, dx: dx, minSlope: 1.0, minAmplitude: Double(1<<14))
            .filter( {(peak: Peak) -> Bool in
                peak.position >= settings.minTargetDepth
                    && peak.position <= settings.maxTargetDepth} )
        
        let baseIntensity = Double(1<<16)
        var guesses = [[Material]]()
        for peak in interfaces {
            let reflection = signal[peak.sampleNumber]
            let mats = DSP.guessMaterials(peak, settings: settings, base: baseIntensity, reflection: reflection)
            
            if mats.count == 0 {
                description += String(format: "At depth %.2f m, unknown material\n", peak.position)
            }
            else {
                // updated to just list best guess; overwhelming otherwise
                description += String(format: "At depth %.2f m, possible object: \(mats[0])\n", peak.position)
            }
            
            for material in mats {
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
                        score += (100.0 - score)/8.0
                    }
                }
            }
            guesses.append(mats)
        }

        return guesses
    }
}