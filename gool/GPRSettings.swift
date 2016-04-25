//
//  GPRSettings.swift
//  gool
//
//  Holds information about measurement and analysis settings for a GPR session

import Foundation

class GPRSetttings : NSObject {
    var baseRdp : Double // Estimated relative dielectric permitivitty of soil measurements were taken in
    var minTargetDepth, maxTargetDepth : Double // During analysis, only consider targets within this range (meters)
    
    init(rdp: Double, minDepth:Double = 0.0, maxDepth:Double = 2.0) {
        baseRdp = rdp
        minTargetDepth = minDepth
        maxTargetDepth = maxDepth
    }
    
    convenience init(soilType: DSP.SoilType, minDepth:Double = 0.0, maxDepth:Double = 2.0) {
        self.init(rdp: soilType.rawValue, minDepth: minDepth, maxDepth: maxDepth)
    }
    
    convenience override init() {
        self.init(rdp: DSP.SoilType.Sandy_10_water.rawValue)
    }
}