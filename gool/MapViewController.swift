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
    
    @IBOutlet weak var results: UITextView!
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchForGPRDevice()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func runTraceClicked(sender: UIButton) {
        let seqNo = Mocker.globalSession?.runTrace()
        
        NSLog("Requested trace #\(seqNo)")
    }
    
    func appendResults(traceNo: Int, score: Double) {
        results.text.appendContentsOf(String("Trace #\(traceNo): \(score)"))
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
