//
//  Gravesite.swift
//  gool
//

import Foundation
import MapKit

class GraveSite: NSObject, MKAnnotation {
    @objc var coordinate:CLLocationCoordinate2D
    @objc var title, subtitle:String?
    
    init(location: CLLocation, trace: GPRTrace, score: Double) {
        coordinate = location.coordinate
        
        title = "Likely Gravesite"
        subtitle = "\(Int(score))% likelihood"
    }
    
    init(location: CLLocation, trace: GPRTrace, score: Double, description: String) {
        coordinate = location.coordinate
        
        title = "Likely Gravesite -- \(Int(score))% likelihood"
        subtitle = description
    }
}