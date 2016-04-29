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
        
        // get the documents folder url
        let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        
        // create the destination url for the text file to be saved
        let fileDestinationUrl = documentDirectoryURL.URLByAppendingPathComponent(DateInFormat + ".gsd")

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
    func readSession(fileName: String) -> GPRSession? {
        // get the documents folder url
        let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        
        // create the destination url for the text file to be saved
        let fileDestinationUrl = documentDirectoryURL.URLByAppendingPathComponent(fileName + ".gsd")
        
        // reading from disk
        do {
            let mytext = try String(contentsOfURL: fileDestinationUrl, encoding: NSUTF8StringEncoding)
            
            print(mytext)   // "some text\n"
            
            let session = self.deserialize(mytext)
            
            return session
            
        } catch let error as NSError {
            print("error loading from url \(fileDestinationUrl)")
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    func listFiles() -> [String?] {
        // We need just to get the documents folder url
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        
        do {
            let directoryUrls = try  NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
            
            print(directoryUrls)
            
            let files = directoryUrls.filter{ $0.pathExtension == "gsd" }.map{ $0.lastPathComponent }
            
            print("GSD FILES:\n" + files.description)
            
            return files
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return [nil]
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
        
        str += "TRACExLOCATION\n"
        
        for trace in 0 ..< session.traceByLocation.count {
            str += "\(session.traceByLocation[session.gprReadings[trace].location!]?.data) | "
            str += "\(session.traceByLocation[session.gprReadings[trace].location!]?.seqNumber) | "
            str += "\(session.traceByLocation[session.gprReadings[trace].location!]?.stackCount) | "
            str += "\(session.traceByLocation[session.gprReadings[trace].location!]?.location)\n"
        }
        
        str += "END\n"
        
        str += "LOCATIONxSEQNO\n"
        
        for seqno in 0 ..< session.locationBySeqNo.count {
            str += "\(session.gprReadings[seqno].seqNumber) | "
            str += "\(session.locationBySeqNo[session.gprReadings[seqno].seqNumber])\n"
        }
        
        str += "END\n"
        
        str += "RESULTS\n"
        
        for seqno in 0 ..< session.locationBySeqNo.count {
            str += "\(session.gprReadings[seqno].seqNumber) | "
            str += "\(session.gprResults[session.gprReadings[seqno].seqNumber])\n"
        }
        
        str += "END\n"
        
        
        
        return str
    }
    
    func deserialize(str: String?) -> GPRSession? {
        let session: GPRSession?
        
        return nil
    }

}