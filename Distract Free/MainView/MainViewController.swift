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

    @IBOutlet weak var rearStatusView: UIView!
    @IBOutlet weak var passengerStatusView: UIView!
    @IBOutlet weak var driverStatusView: UIView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var beaconStatus: UILabel!
    @IBOutlet weak var beaconStatusContainer: UIView!
    @IBOutlet weak var beaconStatusBackgroundView: UIView!
    let manager = CLLocationManager()
    var currentSpeed:Double = 0
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
    var speedString:String = "0"
    var latitiude:Double = 0
    var longitude:Double = 0
    var globalSpeed = 0.0
    var commandIntervalTimer:Timer!
    var isCommandSent = false
    var timeInterval = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIDevice.current.isBatteryMonitoringEnabled = true
        UICustomization()
        InitMap()
        LocationInitializer()
        commandIntervalTimer = Timer()
        
        let glbData = GlobalData.sharedInstance
        
        beacons = [Beacon]()

//        let beacon = Beacon()
//        beacon.identifier = "81B516AD-449B-0BD7-66D5-3BF23FDDAAB7"
//        beacon.type = BeaconType.driving
//        beacons.append(beacon)
        beacons.append((glbData.driverBeacon))
        beacons.append((glbData.passengerBeacon))
        beacons.append((glbData.backSeatBeacon))
        
        rssiArray = [Double]()
        bleManager.delegate = self
        bleManager.startScanForDevices(advertisingWithServices: nil)
        
        StartSendData()        
    }
    
    func LocationInitializer()
    {
        Locator.requestAuthorizationIfNeeded(.always)
        
        Locator.subscribePosition(accuracy: .block, onUpdate:{ loc in
            
            self.latitiude = Double(loc.coordinate.latitude)
            self.longitude = Double(loc.coordinate.longitude)
            
            let speed = Double((loc.speed)) * 2.2
            self.globalSpeed = speed
            
            if speed > 0.0
            {
                self.currentSpeed = speed
                DispatchQueue.main.async {
                    self.speedLabel.text = String(format: "%d",Int(speed))
                }
                
                if speed >= 5 && self.appMode == BeaconType.driving
                {
                    if self.isCommandSent
                    {
                        self.commandIntervalTimer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: false)
                        self.isCommandSent = false
                    }
                    
                    
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
    
    @objc func timerAction()
    {
        timeInterval = 10
        isCommandSent = true
        self.beacons.first?.device.peripheral.discoverServices(nil)
    }
    
    func UICustomization()
    {
        driverStatusView.layer.cornerRadius = 4
        passengerStatusView.layer.cornerRadius = 4
        rearStatusView.layer.cornerRadius = 4
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
            case .driving:
                driverBeacon = beacon
                driverBeacon.device = device
                driverStatusView.backgroundColor = .green
                bleManager.connect(with: device)
            case .front:
                passengerBeacon = beacon
                passengerBeacon.device = device
                passengerStatusView.backgroundColor = .green
                bleManager.connect(with: device)
            case .rear:
                backSeatBc = beacon
                backSeatBc.device = device
                rearStatusView.backgroundColor = .green
                bleManager.connect(with: device)
            case .none:
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
                UpdateBeaconStatusLabel(beacon: BeaconType.none)
            }
        }
    }
    
    func manager(_ manager: Manager, willConnectToDevice device: Device) {
        
    }
    
    
    func manager(_ manager: Manager, connectedToDevice device: Device) {
//        self.beaconStatusContainer.backgroundColor = .green
        
 
     
        device.peripheral.discoverServices(nil)
        
        
    }
//    00001523-1212-EFDE-1523-785FEABCD123
    
    func manager(_ manager: Manager, disconnectedFromDevice device: Device, willRetry retry: Bool) {
     
        let beacon = CheckBLE(device: device)
        
        if beacon != nil {
            
            beacon?.rssi = device.rssi
            
            switch (beacon?.type)! {
            case .driving:
                driverStatusView.backgroundColor = .red
            case .front:
                passengerStatusView.backgroundColor = .red
            case .rear:
                rearStatusView.backgroundColor = .red
            case .none:
                break
            }
        }
        
//        UpdateBeaconStatusLabel(beacon: BeaconType.none)
    }
    
    func manager(_ manager: Manager, RSSIUpdated device: Device) {

    }
    
    func UpdateBeaconStatusLabel(beacon:BeaconType)
    {        
        DispatchQueue.main.async {
          
            switch beacon {
            case .driving:
                self.beaconStatus.text = "Driver"
                self.appMode = BeaconType.driving
                
            case .front:
                self.beaconStatus.text = "Passenger"
                self.appMode = BeaconType.front
            case .rear:
                self.beaconStatus.text = "Rear Seat"
                self.appMode = BeaconType.rear
            default:
                self.beaconStatus.text = "None"
                self.appMode = BeaconType.none
            }
        }
    }
    
    func DetermineZone() -> BeaconType
    {
        var type:BeaconType!
        
        if driverDistance - 0.2 < passengerDistance && driverDistance - 0.2 < backSeatDistance
        {
            type = .driving
            bleManager.connect(with: driverBeacon.device)
        }
        else if passengerDistance < driverDistance && passengerDistance < backSeatDistance
        {
            type = .front
            bleManager.connect(with: passengerBeacon.device)
        }
        else if backSeatDistance < driverDistance && backSeatDistance < passengerDistance
        {
            type = .rear
            bleManager.connect(with: backSeatBc.device)
        }
        else
        {
            self.beaconStatusContainer.backgroundColor = .red
            type = .none
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
    
    func StartSendData()
    {
        Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.SendData), userInfo: nil, repeats: true)
    }
    
    @objc func SendData()
    {
        let distances = [String(driverDistance),String(passengerDistance),String(backSeatDistance)]
        let manager = DataManager()
        
        manager.PostRecords(dateTime: getTodayString(), speed: currentSpeed, latitude: latitiude, longitude: longitude, phoneBattery: Int(UIDevice.current.batteryLevel * 100), userState: self.appMode == nil ? "none" : self.appMode.rawValue, blutoothState: bleManager.bluetoothEnabled, gpsState: true, beacons: [], distances: [], completion: {(APIResponse)-> Void in
            
        })
    }
    
    func getTodayString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
        
        return today_string
        
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
