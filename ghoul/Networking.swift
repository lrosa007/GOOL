//
//  Networking.swift
//  ghoul
//
//  Created by Student on 1/14/16.
//  Copyright (c) 2016 deadsquad. All rights reserved.
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
        browser?.searchForServicesOfType("_gsd._tcp", inDomain: "local.")
        // ^ check whether local is correct. Also mark as constants or something
    }
    
    // MARK: NSNetServiceBrowser callbacks
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        //it's possible we should check moreComing -- if it's true there could be two devices
        // is connection with two devices simultaneously something we could consider as an extension?
        
        // we've found an instance of GDS service! now expose it for NetworkGPRDevice
        
        aNetService.resolveWithTimeout(4.0) //timeout is in seconds
        // once resolved, use aNetService.addresses[0], which should be a sockaddr structure
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        // oh no -- lost connection! inform the appropriate ViewController
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didNotSearch errorDict: [NSObject : AnyObject]) {
        // Use the dictionary keys NSNetServicesErrorCode and NSNetServicesErrorDomain to retrieve the error information from the dictionary.
        // use appropriate viewcontroller to warn that search failed
    }
}