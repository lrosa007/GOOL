//
//  GPRFileReader.swift
//  gool
//
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation

public class GPRFileReader : GPRSessionSource {
    
    // MARK: properties
    public private(set) var path: String
    
    
    // MARK: initialization
    init(path: String) {
        self.path = path
    }
    
    
    // MARK: GPRSessionSource
    func readSession() -> GPRSession? {
        return nil
    }
}