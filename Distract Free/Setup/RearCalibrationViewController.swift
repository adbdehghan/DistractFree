//
//  RearCalibrationViewController.swift
//  Distract Free
//
//  Created by adb on 3/18/18.
//  Copyright © 2018 Arena. All rights reserved.
//

import UIKit
import Bluetonium
import ZAlertView
import RSLoadingView

class RearCalibrationViewController: UIViewController,ManagerDelegate {
    let bleManager = Manager()
    var beacons:[Beacon]!
    var driverBeacon:Beacon!
    var passengerBeacon:Beacon!
    var backSeatBc:Beacon!
    let loadingView = RSLoadingView()
    var counter:Int = 0
    var timeSecond:Int = 0
    var isFounded:Bool = false
    var timer:Timer = Timer()
    var backSeatDistanceArray:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let glbData = GlobalData.sharedInstance
        
        beacons = [Beacon]()
        beacons.append((glbData.backSeatBeacon))
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
            case .driving:
                driverBeacon = beacon
            case .front:
                passengerBeacon = beacon
            case .rear:
                backSeatBc = beacon
            case .none:
                passengerBeacon = nil
                driverBeacon = nil
            }
            
            if backSeatBc != nil {
                
                isFounded = true
                
                let backSeatDistance = calculateNewDistance(txCalibratedPower: 60, rssi: backSeatBc?.rssi as! Int)
                
                backSeatDistanceArray.add(backSeatDistance)
                
                if counter == 15
                {
                    let backSeatArr:[Double] = NSArray(array:backSeatDistanceArray) as! [Double]
                    let backSeatSum = backSeatArr.reduce(0, +) / (Double(counter))
                    
                    CalibrationManager().SaveCalibValues(Driver: CalibrationManager().driverCalibValue, Passenger: CalibrationManager().passengerCalibValue, BackSeat: backSeatSum)
                    
                    let glbData = GlobalData.sharedInstance
                    glbData.driverBeacon.calibrationValue = CalibrationManager().driverCalibValue
                    glbData.passengerBeacon.calibrationValue = CalibrationManager().passengerCalibValue
                    glbData.backSeatBeacon.calibrationValue = CalibrationManager().backSeatCalibValue
                    bleManager.stopScanForDevices()
                    RSLoadingView.hide(from: view)
                    performSegue(withIdentifier: "next", sender: self)
                }
                
                counter+=1
                
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
        
    }
    
    @IBAction func NextButtonEvent(_ sender: Any) {
        
        loadingView.show(on: view)
        bleManager.delegate = self
        bleManager.startScanForDevices(advertisingWithServices: nil)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        
        timeSecond += 1
        
        if timeSecond == 15 && !isFounded
        {
            RSLoadingView.hide(from: view)
            //Reset Values
            timer.invalidate()
            counter = 0
            timeSecond = 0
            bleManager.stopScanForDevices()
            
            
            ///Show alert that beacon not found
            var message:String = ""
            
            if  backSeatBc == nil
            {
                message = "Back seat beacon is not in range"
            }
            
            let dialog = ZAlertView(title: "🙄", message: message , closeButtonText: "OK",closeButtonHandler:{alertView in
                
                alertView.dismissAlertView()
            })
            
            dialog.show()
        }
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

