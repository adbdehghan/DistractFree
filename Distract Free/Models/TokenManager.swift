//
//  FileManager.swift
//  Radio Event
//
//  Created by adb on 1/9/18.
//  Copyright © 2018 Arena. All rights reserved.
//

import UIKit

class TokenManager:NSObject {

    var Token :String = ""
    var Phonenumber :String = ""
    var Password :String = ""
    
    func SaveToken(Phonenumber:String,Token:String,Password:String) -> Void {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths.object(at: 0) as! NSString
        let path = documentsDirectory.appendingPathComponent("LoginData.plist")
        let dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
        
        //saving values
        dict.setObject(Phonenumber, forKey: "Phonenumber" as NSCopying)
        dict.setObject(Token, forKey: "Token" as NSCopying)
        dict.setObject(Password, forKey: "Password" as NSCopying)
        //...
        //writing to LoginData.plist
        dict.write(toFile: path, atomically: false)
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        print("Saved LoginData.plist file is --> \(String(describing: resultDictionary?.description))")
        
        
    }
    
    override init() {
        // getting path to GameData.plist
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! NSString
        let path = documentsDirectory.appendingPathComponent("LoginData.plist")
        
        let fileManager = FileManager.default
        
        //check if file exists
        if(!fileManager.fileExists(atPath: path))
        {
            // If it doesn't, copy it from the default file in the Bundle
            
            if let bundlePath = Bundle.main.path(forResource: "LoginData", ofType: "plist")
            {
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                print("Bundle LoginData.plist file is --> \(resultDictionary?.description)")
                
                do
                {
                    try fileManager.copyItem(atPath: bundlePath, toPath: path)
                    print("copy")
                }
                catch _
                {
                    print("error failed loading data")
                }
            }
            else
            {
                print("LoginData.plist not found. Please, make sure it is part of the bundle.")
            }
        }
        else
        {
            print("LoginData.plist already exits at path.")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        print("Loaded LoginData.plist file is --> \(resultDictionary?.description)")
        let myDict = NSDictionary(contentsOfFile: path)
        
        if let dict = myDict {
            //loading values
            Phonenumber = dict.object(forKey: "Phonenumber")! as! String
            Token = dict.object(forKey: "Token")! as! String
            Password = dict.object(forKey: "Password")! as! String
            //...
        }
        else
        {
            print("WARNING: Couldn't create dictionary from GameData.plist! Default values will be used!")
        }
        
    }
    
}
