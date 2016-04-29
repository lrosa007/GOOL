//
//  Networking.swift
//  gool
//
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation

class Networking : NSObject, NSNetServiceBrowserDelegate {
    private var browser : NSNetServiceBrowser?
    var delegate : NetworkBrowserDelegate?
    
    func startBrowsing(nbDelegate: NetworkBrowserDelegate) {
        delegate = nbDelegate
        
        if browser == nil {
            browser = NSNetServiceBrowser()
        }
        
        // set self as delegate for browser
        browser?.delegate = self
        
        // check whether local is correct. Also mark as constants or something
        browser?.searchForServicesOfType("_gds._tcp", inDomain: "local.")
    }
    
    // MARK: NSNetServiceBrowser callbacks
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        //it's possible we should check moreComing -- if it's true there could be two devices
        // is connection with two devices simultaneously something we could consider as an extension?
        
        // we've found an instance of GDS service! now expose it for NetworkGPRDevice
        
        aNetService.resolveWithTimeout(4.0) //timeout is in seconds
        
        // once resolved, use aNetService.addresses[0], which should be a sockaddr structure
    }
    
    // I'm not sure contents of this method are necessary. 
    func netServiceDidResolveAddress(sender: NSNetService) {
        for addressBytes in sender.addresses! {
            var inetAddress : sockaddr_in!
            var inetAddress6 : sockaddr_in6!
            
            let inetAddressPointer = UnsafePointer<sockaddr_in>(addressBytes.bytes)
            inetAddress = inetAddressPointer.memory
            if inetAddress.sin_family != __uint8_t(AF_INET) {
                if inetAddress.sin_family == __uint8_t(AF_INET6) {
                    let inetAddressPointer6 = UnsafePointer<sockaddr_in6>(addressBytes.bytes)
                    inetAddress6 = inetAddressPointer6.memory
                }
                inetAddress = nil
            }
            
            var ipString : UnsafePointer<Int8>?
            let ipStringBuffer = UnsafeMutablePointer<Int8>.alloc(Int(INET6_ADDRSTRLEN))
            if(inetAddress != nil) {
                var addr = inetAddress.sin_addr
                ipString = inet_ntop(Int32(inetAddress.sin_family), &addr, ipStringBuffer, __uint32_t(INET6_ADDRSTRLEN))
            } else if inetAddress6 != nil {
                var addr = inetAddress6.sin6_addr
                ipString = inet_ntop(Int32(inetAddress6.sin6_family), &addr, ipStringBuffer, __uint32_t(INET6_ADDRSTRLEN))
            }
            
            // expected service name: local._gsd._tcp.gpr-device with optional trailing number
            
            if ipString != nil {
                let ip = String.fromCString(ipString!)
                if ip != nil {
                    NSLog("\(sender.name)(\(sender.type)) - \(ip!)")
                    NSNotificationCenter.defaultCenter().postNotificationName("NewSharedDetected", object: self)
                }
            }
            
            ipStringBuffer.dealloc(Int(INET6_ADDRSTRLEN))
        }
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [NSObject : AnyObject]) {
        NSLog("\(sender.name) did not resolve: \(errorDict[NSNetServicesErrorCode]!)")
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        // oh no -- lost connection! inform the appropriate ViewController
        delegate?.lostService(aNetService)
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didNotSearch aNetService: NSNetService, errorDict: [NSObject : AnyObject]) {
        // Use the dictionary keys NSNetServicesErrorCode and NSNetServicesErrorDomain to retrieve the error information from the dictionary.
        delegate?.didNotSearch(aNetServiceBrowser, aNetService: aNetService, errorDict: errorDict)
    }
}