//
//  GPRDataFileWriter.swift
//  gool
//
//  Allows writing raw/processed GPR data (without session info) to file.
//
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation

public class GPRDataFileWriter : GPRDataOutput {
    public var path: String
    
    init(path: String) {
        if(path.isEmpty) {
            // rename to a default directory and default name from current time?
        }
        
        self.path = path
    }
    
    // MARK: GPRDataOutput
    func writeGprData(data: [UInt8]) {
        //TODO: open file, write short header, then write all data
        
        let outStream = NSOutputStream(toFileAtPath: path, append: false)
        if(outStream == nil) {
            //handle it
        }
        outStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        outStream!.open()
        //TODO: write header
        outStream!.write(data, maxLength: data.count)
        outStream!.close()
    }
}