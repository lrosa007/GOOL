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
        //inputStream = NSInputStream()
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
        let seqNum = msgNo+1
        
        Mocker.delay(0.5) {
            self.getRandomTrace(seqNum)
        }
        
        msgNo += 1
        
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
        
        let nBytes = 1 << 14
        let header = Constants.kMessageNumber + " " + (deviceMsgNo++).description + " " + Constants.STX
                   + Constants.kTraceResponseHeader + " " + seqNo.description + " " + Constants.SOH
        let tail = Constants.ETX + Constants.kTraceResponseTail
        let encodedHeader = [UInt8](header.utf8), encodedTail = [UInt8](tail.utf8)
        
        let randomData = UnsafeMutablePointer<UInt8>()
        SecRandomCopyBytes(kSecRandomDefault, nBytes, randomData)
        
        outputStream.write(encodedHeader, maxLength: encodedHeader.count)
        outputStream.write(randomData, maxLength: nBytes)
        outputStream.write(encodedTail, maxLength: encodedTail.count)
    }
}