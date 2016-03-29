//
//  NetworkGPRDevice.swift
//  gool
//
//  Application representation of a  WiFi-connected GPR data collector.
//
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation

class NetworkGPRDevice : GPRDataSource {
    enum ConnectionStatus {
        case CONNECTED
        case PRE_CONNECTION
        case DISCONNECTED
        case FINISHED
    }

    //TODO: properties and initializer(s) for actual WiFi connection
    private var inputStream: NSInputStream
    private var outputStream: NSOutputStream
    var messageNumber: Int
    internal var status: ConnectionStatus
    var delegate: GPRStreamHandler?

    internal var dataStream: NSInputStream {
        get {
            return inputStream
        }
    }


    // MARK: initialization
    init() {
        inputStream = NSInputStream()
        outputStream = NSOutputStream()

        messageNumber = 1;
        status = ConnectionStatus.PRE_CONNECTION
    }

    convenience init?(service: NSNetService) {
        self.init()

        let isPtr = UnsafeMutablePointer<NSInputStream?>.alloc(1)
        let osPtr = UnsafeMutablePointer<NSOutputStream?>.alloc(1)

        service.getInputStream(isPtr, outputStream: osPtr)

        let fail = (isPtr == nil || osPtr == nil)

        if !fail {
            inputStream = isPtr.move()!
            outputStream = osPtr.move()!
            status = ConnectionStatus.CONNECTED

        }

        isPtr.dealloc(1)
        osPtr.dealloc(1)

        if fail {
            return nil
        }
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
        
        let formattedMessage = Constants.kMessageNumber + " " + (messageNumber++).description
            + " " + Constants.STX + msg + Constants.EOT

        return send(formattedMessage)
    }

    func isConnected() -> Bool {
        return status == ConnectionStatus.CONNECTED
    }

    // MARK: GPRDataSource

    // returns sequence number that will be associated with this trace
    // once its data is generated, or -1 if sending message fails
    func runTrace() -> Int {
        let seqNum = messageNumber+1

        return sendMessage(Constants.kRunTrace) ? seqNum : -1
    }

    func start() -> Bool {
        if(delegate == nil) {
            return false
        }

        if(!isConnected()) {
            // log? otherwise handle?
        }

        // TODO: send START instruction to device

        return true
    }

    func stop() {
        if(!isConnected()) {
            //?
        }

        //TODO: send STOP instruction to device
    }

    func setFrequency(hertz: UInt) {
        // should require source to stop reading before changing frequency
        // perhaps should be async and not return bool yet

    }

    func hasFullMessage() -> Bool {
        //TODO: read bytes into a buf; advance until EOT

        return false
    }

    func getMessage() -> String {
        //TODO: create message class to improve this

        return ""
    }


    // MARK: Callbacks
    func stopped() {
        inputStream.close()
        outputStream.close()
        status = ConnectionStatus.FINISHED
    }
}
