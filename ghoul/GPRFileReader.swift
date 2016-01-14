//
//  GPRFileReader.swift
//  ghoul
//
//  Created by Student on 1/14/16.
//  Copyright (c) 2016 deadsquad. All rights reserved.
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