//
//  GPRSessionSource.swift
//  gool
//
//  Represents some source which holds a representation of a recorded GPR session.
//
//  Created by Janet on 3/17/16.
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation

protocol GPRSessionSource {
    func readSession() -> GPRSession?
}