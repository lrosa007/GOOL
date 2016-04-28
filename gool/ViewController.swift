//
//  ViewController.swift
//  gool
//
//  Created by Janet on 3/17/16.
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let borderAlpha : CGFloat = 0.7
    let cornerRadius : CGFloat = 5.0
    
    @IBOutlet weak var load: UIButton!
    @IBOutlet weak var new: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        self.refresh()
        
        load.frame = CGRectMake(100, 100, 200, 40)
        load.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        load.backgroundColor = UIColor.clearColor()
        load.layer.borderWidth = 1.0
        load.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).CGColor
        load.layer.cornerRadius = cornerRadius
        
        new.frame = CGRectMake(100, 100, 200, 40)
        new.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        new.backgroundColor = UIColor.clearColor()
        new.layer.borderWidth = 1.0
        new.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).CGColor
        new.layer.cornerRadius = cornerRadius
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition(nil, completion: {
            _ in
            
            
            self.refresh()
        })
    }
}
