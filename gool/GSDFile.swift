//
//  GPRFileWriter.swift
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
    func writeSession(session: GPRSession?) {
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

        let contents = session?.toJsonString()
        
        print(contents)
        
//        do {
//            // writing to disk
//            try contents.writeToURL(fileDestinationUrl, atomically: true, encoding: NSUTF8StringEncoding)
//            
//            // saving was successful. any code posterior code goes here
//            
//        } catch let error as NSError {
//            print("error writing to url \(fileDestinationUrl)")
//            print(error.localizedDescription)
//        }
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

}