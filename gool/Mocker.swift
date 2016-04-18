//
//  Mocker.swift
//  gool
//
//  Utility settings for mocking
//
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation

class Mocker {
    internal static var mockEnabled = false
    
    static var globalSession: GPRSession?
    
    static func delay(delay: Double, closure: ()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(), closure)
    }
}