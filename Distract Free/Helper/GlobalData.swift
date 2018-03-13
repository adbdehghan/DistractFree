//
//  GlobalData.swift
//  Distract Free
//
//  Created by adb on 2/19/18.
//  Copyright © 2018 Arena. All rights reserved.
//

import UIKit

class GlobalData: NSObject {
    static let sharedInstance = GlobalData()
    var driverBeacon:Beacon = Beacon()
    var passengerBeacon:Beacon = Beacon()
}