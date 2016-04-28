//
//  Material.swift
//  gool
//
//  Represents a material whose presence underground may be guessed at
//
//  Some are defined statically; others may be added later via UI or files
//

import Foundation

class Material : NSObject {
    let minRDP, maxRDP: Double
    let casketMaterial, remains: Bool
    private let _description: String
    
    private init(min: Double, max: Double, casket: Bool = false, body: Bool = false, name: String) {
        minRDP = min
        maxRDP = max
        casketMaterial = casket
        remains = body
        _description = name
    }
    
    override var description: String {
        return _description
    }
    
    
    // Mark: predefined materials
    static let Water = Material(min: 78.0, max: 87.0, name: "Water") // ~76.5 @ 30°C - ~87.7 @ 0.1°C
    
    static let Brick = Material(min: 3.7, max: 4.5, name: "Brick")
    static let Charcoal = Material(min: 1.2, max: 1.81, name: "Charcoal")
    static let Concrete = Material(min: 4.4, max: 4.6, name: "Concrete")
    static let FiberglassResin = Material(min: 4.0, max: 4.5, casket: true, name: "Fiberglass resin")
    static let Glass = Material(min: 3.7, max: 4.0, name: "Glass")
    
    // Any conductor has theoretical RDP of ∞. Any value beyond 80 probably indicates conductor, however
    static let Metal = Material(min: 90, max: Double.infinity, casket: true, name: "Metal")
    
    static let PFR = Material(min: 4.5, max: 5.0, casket: true, name: "Polymer (Phenol Formaldehyde Resin)")
    static let PFR_Cast = Material(min: 9.0, max: 15.0, casket: true, name: "Polymer (cast PFR)")
    static let PFR_GlassFiller = Material(min: 6.6, max: 7.0, casket: true, name: "Polymer (PFR with glass fiber filler)")
    
    static let Porcelain = Material(min: 6.0, max: 8.0, name: "Porcelain")
    static let Sheetrock = Material(min: 2.3, max: 2.5, name: "Sheetrock")
    
    static let GenericWoodDry = Material(min: 1.4, max: 6.0, casket: true, name: "Wood (generic, dry)")
    static let GenericWoodWet = Material(min: 10.0, max: 20.0, name: "Wood (generic, wet)")
    
    // materials possibly indicative of human remains
    static let Bone = Material(min: 14.1, max: 14.6, body: true, name: "Bone (wet)")
    static let Muscle = Material(min: 45, max: 50, body: true, name: "Muscle")
    static let Skin = Material(min: 33, max: 44, body: true, name: "Skin (not mummified)")
    
    
    
    // Perhaps this stuff could be stored in a config file or something
    static let MaterialList = [Water, Brick, Charcoal, Concrete, FiberglassResin, Glass, Metal,
                               PFR, PFR_Cast, PFR_GlassFiller, Porcelain, Sheetrock, GenericWoodDry,
                               GenericWoodWet, Bone, Muscle, Skin]
}