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
    let manager = CLLocationManager()
    var currentSpeed = 0.0
    var mapView:GMSMapView!
    let bleManager = Manager()
//    var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        UICustomization()
        InitMap()
        LocationInitializer()
        
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

    func manager(_ manager: Manager, didFindDevice device: Device) {

    }
    
    func manager(_ manager: Manager, willConnectToDevice device: Device) {
        
    }
    
    func manager(_ manager: Manager, connectedToDevice device: Device) {        

    }
    
    func manager(_ manager: Manager, disconnectedFromDevice device: Device, willRetry retry: Bool) {
        
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
