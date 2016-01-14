//
//  GPRDataOutput.swift
//  ghoul
//
//  Classes implementing this protocol allow saving raw or processed GPR data
//
//  Copyright (c) 2016 deadsquad. All rights reserved.
//

import Foundation

protocol GPRDataOutput {
    func writeGprData(data: [UInt8])
}