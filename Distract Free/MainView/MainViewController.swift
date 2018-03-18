//
//  MainViewController.swift
//  Distract Free
//
//  Created by adb on 2/13/18.
//  Copyright © 2018 Arena. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftLocation
import Bluetonium
import CoreLocation
import AEXML

class MainViewController: UIViewController,CLLocationManagerDelegate,ManagerDelegate {
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var beaconStatus: UILabel!
    @IBOutlet weak var beaconStatusContainer: UIView!
    @IBOutlet weak var beaconStatusBackgroundView: UIView!
    let manager = CLLocationManager()
    var currentSpeed = 0.0
    var mapView:GMSMapView!
    let bleManager = Manager()
    var beacons:[Beacon]!
    var driverBeacon:Beacon!
    var passengerBeacon:Beacon!
    var backSeatBc:Beacon!
    var appMode:BeaconType!
    var filter = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 1)
    var counter = 0
    var rssiArray:[Double]!
    var cameraUpdated:Bool = false
    var driverDistance:Double = 0
    var passengerDistance:Double = 0
    var backSeatDistance:Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UICustomization()
        InitMap()
        LocationInitializer()
        
        let glbData = GlobalData.sharedInstance
        
        beacons = [Beacon]()

        beacons.append((glbData.driverBeacon))
        beacons.append((glbData.passengerBeacon))
        beacons.append((glbData.backSeatBeacon))
        
        rssiArray = [Double]()
        bleManager.delegate = self
        bleManager.startScanForDevices(advertisingWithServices: nil)
    }
    
    
    func LocationInitializer()
    {
        Locator.requestAuthorizationIfNeeded(.always)
        
        Locator.subscribePosition(accuracy: .block, onUpdate:{ loc in
            
            let speed = Double((loc.speed))
            
            if speed > 0.0
            {
                DispatchQueue.main.async {
                    self.speedLabel.text = String(format: "%d",Int((loc.speed) * 2.2))
                }
           
            }
            if !self.cameraUpdated
            {
                self.cameraUpdated = true
                
                let camera = GMSCameraPosition.camera(withLatitude:(loc.coordinate.latitude),
                                                      longitude: (loc.coordinate.longitude),
                                                      zoom: 18)
                self.mapView.camera = camera
            }
        },onFail: { err, last in
            print("Failed with error: \(err)")
        })
    }
    
    func UICustomization()
    {
        beaconStatusContainer.layer.cornerRadius = 6
        beaconStatusBackgroundView.layer.cornerRadius = 6
    }
    
    func InitMap()
    {
        let camera = GMSCameraPosition.camera(withLatitude: 35.6961, longitude: 51.4231, zoom: 18.0)
        mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        mapView.isMyLocationEnabled = true
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        self.view.addSubview(mapView)
        view.sendSubview(toBack: mapView)
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
                bleManager.connect(with: device)
            case .None:
                passengerBeacon = nil
                driverBeacon = nil
                backSeatBc = nil
            }
            
            if driverBeacon != nil && passengerBeacon != nil && backSeatBc != nil  {
                
                 driverDistance = calculateNewDistance(txCalibratedPower: 60, rssi: driverBeacon?.rssi as! Int)
                 passengerDistance = calculateNewDistance(txCalibratedPower: 60, rssi: passengerBeacon?.rssi as! Int)
                 backSeatDistance = calculateNewDistance(txCalibratedPower: 60, rssi: backSeatBc?.rssi as! Int)
                
                
                
//                let date = Date()
//                let calendar = Calendar.current
//                let minutes = calendar.component(.minute, from: date)
//                let seconds = calendar.component(.second, from: date)
//                let miliSeconds = calendar.component(.nanosecond, from: date)
//
//                let soapRequest = AEXMLDocument()
//                let attributes = ["Time" : String(minutes) + ":" + String(seconds) + ":" + String(miliSeconds) ]
//                let envelope = soapRequest.addChild(name: "BeaconsData", attributes: attributes)
//                let driver = envelope.addChild(name: "DriverBeacon")
//                let passenger = envelope.addChild(name: "PassengerBeacon")
//                let backseat = envelope.addChild(name: "BackSeatBeacon")
//                driver.addChild(name: "Distance", value: String(driverDistance))
//                passenger.addChild(name: "Distance", value: String(passengerDistance))
//                backseat.addChild(name: "Distance", value: String(backSeatDistance))
//
//                // prints the same XML structure as original
//                print(soapRequest.xml)
                self.beaconStatusContainer.backgroundColor = .green
                UpdateBeaconStatusLabel(beacon: DetermineZone())
             
            }
            else
            {
                self.beaconStatusContainer.backgroundColor = .red
                UpdateBeaconStatusLabel(beacon: BeaconType.None)
            }
        }
    }
    
    func manager(_ manager: Manager, willConnectToDevice device: Device) {
        
    }
    
    func manager(_ manager: Manager, connectedToDevice device: Device) {
//        self.beaconStatusContainer.backgroundColor = .green
    }
    
    func manager(_ manager: Manager, disconnectedFromDevice device: Device, willRetry retry: Bool) {
     
        UpdateBeaconStatusLabel(beacon: BeaconType.None)
    }
    
    func manager(_ manager: Manager, RSSIUpdated device: Device) {

    }
    
    func UpdateBeaconStatusLabel(beacon:BeaconType)
    {        
        DispatchQueue.main.async {
          
            switch beacon {
            case .Driver:
                self.beaconStatus.text = "Driver"
                self.appMode = BeaconType.Driver
                
            case .Passenger:
                    self.beaconStatus.text = "Passenger"
                    self.appMode = BeaconType.Passenger
            case .BackSeat:
                self.beaconStatus.text = "Back Seat"
                self.appMode = BeaconType.BackSeat
            default:
                self.beaconStatus.text = "None"
                self.appMode = BeaconType.None
            }
        }
    }
    
    func DetermineZone() -> BeaconType
    {
        var type:BeaconType!
        let driverCalibValue = GlobalData.sharedInstance.driverBeacon.calibrationValue
        let passengerCalibValue = GlobalData.sharedInstance.passengerBeacon.calibrationValue
        let backSeatCalibValue = GlobalData.sharedInstance.backSeatBeacon.calibrationValue
        
        if driverDistance < driverCalibValue! + 0.1
        {
            type = .Driver
        }
        else if passengerDistance < passengerCalibValue! + 0.05
        {
            type = .Passenger
        }
        else if backSeatDistance < backSeatCalibValue! + 0.05
        {
            type = .BackSeat
        }
        else
        {
            type = .None
        }
        return type
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        bleManager.stopScanForDevices()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}
