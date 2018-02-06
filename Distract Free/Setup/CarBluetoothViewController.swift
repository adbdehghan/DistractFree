//
//  CarBluetoothViewController.swift
//  Distract Free
//
//  Created by adb on 2/6/18.
//  Copyright © 2018 Arena. All rights reserved.
//

import UIKit
import Bluetonium

class CarBluetoothViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,ManagerDelegate {
    
    @IBOutlet weak var bluetoothListTableView: UITableView!
    let manager = Manager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bluetoothListTableView.alpha = 0
        bluetoothListTableView.layer.cornerRadius = 8
        bluetoothListTableView.backgroundColor = .clear
        manager.delegate = self
        manager.startScanForDevices()
        
    }
    
    func manager(_ manager: Manager, didFindDevice device: Device) {
         bluetoothListTableView?.reloadData()
    }
    
    func manager(_ manager: Manager, willConnectToDevice device: Device) {
        
    }
    
    func manager(_ manager: Manager, connectedToDevice device: Device) {
        
    }
    
    func manager(_ manager: Manager, disconnectedFromDevice device: Device, willRetry retry: Bool) {
        
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
        cell.textLabel?.text = device.peripheral.name ?? "⛄️ No name"
        cell.textLabel?.font = (device.peripheral.state == .connected) ? UIFont.boldSystemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
        
        return cell
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
