//
//  GSDFile.swift
//  gool
//
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import Foundation

public class GSDFile : GPRSessionStore {
    
    // MARK: initialization
    init() {
        
    }
    
    
    // MARK: GPRSessionStore
    // open file, encode data, write data, close file
    func writeSession(session: GPRSession) {
        let todaysDate:NSDate = NSDate()
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let DateInFormat:String = dateFormatter.stringFromDate(todaysDate)
        
        print(DateInFormat)
        
        // get the documents folder url
        let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        
        // create the destination url for the text file to be saved
        let fileDestinationUrl = documentDirectoryURL.URLByAppendingPathComponent(DateInFormat + ".gsd")
        
        print(fileDestinationUrl)

        let contents = self.serialize(session)
        print(contents)
            
        do {
            // writing to disk
            try contents.writeToURL(fileDestinationUrl, atomically: true, encoding: NSUTF8StringEncoding)
                
            // saving was successful. any code posterior code goes here
            print("save success")
        } catch let error as NSError {
            print("error writing to url \(fileDestinationUrl)")
            print(error.localizedDescription)
        }
        
    }
    
    // MARK: GPRSessionStore
    func readSession() -> GPRSession? {
        // get the documents folder url
        let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        
        // create the destination url for the text file to be saved
        let fileDestinationUrl = documentDirectoryURL.URLByAppendingPathComponent("file.txt")
        
        // reading from disk
        do {
            let mytext = try String(contentsOfURL: fileDestinationUrl, encoding: NSUTF8StringEncoding)
            
            print(mytext)   // "some text\n"
            
        } catch let error as NSError {
            print("error loading from url \(fileDestinationUrl)")
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    func serialize(session: GPRSession) -> String {
        var str: String
        
        str = "HEADER\n"
        str += "\(session.status)\n"
        str += "\(session.settings.𝚫T)"
        str += "\(session.gprFrequency)"
            
        str += "\(session.startingTime)\n"
        str += "END\n"
            
        str += "LOCATIONS\n"
        
        for location in 0 ..< session.graveLocations.count {
            str += "\(session.graveLocations[location].coordinate)\n"
        }
        
        str += "\(session.origin.coordinate)\n"
        
        str += "END\n"
        
        str += "READINGS\n"
        
        for reading in 0 ..< session.gprReadings.count {
            str += "\(session.gprReadings[reading].data) | "
            str += "\(session.gprReadings[reading].seqNumber) | "
            str += "\(session.gprReadings[reading].stackCount) | "
            str += "\(session.gprReadings[reading].location)\n"
        }
        
        str += "END\n"
        
        
        
        return str
    }

}