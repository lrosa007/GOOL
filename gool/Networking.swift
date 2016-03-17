//
//  Networking.swift
//  gool
//
//  Created by Janet on 3/17/16.
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation

class Networking : NSObject, NSNetServiceBrowserDelegate {
    private var browser : NSNetServiceBrowser?
    
    func startBrowsing() {
        if browser == nil {
            browser = NSNetServiceBrowser()
        }
        
        // set delegate
        browser?.delegate = self
        
        // check whether local is correct. Also mark as constants or something
        browser?.searchForServicesOfType("_gsd._tcp", inDomain: "local.")
    }
    
    
}