//
//  ViewController.swift
//  MovieApp
//
//  Created by Third Eye InfoTech on 03/03/19.
//  Copyright © 2019 Third Eye InfoTech. All rights reserved.
//

import UIKit
import Alamofire


let strBaseUrl = "https://api.themoviedb.org/3/"
let imagebaseURL = "https://image.tmdb.org/t/p/w500"
let API_Key = "14bc774791d9d20b3a138bb6e26e2579"

struct MovieList {
    let title: String!
    let overView: String!
    let ID:String!
    let releaseDate:String!
    let posterPath:String!
}



struct APIName {
    static let DiscoverMovie = "discover/movie"
    static let MovieDetails = "movie/"
}

class ViewController: UIViewController {
    @IBOutlet weak var tblMovie: UITableView!
    
    var arrMovies:[MovieList] = []
    
    var currentPage = 1
    var totalPage = 1
    
    
    var databasePath = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CreateTable()
    }
    
    @IBAction func btnSaveTap(_ sender: Any)
    {
        saveData()
    }
    
    @IBAction func btnGetTap(_ sender: Any)
    {
        searchData()
    }
    
    func CreateTable()
    {
        let filemgr = FileManager.default
        let dirPaths = filemgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        
        databasePath = dirPaths[0].appendingPathComponent("userdetail1.db").path
        
        if !filemgr.fileExists(atPath: databasePath as String) {
            
            let contactDB = FMDatabase(path: databasePath as String)
            
            if contactDB == nil {
                print("Error: \(contactDB?.lastErrorMessage())")
            }
            
            if (contactDB?.open())! {
                let sql_stmt = "CREATE TABLE IF NOT EXISTS USERDETAIL (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, ADDRESS TEXT, PASSWORD TEXT, PIC TEXT)"
                if !(contactDB?.executeStatements(sql_stmt))! {
                    print("Error: \(contactDB?.lastErrorMessage())")
                }
                contactDB?.close()
            } else {
                print("Error: \(contactDB?.lastErrorMessage())")
            }
        }
    }
    
    func saveData()
    {
        let contactDB = FMDatabase(path: databasePath as String)
        
        let name = "Vivek1"
        let address = "Jodhpur"
        let password = "123456"
        
        let imgU = UIImage.init(named: "s")
        let imgData = imgU!.jpegData(compressionQuality: 0.5)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // choose a name for your image
        let time:Int = Int(Date().timeIntervalSince1970)
        let fileName = "\(time).jpg"
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if let data = imgData,
            !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
        
        
        
        if (contactDB?.open())! {
            
            let insertSQL = "INSERT INTO USERDETAIL (name, address, password, pic) VALUES ('\(name)', '\(address)', '\(password)', '\(fileURL.path)')"
            
            let result = contactDB?.executeUpdate(insertSQL,
                                                  withArgumentsIn: nil)
            
            if !result! {
                
                print("Error: \(contactDB?.lastErrorMessage())")
            } else {
                print("Added")
            }
        } else {
            print("Error: \(contactDB?.lastErrorMessage())")
        }
    }
    
    func searchData()
    {
        let contactDB = FMDatabase(path: databasePath as String)
        
        let name = "Vivek1"
        
        if (contactDB?.open())! {
            let querySQL = "SELECT * FROM USERDETAIL WHERE name = '\(name)'"
            
            let results:FMResultSet? = contactDB?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
            
            if results?.next() == true {
                let address = results?.string(forColumn: "address")
                let password = results?.string(forColumn: "password")
                let name = results?.string(forColumn: "name")
                let pic = results?.string(forColumn: "pic")
                print("Found \(address) \(password) \(name) \(pic)")
            } else {
                print("Not Found")
            }
            contactDB?.close()
        } else {
            print("Error: \(contactDB?.lastErrorMessage())")
        }
    }

    
}

