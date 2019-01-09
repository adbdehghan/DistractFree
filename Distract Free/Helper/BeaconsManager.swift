//
//  BeaconsManager.swift
//  Distract Free
//
//  Created by adb on 8/25/18.
//  Copyright © 2018 Arena. All rights reserved.
//

import UIKit

class BeaconsManager: NSObject {
    
    var beacons:[Beacon] = [Beacon]()
    
    func SaveBeacons(beacons:[Beacon]) -> Void {
         var bag: [[String: Any]] = []
        
        for beacon in beacons
        {
            bag.append(["identifier": beacon.identifier, "type": beacon.type.rawValue])
            
        }
       
        UserDefaults.standard.set(bag, forKey: "beacons")
        
    }
    
    override init() {
        // getting path to GameData.plist
        if let loadedBeacons = UserDefaults.standard.array(forKey: "beacons") as? [[String: Any]] {
            
            for item in loadedBeacons {
                
                let beacon = Beacon()
                beacon.identifier = item["identifier"] as? String
                beacon.type = BeaconType(rawValue:(item["type"] as! String))
                
                beacons.append(beacon)
                
            }
        }
    }
}
