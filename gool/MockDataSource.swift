//
//  MockDataSource.swift
//  gool
//
//  For testing/demo. Does not handle any networking.
//
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation

class MockDataSource : GPRDataSource {
    
    private var msgNo = 0, deviceMsgNo = 0
    var inputStream: NSInputStream
    var outputStream: NSOutputStream
    
    internal var dataStream: NSInputStream {
        get {
            return inputStream
        }
    }
    
    init() {
        inputStream = NSInputStream()
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreateBoundPair(nil, &readStream, &writeStream, CFIndex(1 << 20))
        
        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        
        // set delegates for streams
        
        inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func runTrace() -> Int {
        let seqNum = msgNo++
        
        // call some mock function to generate response after a few milliseconds
        
        return seqNum
    }
    
    func start() -> Bool {
        inputStream.open()
        outputStream.open()
        
        return true
    }
    
    func stop() {
        
    }
    
    func setFrequency(hertz: UInt) {
        
    }
    
    func hasFullMessage() -> Bool {
        return true
    }
    
    func getMessage() -> String {
        return Constants.kTraceResponseHeader
    }
    
    
    private func getRandomTrace(seqNo: Int) {
        // replace with pipe to mock input?
        let ostream = NSOutputStream()
        
        let nBytes = 1 << 14
        let header = Constants.kMessageNumber + " " + (deviceMsgNo++).description + " " + Constants.STX
                   + Constants.kTraceResponseHeader + " " + seqNo.description + " " + Constants.SOH
        let tail = Constants.ETX + Constants.kTraceResponseTail
        let encodedHeader = [UInt8](header.utf8), encodedTail = [UInt8](tail.utf8)
        
        let randomData = UnsafeMutablePointer<UInt8>()
        SecRandomCopyBytes(kSecRandomDefault, nBytes, randomData)
        
        ostream.write(encodedHeader, maxLength: encodedHeader.count)
        ostream.write(randomData, maxLength: nBytes)
        ostream.write(encodedTail, maxLength: encodedTail.count)
    }
}