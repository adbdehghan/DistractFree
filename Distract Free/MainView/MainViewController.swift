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
    
    
    
    @IBOutlet weak var speedBackLayer: UIView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var SpeedContainerView: UIView!
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
    
    //    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UICustomization()
        InitMap()
        LocationInitializer()
        
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
        SpeedContainerView.layer.cornerRadius = SpeedContainerView.frame.width/2
        speedBackLayer.layer.cornerRadius = speedBackLayer.frame.width/2
        beaconStatusContainer.layer.cornerRadius = beaconStatusContainer.frame.width/2
        beaconStatusBackgroundView.layer.cornerRadius = beaconStatusBackgroundView.frame.width/2
        
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
            
            self.beaconStatusContainer.backgroundColor = .green
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
//                let backSeatDistance = calculateNewDistance(txCalibratedPower: 60, rssi: passengerBeacon?.rssi as! Int)
                
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
                
                if driverDistance < passengerDistance
                {
                    UpdateBeaconStatusLabel(beacon: (driverBeacon?.type)!)
                }
                else
                {
                    UpdateBeaconStatusLabel(beacon: (passengerBeacon?.type)!)
                }
            }
            else if driverBeacon?.rssi != nil
            {
                UpdateBeaconStatusLabel(beacon: (driverBeacon?.type)!)
            }
            else if passengerBeacon?.rssi != nil
            {
                UpdateBeaconStatusLabel(beacon: (passengerBeacon?.type)!)
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
        self.beaconStatusContainer.backgroundColor = .green
    }
    
    func manager(_ manager: Manager, disconnectedFromDevice device: Device, willRetry retry: Bool) {
     
        UpdateBeaconStatusLabel(beacon: BeaconType.None)
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
            
            if driverDistance > passengerDistance
            {
                UpdateBeaconStatusLabel(beacon: (beacon1?.type)!)
            }
            else
            {
                UpdateBeaconStatusLabel(beacon: (beacon2?.type)!)
            }
        }
        else if beacon1?.rssi != nil
        {
            UpdateBeaconStatusLabel(beacon: (beacon1?.type)!)
        }
        else if beacon2?.rssi != nil
        {
            UpdateBeaconStatusLabel(beacon: (beacon2?.type)!)
        }
        else
        {
            UpdateBeaconStatusLabel(beacon: BeaconType.None)
        }
        //        let prediction = filter.predict(stateTransitionModel: 1, controlInputModel: 0, controlVector: 0, covarianceOfProcessNoise: 0)
        //        let update = prediction.update(measurement: device.rssi.doubleValue, observationModel: 1, covarienceOfObservationNoise: 0.1)
        //
        //        filter = update
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
            default:
                self.beaconStatus.text = "None"
                self.appMode = BeaconType.None
            }
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
