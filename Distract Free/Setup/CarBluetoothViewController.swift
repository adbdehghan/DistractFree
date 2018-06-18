//
//  CarBluetoothViewController.swift
//  Distract Free
//
//  Created by adb on 2/6/18.
//  Copyright © 2018 Arena. All rights reserved.
//

import UIKit
import Bluetonium
import ZAlertView
import KVSpinnerView

class CarBluetoothViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,ManagerDelegate,RadarViewDelegate {


    var radarView: RadarView?
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var bluetoothListTableView: UITableView!
    let manager = Manager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        radarView = RadarView(frame: view.frame)
        radarView?.delegate = self
        radarView?.alpha = 0.4
        radarView?.backgroundColor = .clear
        view.addSubview(radarView!)
        view.sendSubview(toBack: radarView!)
        view.sendSubview(toBack: backgroundImageView)
        
        bluetoothListTableView.alpha = 0
        bluetoothListTableView.backgroundColor = .clear
        manager.delegate = self
        manager.startScanForDevices()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
     
    }
    
    func manager(_ manager: Manager, didFindDevice device: Device) {
         bluetoothListTableView?.reloadData()
        let item = Item(uniqueKey: "item\(device.peripheral.identifier)", value:"item\(device.peripheral.identifier)")
        
        radarView?.add(item: item)
    }
    
    func manager(_ manager: Manager, willConnectToDevice device: Device) {
        
    }
    
    func manager(_ manager: Manager, connectedToDevice device: Device) {
     
        let manager = BluetoothManager()
        manager.SaveBlutoothIdentifier(identifier: device.peripheral.identifier.uuidString, name: (device.peripheral.name ?? "no name"))
        KVSpinnerView.show(saying: "Connected")
        KVSpinnerView.dismiss(after: 1.5)
    }
    
    func manager(_ manager: Manager, disconnectedFromDevice device: Device, willRetry retry: Bool) {
        
    }
    func manager(_ manager: Manager, RSSIUpdated device: Device) {

    }
    
    func radarView(radarView: RadarView, didSelect item: Item) {
        
    }
    
    func manager(_ manager: Manager, IsBLEOn status: Bool) {
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.foundDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        bluetoothListTableView.alpha = 1
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath)
        let device = manager.foundDevices[indexPath.row]
        
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = .clear
        cell.textLabel?.text = (device.peripheral.name ?? "⛄️ No name")
        cell.textLabel?.font = (device.peripheral.state == .connected) ? UIFont.boldSystemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let device = manager.foundDevices[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dialog = ZAlertView(title: "Are you sure?", message: "Connect to \(device.peripheral.name ?? "⛄️ No name")" ,isOkButtonLeft: false, okButtonText: "SET",cancelButtonText: "CANCEL",okButtonHandler:{alertView in
            
            alertView.dismissAlertView()
            
            KVSpinnerView.show(saying: "Connecting")
            self.manager.disconnectFromDevice()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.manager.connect(with: device)
            }
  
        }, cancelButtonHandler: { alertView in
            alertView.dismissAlertView()
        })
        
        dialog.show()
    }
    
    @IBAction func NextButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "next", sender: self)
    }
    
    @IBAction func BackButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
