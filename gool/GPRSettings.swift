//
//  GPRSettings.swift
//  gool
//
//  Holds information about measurement and analysis settings for a GPR session

import Foundation

class GPRSettings : NSObject {
    var baseRdp : Double // Estimated relative dielectric permitivitty of soil measurements were taken in
    var minTargetDepth, maxTargetDepth : Double // During analysis, only consider targets within this range (meters)
    var 𝚫T : Double = 1e-10 // time elapsed between each consecutive sample, in seconds
    
    init(rdp: Double, minDepth:Double = 0.2, maxDepth:Double = 2.0) {
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