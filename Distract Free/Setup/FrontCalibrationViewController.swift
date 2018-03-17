//
//  FrontCalibrationViewController.swift
//  Distract Free
//
//  Created by adb on 3/18/18.
//  Copyright © 2018 Arena. All rights reserved.
//

import UIKit
import Bluetonium
import ZAlertView
import RSLoadingView

class FrontCalibrationViewController: UIViewController,ManagerDelegate {
    let bleManager = Manager()
    var beacons:[Beacon]!
    var driverBeacon:Beacon!
    var passengerBeacon:Beacon!
    var backSeatBc:Beacon!
    let loadingView = RSLoadingView()
    var counter:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let glbData = GlobalData.sharedInstance
        
        beacons = [Beacon]()
        //        var driverBeacon1 = Beacon()
        //        var passengerBeacon2 = Beacon()
        let backBeacon = Beacon()
        //        backBeacon.identifier = "18018701-88C5-1368-73C7-30D07905E6B4"
        //        backBeacon.type = BeaconType.Driver
        //        backBeacon.identifier = "9E0C8526-EFA8-999C-55AF-CD30D347BDB8"
        //        backBeacon.type = BeaconType.BackSeat
        //        beacons.append(backBeacon)
        //        beacons.append(passengerBeacon2)
        beacons.append((glbData.driverBeacon))
        beacons.append((glbData.passengerBeacon))

    }
    
    func CheckBLE(device:Device) -> Beacon?
    {
        var beacon:Beacon? = nil
        for item in beacons {
            
            if device.peripheral.identifier.uuidString == item.identifier
            {
                beacon = item
            }
        }
        return beacon
    }
    
    func manager(_ manager: Manager, didFindDevice device: Device) {
        
        let beacon = CheckBLE(device: device)
        
        if beacon != nil {
                
            beacon?.rssi = device.rssi
            
            switch (beacon?.type)! {
            case .Driver:
                driverBeacon = beacon
            case .Passenger:
                passengerBeacon = beacon
            case .BackSeat:
                backSeatBc = beacon
            case .None:
                passengerBeacon = nil
                driverBeacon = nil
            }
            
            if driverBeacon != nil && passengerBeacon != nil  {
                
                let driverDistance = calculateNewDistance(txCalibratedPower: 60, rssi: driverBeacon?.rssi as! Int)
                let passengerDistance = calculateNewDistance(txCalibratedPower: 60, rssi: passengerBeacon?.rssi as! Int)

                counter+=1
                
                if counter == 10
                {
                    RSLoadingView.hide(from: view)
                    shouldPerformSegue(withIdentifier: "next", sender: self)
                }
         
            }            
        }
    }
    
    func manager(_ manager: Manager, willConnectToDevice device: Device) {
        
    }
    
    func manager(_ manager: Manager, connectedToDevice device: Device) {
        
    }
    
    func manager(_ manager: Manager, disconnectedFromDevice device: Device, willRetry retry: Bool) {
        
        
    }
    
    func manager(_ manager: Manager, RSSIUpdated device: Device) {
        let beacon = CheckBLE(device: device)
        
        if beacon != nil {
            beacon?.rssi = device.rssi
        }
        
        let beacon1 = beacons.first
        let beacon2 = beacons.last
        
        if beacon1?.rssi != nil && beacon2?.rssi != nil{
            
            let driverDistance = calculateNewDistance(txCalibratedPower: 60, rssi: beacon1?.rssi as! Int)
            let passengerDistance = calculateNewDistance(txCalibratedPower: 60, rssi: beacon2?.rssi as! Int)
            
      
        }

    }
    
    @IBAction func NextButtonEvent(_ sender: Any) {
        
        loadingView.show(on: view)
        bleManager.delegate = self
        bleManager.startScanForDevices(advertisingWithServices: nil)
        
    }
    
    func calculateNewDistance(txCalibratedPower: Int, rssi: Int) -> Double{
        if rssi == 0 {
            return -1
        }
        let ratio = Double(exactly:rssi)!/Double(txCalibratedPower)
        if ratio < 1.0{
            return pow(ratio, 10.0)
        }else{
            let accuracy = 0.89976 * pow(ratio, 7.7095) + 0.111
            return accuracy
        }
        
    }
    
    @IBAction func BackButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
