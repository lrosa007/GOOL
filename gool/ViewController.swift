//
//  ViewController.swift
//  gool
//
//  Created by Janet on 3/17/16.
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NetworkBrowserDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loadSession(sender: UIButton) {
        
    }
    
    @IBAction func newSession(sender: UIButton) {
        self.searchForGPRDevice()
    }
    
    
    func searchForGPRDevice() {
        Networking().startBrowsing(self)
    }
    
    func serviceResolved(service: NSNetService) {
        // create NetworkGPRDevice like so:
        let gprDevice = NetworkGPRDevice(service: service)
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
