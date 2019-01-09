//
//  Beacon.swift
//  Distract Free
//
//  Created by adb on 2/17/18.
//  Copyright © 2018 Arena. All rights reserved.
//

import UIKit
import Bluetonium
public enum BeaconType: String {
    case driving
    case front
    case rear
    case none
}
class Beacon: NSObject{
    
//
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(name,forKey: "name")
//        aCoder.encode(identifier,forKey: "identifier")
//        aCoder.encode(type,forKey: "type")
//        aCoder.encode(calibrationValue,forKey: "calibrationValue")
//        aCoder.encode(device,forKey: "device")
//        aCoder.encode(Updated,forKey: "Updated")
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//
//        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
//        self.identifier = aDecoder.decodeObject(forKey: "identifier") as? String ?? ""
//        self.rssi = aDecoder.decodeObject(forKey: "rssi") as? NSNumber ?? nil
//        self.type = aDecoder.decodeObject(forKey: "type") as? BeaconType ?? BeaconType.none
//        self.calibrationValue = aDecoder.decodeDouble(forKey: "calibrationValue")
//        self.device = aDecoder.decodeObject(forKey: "device") as? Device ?? nil
//        self.Updated = aDecoder.decodeBool(forKey: "Updated")
//    }
//
    var name:String!
    var identifier:String!
    var rssi:NSNumber!
    var type:BeaconType!
    var calibrationValue:Double!
    var device:Device!
    var Updated = false

}
