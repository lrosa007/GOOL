//
//  MapViewController.swift
//  gool
//
//  Created by Janet on 4/19/16.
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, NetworkBrowserDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    var session:GPRSession?
    var locationManager: CLLocationManager?
    
    let borderAlpha : CGFloat = 0.7
    let cornerRadius : CGFloat = 5.0
    
    @IBOutlet weak var run: UIButton!
    @IBOutlet weak var done: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refresh()
        
        run.frame = CGRectMake(100, 100, 200, 40)
        run.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        run.backgroundColor = UIColor.clearColor()
        run.layer.borderWidth = 1.0
        run.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).CGColor
        run.layer.cornerRadius = cornerRadius
        
        done.frame = CGRectMake(100, 100, 200, 40)
        done.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        done.backgroundColor = UIColor.clearColor()
        done.layer.borderWidth = 1.0
        done.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).CGColor
        done.layer.cornerRadius = cornerRadius
        
        
        self.searchForGPRDevice()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            locationManager?.requestWhenInUseAuthorization()
        }
        
        let testArr = [1.0, 2.0, 4.0, 6.5, 4.0, 2.0, 1.0]
        DSP.findPeaks(testArr, dx: 1.0, minSlope: 0.5, minAmplitude: 1.9)
    }
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
            mapView.mapType = .Satellite
            
            //            if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            //                initMap()
            //            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLoc = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: currentLoc.coordinate.latitude, longitude: currentLoc.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        
        mapView.setRegion(region, animated: true)
    }
    
    // set up map stuff
    //    private func initMap() {
    //        if mapView == nil {
    //            mapView = MKMapView()
    //        }
    //
    //        let here = CLLocationCoordinate2D(latitude: CLLocationDegrees(28.6013431), longitude: CLLocationDegrees(-81.2009287))
    //        let viewRegion = MKCoordinateRegionMakeWithDistance(here, 500, 500);
    //        let adjustedRegion = mapView.regionThatFits(viewRegion);
    //        mapView.setRegion(adjustedRegion, animated:true);
    //        mapView.showsUserLocation = true;
    //    }
    
    // Mark: CLLocationManagerDelegate implementations
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse:
            //initMap()
            locationManager?.startUpdatingLocation()
            
            break
        case .Denied:
            // sorry, can't use without location services -- go to settings to change them
            break
        case .Restricted:
            // sorry, this app won't function without location services
            break
        default:
            // don't do anything
            return
        }
    }
    
    //Mark: map controls
    private func clearAnnotations() {
        if mapView?.annotations != nil { mapView.removeAnnotations(mapView.annotations) }
    }
    
    // annotation must have coordinate:CLLocationCoordinate2D, title:String!, subtitle:String!
    private func addAnnotations(annotations: [MKAnnotation]) {
        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: true)
    }
    
    // Use this function to mark gravesites on map
    func markObjectsOnMap(location: [CLLocation], trace: [GPRTrace], score: [Double]) {
        var annotations = [MKAnnotation]()
        
        for i in 0...location.count-1 {
            annotations[i] = GraveSite(location: location[i], trace: trace[i], score: score[i])
        }
        
        addAnnotations(annotations)
    }
    
    @IBAction func runTraceClicked(sender: UIButton) {
        var response:String
        
        let seqNo = Mocker.globalSession?.runTrace()
        NSLog("Requested trace #\(seqNo)")
        
        if true {
            response = "we found it"
        } else {
            response = "dam nothing"
        }
        
        let alert = UIAlertController(title: "trace", message: response, preferredStyle: UIAlertControllerStyle.Alert)
        
        // cool got it
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveSession(sender: UIButton) {
        // create the alert
        let alert = UIAlertController(title: "session", message: "Would you like to save and close this session?", preferredStyle: UIAlertControllerStyle.Alert)
        
        // sorry nvm
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        // save & close
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: { action in
            let vc: AnyObject! = self.storyboard!.instantiateInitialViewController()
            self.showViewController(vc as! ViewController, sender: vc)
        }))
        
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    
    func searchForGPRDevice() {
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            locationManager?.requestWhenInUseAuthorization()
        }
            
        else {
            Networking().startBrowsing(self)
        }
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
        
//        session = GPRSession(device: NetworkGPRDevice(service: service)!)
        
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