//
//  LocalDatabase.swift
//  HiteshPractical
//
//  Created by MAC on 3/1/19.
//  Copyright © 2019 MAC. All rights reserved.
//

import Foundation
class FMDBAccessor: NSObject {
    
    
    //sharedInstance
    static let sharedInstance = FMDBAccessor()
    
        func CreateDataBase() -> URL? {
        
        let fileManager = FileManager.default
        
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        if let documentDirectory:URL = urls.first { // No use of as? NSURL because let urls returns array of NSURL
            
            // exclude cloud backup
            do {
                try (documentDirectory as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
            } catch _{
                print("Failed to exclude backup")
            }
            
            // This is where the database should be in the documents directory
            let finalDatabaseURL = documentDirectory.appendingPathComponent("MovieDB.db")
            
            if (finalDatabaseURL as NSURL).checkResourceIsReachableAndReturnError(nil) {
                // The file already exists, so just return the URL
                return finalDatabaseURL
            } else {
                // Copy the initial file from the application bundle to the documents directory
                if let bundleURL = Bundle.main.url(forResource: "MovieDB", withExtension: "db") {
                    
                    do {
                        
                        try fileManager.copyItem(at: bundleURL, to: finalDatabaseURL)
                    } catch _ {
                        print("Couldn't copy file to final location!")
                    }
                    
                } else {
                    print("Couldn't find initial database in the bundle!")
                }
            }
        } else {
            print("Couldn't get documents directory!")
        }
        
        return nil
    }
    
    
    
        func methodToInsertUpdateDeleteData(_ strQuery : String,completion: @escaping (_ result: Bool) -> Void)
        {
            print("Query: \(strQuery)")
            let contactDB = FMDatabase(path: String(CreateDataBase()!.absoluteString) )
            
            if (contactDB?.open())! {
                
                let insertSQL = strQuery
                
                let result = contactDB?.executeUpdate(insertSQL,
                    withArgumentsIn: nil)
                
                if !result! {
                    print("Failed to add")
                    print("Error: \(String(describing: contactDB?.lastErrorMessage()))")
                    completion(false)
                    
                } else {
                    print("Added")
                    completion(true)
                    
                }
            } else {
                print("Error: \(String(describing: contactDB?.lastErrorMessage()))")
                completion(false)
               
            }

        }

    
    func methodToSelectData(_ strQuery : String,completion: @escaping (_ result: NSMutableArray) -> Void)
    {
        
        let arryToReturn : NSMutableArray = []
        
        let contactDB = FMDatabase(path: String(CreateDataBase()!.absoluteString) )
        
        if (contactDB?.open())! {
            let querySQL = strQuery
            
            let results:FMResultSet? = contactDB?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
            
            while results?.next() == true
            {
                arryToReturn.add(results!.resultDictionary())
            }            
            completion(arryToReturn)
            contactDB?.close()
        } else {
            print("Error: \(String(describing: contactDB?.lastErrorMessage()))")
        }
        
        completion(arryToReturn)
        
    }

    
}
