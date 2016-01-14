//
//  GPRSessionSource.swift
//  ghoul
//
//  Represents some source which holds a representation of a recorded GPR session.
//
//  Copyright (c) 2016 deadsquad. All rights reserved.
//

import Foundation

protocol GPRSessionSource {
    func readSession() -> GPRSession?
}