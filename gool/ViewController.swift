//
//  ViewController.swift
//  gool
//
//  Created by Janet on 3/17/16.
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NetworkBrowserDelegate {
    var session:GPRSession?
    
    @IBOutlet weak var results: UITextView!
    
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
    
    @IBAction func runTraceClicked(sender: UIButton) {
        let seqNo = Mocker.globalSession?.runTrace()
        
        NSLog("Requested trace #\(seqNo)")
    }
    
    func appendResults(traceNo: Int, score: Double) {
        results.text.appendContentsOf(String("Trace #\(traceNo): \(score)"))
    }
    
    func searchForGPRDevice() {
        Networking().startBrowsing(self)
    }
    
    func serviceResolved(service: NSNetService) {
        if (Mocker.mockEnabled) {
            session = GPRSession(mock: MockDataSource())
            session?.mainDisplay = self
            Mocker.globalSession = session!
            return
        }
        
        // create NetworkGPRDevice like so:
        let gprDevice = NetworkGPRDevice(service: service)
        // use it or assign it properly, then perform UI actions to inform user of connection
        if(gprDevice == nil) {
            //warn user via UI
            return
        }
        
        session = GPRSession(device: NetworkGPRDevice(service: service)!)

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
