//
//  Beacon.swift
//  Distract Free
//
//  Created by adb on 2/17/18.
//  Copyright © 2018 Arena. All rights reserved.
//

import UIKit

public enum BeaconType {
    case Driver
    case Passenger
    case BackSeat
    case None
}
class Beacon: NSObject {
    
    var identifier:String!
    var rssi:NSNumber!
    var type:BeaconType!

}
