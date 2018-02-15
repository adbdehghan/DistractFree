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

class MainViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var speedBackLayer: UIView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var SpeedContainerView: UIView!
    let manager = CLLocationManager()
    var currentSpeed = 0.0
    var mapView:GMSMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        UICustomization()
        InitMap()
        LocationInitializer()
    }
    
    func LocationInitializer()
    {
        Locator.requestAuthorizationIfNeeded(.always)
        
        Locator.subscribePosition(accuracy: .block, onUpdate:{ loc in
            
            let speed = Double((loc.speed))
            if speed > 0.0
            {
                self.speedLabel.text = String(format: "%d",Int((loc.speed) * 3.6)) + " km/h"
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


}
