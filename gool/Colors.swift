//
//  Colors.swift
//  gool
//
//  Created by Janet on 4/19/16.
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation
import UIKit

class Colors {
    static let defaultColors = Colors()
    
    
    let colorTop = UIColor(red: 24.0/255.0, green: 90.0/255.0, blue: 157.0/255.0, alpha: 1.0).CGColor
    let colorBottom = UIColor(red: 67.0/255.0, green: 206.0/255.0, blue: 162.0/255.0, alpha: 1.0).CGColor
    
    let gl: CAGradientLayer
    
    init() {
        gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0]
    }
}

extension UIViewController {
    var colors: Colors { return Colors.defaultColors }
    
    func refresh() {
        view.backgroundColor = UIColor.clearColor()
        let backgroundLayer = colors.gl
        backgroundLayer.frame = view.frame
        view.layer.insertSublayer(backgroundLayer, atIndex: 0)
    }
}