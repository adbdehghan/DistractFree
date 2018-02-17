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
    
//    var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        UICustomization()
        InitMap()
        LocationInitializer()
        
        let beacon = Beacon()
        beacon.identifier = "9E0C8526-EFA8-999C-55AF-CD30D347BDB8"
        beacon.type = BeaconType.Driver
        beacons = [Beacon]()
        beacons.append(beacon)
        
        bleManager.delegate = self
        bleManager.startScanForDevices()
//        locationManager = CLLocationManager()
//        locationManager.delegate = self
//        locationManager.requestAlwaysAuthorization()
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
            
            if device.peripheral.identifier.uuidString == item.identifier
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
        let beacon = CheckBLE(device: device)
        print(device.rssi)
    }

    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .authorizedAlways {
//            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
//                if CLLocationManager.isRangingAvailable() {
//                    startScanning()
//                }
//            }
//        }
//    }
//    func startScanning() {
//        let uuid = UUID(uuidString: "9E0C8526-EFA8-999C-55AF-CD30D347BDB8")!
//        let beaconRegion = CLBeaconRegion.init(proximityUUID: UUID.init(uuidString: "9E0C8526-EFA8-999C-55AF-CD30D347BDB8")!,
//                                                       identifier: "9E0C8526-EFA8-999C-55AF-CD30D347BDB8")
//
//        locationManager.startMonitoring(for: beaconRegion)
//        locationManager.startRangingBeacons(in: beaconRegion)
//    }
//
//    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        if beacons.count > 0 {
//            updateDistance(beacons[0].proximity)
//        } else {
//            updateDistance(.unknown)
//        }
//    }
//
//    func updateDistance(_ distance: CLProximity) {
//        UIView.animate(withDuration: 0.8) {
//            switch distance {
//            case .unknown:
//                self.view.backgroundColor = UIColor.gray
//
//            case .far:
//                self.view.backgroundColor = UIColor.blue
//
//            case .near:
//                self.view.backgroundColor = UIColor.orange
//
//            case .immediate:
//                self.view.backgroundColor = UIColor.red
//            }
//        }
//    }
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
