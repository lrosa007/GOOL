//
//  NetworkBrowserDelegate.swift
//  gool
//
//  protocol for delegate to handle asynchronous events during mDNS discovery
//
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation

protocol NetworkBrowserDelegate {
    func serviceResolved(service: NSNetService)
    func didNotSearch(aNetServiceBrowser: NSNetServiceBrowser, aNetService: NSNetService, errorDict: [NSObject : AnyObject])
    func lostService(aNetSerice: NSNetService)
}