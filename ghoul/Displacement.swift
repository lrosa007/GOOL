//
//  Displacement.swift
//  ghoul
//
//  Represents a translational displacement in two dimensions.
//  Units are not specified within the type
//  Copyright (c) 2016 deadsquad. All rights reserved.
//

import Foundation

// MARK: Equatable
func ==(lhs: Displacement, rhs: Displacement) -> Bool {
    // perhaps use a tolerance?
    return lhs.northSouth == rhs.northSouth &&
           lhs.eastWest == rhs.eastWest
}

class Displacement : Hashable {
    
    // MARK: Properties
    var northSouth: Double
    var eastWest: Double
    
    var hashValue : Int {
        get {
            return northSouth.hashValue * 31 + eastWest.hashValue
        }
    }
    
    
    // MARK: Initialization
    init(northSouth: Double, eastWest: Double) {
        self.northSouth = northSouth
        self.eastWest = eastWest
    }
}