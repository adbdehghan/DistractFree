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
import TCPickerView
import ZAlertView

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
    var isCommandSent = true
    var isUpdated = false
    var isTestMode = false
    var disconnectMode = false
    var timeInterval = 1.0
    let picker = TCPickerView()
    var bleList:Array<Any>!
    var locationRequest:LocationRequest!
    var locationIsUpdating = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        beacons = [Beacon]()
        let glbData = GlobalData.sharedInstance
        beacons = glbData.beacons
        
        rssiArray = [Double]()
        bleManager.delegate = self
        bleManager.startScanForDevices(advertisingWithServices: nil)
        
        if !bleManager.bluetoothEnabled
        {
            ShowEnableBLEAlert()
        }
        
        UICustomization()
        InitMap()
        LocationInitializer()
        commandIntervalTimer = Timer()
        StartSendData()
    }
    
    func LocationInitializer()
    {
        locationIsUpdating = true
        Locator.requestAuthorizationIfNeeded(.always)
        Locator.backgroundLocationUpdates = true
        
        locationRequest = Locator.subscribePosition(accuracy: .block, onUpdate:{ loc in
            
            self.latitiude = Double(loc.coordinate.latitude)
            self.longitude = Double(loc.coordinate.longitude)
            
            let speed = Double((loc.speed)) * 2.2
            self.globalSpeed = speed
            
            if self.isTestMode
            {
                DispatchQueue.main.async {
                    self.speedLabel.text = "👻"
                }
                
                if self.isCommandSent
                {
                    self.commandIntervalTimer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: false)
                    self.isCommandSent = false
                }
            }
            
            if speed > 0.0 && !self.isTestMode
            {
                self.currentSpeed = speed
                DispatchQueue.main.async {
                    self.speedLabel.text = String(format: "%d",Int(speed))
                }
                
                if speed >= 10 && self.appMode == BeaconType.driving
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
    
    @IBAction func ShowBLEList(_ sender: Any) {
        bleList = bleManager.foundDevices
        picker.title = "BLE List"
        picker.values = bleManager.foundDevices.map{TCPickerView.Value(title: ($0.peripheral.name ?? "no name") + ": " + $0.peripheral.identifier.uuidString)}
        picker.selection = .none
        picker.mainColor = UIColor.init(red: 235.0/255.0, green: 38.0/255.0, blue: 115.0/255.0, alpha: 1)
        picker.show()
    }
    
    @objc func timerAction()
    {
        timeInterval = 10
        isCommandSent = true
        if self.driverBeacon != nil {
            if self.driverBeacon.device != nil
            {
                self.driverBeacon.device.peripheral.discoverServices(nil)
//                bleManager.startScanForServices(device: self.driverBeacon.device)
            }
        }
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

    func CheckBLEWithName(device:Device) -> Beacon?
    {
        var beacon:Beacon? = nil
        for item in beacons {
            if device.peripheral.name?.lowercased() != nil
            {
                if device.peripheral.name?.lowercased() == item.identifier.lowercased()
                {
                    beacon = item
                    beacon?.device = device
                }
            }
        }
        return beacon
    }
    
    func manager(_ manager: Manager, didFindDevice device: Device) {
        
        let name = (device.peripheral.name ?? "no name") + ": " + device.peripheral.identifier.uuidString
        
        if !picker.values.contains(where: {$0.title == name}) {
            picker.values = bleManager.foundDevices.map{TCPickerView.Value(title: ($0.peripheral.name ?? "no name") + ": " + $0.peripheral.identifier.uuidString)}
        }
        
        let beacon = CheckBLEWithName(device: device)
        
        if beacon != nil {
            
            beacon?.rssi = device.rssi
            
            switch (beacon?.type)! {
            case .driving:
                driverBeacon = beacon
                driverStatusView.backgroundColor = .green
                driverBeacon.device.peripheral.delegate = bleManager
                if !disconnectMode
                {
                    bleManager.connect(with: device)
                }
            case .front:
                passengerBeacon = beacon
                passengerStatusView.backgroundColor = .green
                bleManager.connect(with: device)
            case .rear:
                backSeatBc = beacon
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
                
                self.beaconStatusContainer.backgroundColor = .green
                
                if  !isUpdated
                {
                    self.isUpdated = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                        self.UpdateBeaconStatusLabel(beacon: self.DetermineZone())
                    })
                }
                
            }
            else
            {
                self.beaconStatusContainer.backgroundColor = UIColor.init(red: 255/255.0, green: 38/255.0, blue: 115/255.0, alpha: 0.9)
                UpdateBeaconStatusLabel(beacon: BeaconType.none)
            }
        }
        else
        {
            self.beaconStatusContainer.backgroundColor = UIColor.init(red: 255/255.0, green: 38/255.0, blue: 115/255.0, alpha: 0.9)
            UpdateBeaconStatusLabel(beacon: BeaconType.none)
        }
    }
    
    @IBAction func DisconnectManually(_ sender: Any) {
    
        disconnectMode = !disconnectMode
        if disconnectMode
        {
            bleManager.disconnectFromDevice()
            bleManager.stopScanForDevices()
        }
        else
        {
            let dialog = ZAlertView(title: "🤖", message: "Start Connecting" , closeButtonText: "OK",closeButtonHandler:{alertView in
                self.bleManager.startScanForDevices()
                alertView.dismissAlertView()
            })
            dialog.show()
        }
        
    }
    
    @IBAction func ToggleKeyboardEvent(_ sender: Any) {
        
  
        bleManager.mangeKeyboard = true
        
            let dialog = ZAlertView(title: "👻", message: "Do you want to use your keyboard? (If NO until you are in the car, keyboard will not popup!)" , closeButtonText: "OK",closeButtonHandler:{alertView in
                let textField = alertView.getTextFieldWithIdentifier("1")
                if textField?.text?.lowercased() == "no"
                {
                    Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.SendKeyboardCommand), userInfo: nil, repeats: false)
                }
                alertView.dismissAlertView()
            })
        
        dialog.addTextField("1", placeHolder: "Say Yes or No...")
        dialog.show()
        
        let textField = dialog.getTextFieldWithIdentifier("1")
        textField?.becomeFirstResponder()
        
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.SendKeyboardCommand), userInfo: nil, repeats: false)
        
    }
    
    @objc func SendKeyboardCommand()
    {
        if self.driverBeacon != nil {
            if self.driverBeacon.device != nil
            {
                self.driverBeacon.device.peripheral.discoverServices(nil)                
            }
        }
    }
    
    func manager(_ manager: Manager, willConnectToDevice device: Device) {
        
    }
    
    
    func manager(_ manager: Manager, connectedToDevice device: Device) {

        
        
    }

    
    func manager(_ manager: Manager, disconnectedFromDevice device: Device, willRetry retry: Bool) {
     
        let dialog = ZAlertView(title: "💀", message: "Disconnected" , closeButtonText: "OK",closeButtonHandler:{alertView in
            alertView.dismissAlertView()
        })
        dialog.show()
        
        let beacon = CheckBLEWithName(device: device)
        
        if beacon != nil {
            
            beacon?.rssi = device.rssi
            
            switch (beacon?.type)! {
            case .driving:
                driverStatusView.backgroundColor = UIColor.init(red: 255/255.0, green: 38/255.0, blue: 115/255.0, alpha: 0.9)
            case .front:
                passengerStatusView.backgroundColor = UIColor.init(red: 255/255.0, green: 38/255.0, blue: 115/255.0, alpha: 0.9)
            case .rear:
                rearStatusView.backgroundColor = UIColor.init(red: 255/255.0, green: 38/255.0, blue: 115/255.0, alpha: 0.9)
            case .none:
                break
            }
        }
    }
    
    func manager(_ manager: Manager, RSSIUpdated device: Device) {

    }
    
    func manager(_ manager: Manager,IsBLEOn status:Bool)
    {
        ShowEnableBLEAlert()
    }
    
    fileprivate func ShowEnableBLEAlert() {
        let dialog = ZAlertView(title: "🙄", message: "Please turn Bluetooth ON!" , closeButtonText: "OK",closeButtonHandler:{alertView in
            alertView.dismissAlertView()
        })
        dialog.show()
    }

    
    func UpdateBeaconStatusLabel(beacon:BeaconType)
    {
        DispatchQueue.main.async {
          
            switch beacon {
            case .driving:
                self.beaconStatus.text = "Driver"
                self.appMode = BeaconType.driving
                if !self.locationIsUpdating
                {
                    self.LocationInitializer()
                    self.mapView.isMyLocationEnabled = true
                }
            case .front:
                self.beaconStatus.text = "Passenger"
                self.appMode = BeaconType.front
                self.StopLocationRequest()
                
            case .rear:
                self.beaconStatus.text = "Rear Seat"
                self.appMode = BeaconType.rear
                self.StopLocationRequest()
            default:
                self.beaconStatus.text = "None"
                self.appMode = BeaconType.none
                self.StopLocationRequest()
            }
        }
        isUpdated = false
    }
    
    @IBAction func ShowBlesEvent(_ sender: Any) {
        
    }
    
    func StopLocationRequest()
    {
        if locationRequest != nil {
            locationRequest.stop()
            Locator.stopRequest(locationRequest)
            locationIsUpdating = false
            mapView.isMyLocationEnabled = false
            Locator.completeAllLocationRequests()
        }
    }
    
    func DetermineZone() -> BeaconType
    {
        var type:BeaconType = BeaconType.none
        
        if driverDistance == 0 && passengerDistance == 0 && backSeatDistance == 0{
            self.beaconStatusContainer.backgroundColor = UIColor.init(red: 255/255.0, green: 38/255.0, blue: 115/255.0, alpha: 0.9)
            type = BeaconType.none
        }
        
        if driverDistance - 0.15 < passengerDistance && driverDistance - 0.15 < backSeatDistance
        {
            type = .driving
        }
        else if passengerDistance < driverDistance && passengerDistance < backSeatDistance
        {
            type = .front
        }
        else if backSeatDistance < driverDistance - 0.15 && backSeatDistance < passengerDistance
        {
            type = .rear
        }
        else
        {
            self.beaconStatusContainer.backgroundColor = UIColor.init(red: 255/255.0, green: 38/255.0, blue: 115/255.0, alpha: 0.9)
            type = BeaconType.none
        }
        
        ResetDistances()
        
        return type
    }
    
    func ResetDistances()
    {
        driverDistance = 0
        passengerDistance = 0
        backSeatDistance = 0
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
        if locationIsUpdating
        {
            let distances = [String(driverDistance),String(passengerDistance),String(backSeatDistance)]
            let manager = DataManager()
            
            manager.PostRecords(dateTime: getTodayString(), speed: currentSpeed, latitude: latitiude, longitude: longitude, phoneBattery: Int(UIDevice.current.batteryLevel * 100), userState: self.appMode == nil ? "none" : self.appMode.rawValue, blutoothState: bleManager.bluetoothEnabled, gpsState: true, beacons: [], distances: [], completion: {(APIResponse)-> Void in
                
            })
        }
    }
    @IBAction func ActivateTestModeEvent(_ sender: Any) {
        
        if isTestMode {
            let dialog = ZAlertView(title: "🙄", message: "Test Mode Deactivated!" , closeButtonText: "OK",closeButtonHandler:{alertView in
                self.isTestMode = false
                self.speedLabel.text = "0"
                alertView.dismissAlertView()
            })
            dialog.show()
        }
        else{
            let dialog = ZAlertView(title: "🙄", message: "Test Mode Activated!" , closeButtonText: "OK",closeButtonHandler:{alertView in
                self.isTestMode = true
                alertView.dismissAlertView()
            })
            dialog.show()
        }
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
//        bleManager.stopScanForDevices()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}
