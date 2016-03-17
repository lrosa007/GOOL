//
//  GPRSessionOutput.swift
//  gool
//
//  Classes implementing this protocol allow saving GPR session information
//
//  Created by Janet on 3/17/16.
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation

protocol GPRSessionOutput {
    func writeSession(session: GPRSession)
}