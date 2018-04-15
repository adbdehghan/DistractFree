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
class Beacon: NSObject {
    
    var identifier:String!
    var rssi:NSNumber!
    var type:BeaconType!
    var calibrationValue:Double!
    var device:Device!

}
