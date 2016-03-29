//
//  NetworkConnectionVC.swift
//  gool
//
//  Contains callbacks to handle network GPR device detection.
//
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import UIKit

class NetworkConnectionVC : UIViewController, NetworkBrowserDelegate {
    
    func searchForGPRDevice() {
        Networking().startBrowsing(self)
    }
    
    func serviceResolved(service: NSNetService) {
        if Mocker.mockEnabled {
            var session = GPRSession(mock: MockDataSource())
            return
        }
        
        // create NetworkGPRDevice like so:
        let gprDevice = NetworkGPRDevice(service: service)!
        // use it or assign it properly, then perform UI actions to inform user of connection
    }
    
    func didNotSearch(aNetServiceBrowser: NSNetServiceBrowser, aNetService: NSNetService,
        errorDict: [NSObject : AnyObject]) {
            // could not search for devices :(
            // tell user based on errorDict
    }
    
    func lostService(aNetSerice: NSNetService) {
        // report loss of connection via UI
    }
}