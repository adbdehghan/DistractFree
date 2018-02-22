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
    var filter = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 1)
    var counter = 0
    var rssiArray:[Double]!
    
//    var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        UICustomization()
        InitMap()
        LocationInitializer()
        
        let glbData = GlobalData.sharedInstance
        
        beacons = [Beacon]()
        driverBeacon = Beacon()
        passengerBeacon = Beacon()
        driverBeacon.identifier = "18e2870c-c04d-2034-2997-d74315f285bc"
        passengerBeacon.identifier = "18018701-88c5-1368-73c7-30d07905e6b4"
        beacons.append(driverBeacon)
        beacons.append(passengerBeacon)
//        beacons.append((glbData.driverBeacon))
//        beacons.append((glbData.passengerBeacon))
        
        rssiArray = [Double]()
        
        bleManager.delegate = self
        bleManager.startScanForDevices()

    }
    
    func LocationInitializer()
    {
        Locator.requestAuthorizationIfNeeded(.always)
        
        Locator.subscribePosition(accuracy: .block, onUpdate:{ loc in
            
            let speed = Double((loc.speed))
            
            if speed > 0.0
            {
                
                self.speedLabel.text = String(format: "%d",Int((loc.speed) * 3.6)) 
            }
            
            let camera = GMSCameraPosition.camera(withLatitude:(loc.coordinate.latitude),
                                                  longitude: (loc.coordinate.longitude),
                                                  zoom: 18)
            self.mapView.camera = camera
            
        },onFail: { err, last in
                print("Failed with error: \(err)")
        })
    }
    
    func UICustomization()
    {
        SpeedContainerView.layer.cornerRadius = SpeedContainerView.frame.width/2
        speedBackLayer.layer.cornerRadius = speedBackLayer.frame.width/2
        beaconStatusContainer.layer.cornerRadius = SpeedContainerView.frame.width/2
        beaconStatusBackgroundView.layer.cornerRadius = speedBackLayer.frame.width/2
        
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
        for item in beacons {
            
            if device.peripheral.identifier.uuidString.lowercased() == item.identifier
            {
                return item
            }
            else
            {
                return nil
            }
            
        }
        return nil
    }
    
    func manager(_ manager: Manager, didFindDevice device: Device) {
                let beacon = CheckBLE(device: device)
        
                if beacon != nil {
                    bleManager.connect(with: device)
                    if beacon?.type == BeaconType.Driver
                    {
                        self.beaconStatus.text = "Driver"
                        driverBeacon = beacon
        
                    }
                    else
                    {
                        self.beaconStatus.text = "Passenger"
                        passengerBeacon = beacon
                    }
                }
    }
    
    func manager(_ manager: Manager, willConnectToDevice device: Device) {
        
    }
    
    func manager(_ manager: Manager, connectedToDevice device: Device) {
        self.beaconStatusContainer.backgroundColor = .green
    }
    
    func manager(_ manager: Manager, disconnectedFromDevice device: Device, willRetry retry: Bool) {
          self.beaconStatusContainer.backgroundColor = .red
    }
    
    func manager(_ manager: Manager, RSSIUpdated device: Device) {
        var beacon = CheckBLE(device: device)
        
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
                self.beaconStatus.text = "Driver"
            }
            else
            {
                self.beaconStatus.text = "Passenger"
            }
            
            
        }
//        let prediction = filter.predict(stateTransitionModel: 1, controlInputModel: 0, controlVector: 0, covarianceOfProcessNoise: 0)
//        let update = prediction.update(measurement: device.rssi.doubleValue, observationModel: 1, covarienceOfObservationNoise: 0.1)
//
//        filter = update
        

    }
    
    func calculateNewDistance(txCalibratedPower: Int, rssi: Int) -> Double{
        if rssi == 0{
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
