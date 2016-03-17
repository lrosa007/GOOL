//
//  GPRDataOutput.swift
//  gool
//
//  Classes implementing this protocol allow saving raw or processed GPR data
//
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation

protocol GPRDataOutput {
    func writeGprData(data: [UInt8])
}