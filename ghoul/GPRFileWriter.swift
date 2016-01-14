//
//  GPRFileWriter.swift
//  ghoul
//
//  Writes GPR session to a .GSD file
//  Copyright (c) 2016 deadsquad. All rights reserved.
//

import Foundation

public class GPRFileWriter : GPRSessionOutput {
    
    public var path: String
    
    
    // MARK: initialization
    init(path: String) {
        self.path = path
    }
    
    
    // MARK: GPRSessionOutput
    func writeSession(session: GPRSession) {
        // open file, encode data, write data, close file
    }
}