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
    private var inputStream: NSInputStream
    private var outputStream: NSOutputStream
    var messageNumber: Int
    
    internal var dataStream: NSInputStream {
        get {
            return self.dataStream
        }
    }
    
    
    // MARK: initialization
    init?() {
        // TODO should actually be passed connection (socket?) to device and init based on that
        inputStream = NSInputStream()
        outputStream = NSOutputStream()
        
        messageNumber = 1;
    }
    
    
    // MARK: functions
    private func send(msg: String) -> Bool {
        if(msg.isEmpty) {
            return true
        }
        
        if(!isConnected()) {
            return false
        }
        
        let encodedArray = [UInt8](msg.utf8)
        return outputStream.write(encodedArray, maxLength: encodedArray.count) > 0
        
        
        //outputStream.write(UnsafePointer<UInt8>(msg), maxLength: msg.lengthOfBytesUsingEncoding(<#encoding: NSStringEncoding#>))
    }
    
    func sendMessage(msg: String) -> Bool {
        if(msg.isEmpty) {
            return false
        }
        
        let formattedMessage = (messageNumber++).description
            + " " + Constants.STX + msg + Constants.EOT
        
        return send((messageNumber++).description + " " + msg)
    }
    
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