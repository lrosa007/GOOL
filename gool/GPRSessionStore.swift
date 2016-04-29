//
//  GPRSessionOutput.swift
//  gool
//
//  Classes implementing this protocol allow saving GPR session information
//
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation

protocol GPRSessionStore {
    func writeSession(session: GPRSession)
    func readSession() -> GPRSession?
    func serialize(session: GPRSession) -> String
}