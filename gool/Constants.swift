//
//  Constants.swift
//  gool
//
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation

struct Constants {
    static let SOH = "\u{0001}"
    static let STX = "\u{0002}"
    static let ETX = "\u{0003}"
    static let EOT = "\u{0004}"
    static let kMessageNumber = "MSGNO"
    static let kErrorPrefix = "ERR_"
    static let kBadMessage = "ERR_BAD_MSG"
    static let kResendMessage = "ERR_RESEND_MSG"
    static let kSetFrequency = "SET_FREQ"
    static let kOkay = "OKAY"
    static let kFrequencyErrorPrefix = "ERR_FREQ"
    static let kRunTrace = "RUN_TRACE"
    static let kTraceResponseHeader = "TRACE"
    static let kTraceResponseTail = "DONE"
}