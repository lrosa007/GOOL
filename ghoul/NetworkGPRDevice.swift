//
//  NetworkGPRDevice.swift
//  ghoul
//
//  Application representation of a  WiFi-connected GPR data collector.
//  Copyright (c) 2016 deadsquad. All rights reserved.
//

import Foundation

class NetworkGPRDevice : GPRDataSource {
    //TODO: properties and initializer(s) for actual WiFi connection
    private var stream: NSInputStream
    
    internal var dataStream: NSInputStream {
        get {
            return self.dataStream
        }
    }
    
    
    // MARK: initialization
    init?() {
        // TODO should actually be passed connection (socket?) to device and init based on that
        stream = NSInputStream()
    }
    
    
    // MARK: functions
    
    func isConnected() -> Bool {
        //TODO: stub
        return false
    }
    
    // MARK: GPRDataSource
    func start() {
        if(!isConnected()) {
            // log? otherwise handle?
        }
        
        // TODO: send START instruction to device
    }
    
    func stop() {
        if(!isConnected()) {
            //?
        }
        
        //TODO: send STOP instruction to device
    }
    
    func setFrequency(hertz: UInt) -> Bool {
        // should require source to stop reading before changing frequency
        // perhaps should be async and not return bool yet
        
        return false
    }
}