//
//  GPRSessionOutput.swift
//  ghoul
//
//  Classes implementing this protocol allow saving GPR session information
//
//  Copyright (c) 2016 deadsquad. All rights reserved.
//

import Foundation

protocol GPRSessionOutput {
    func writeSession(session: GPRSession)
}