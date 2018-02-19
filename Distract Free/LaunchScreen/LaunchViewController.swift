//
//  LaunchViewController.swift
//  Distract Free
//
//  Created by adb on 2/19/18.
//  Copyright © 2018 Arena. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Timer.scheduledTimer(timeInterval: 0,
                             target: self,
                             selector: #selector(update),
                             userInfo: nil,
                             repeats: false)
    }

    @objc func update() {
        
        let manager = DataManager()
        
        if TokenManager().Token != "" {
            manager.Beacons(completion: {(APIResponse)-> Void in
                
                let glbData = GlobalData.sharedInstance
                glbData.driverBeacon = APIResponse.first!
                glbData.passengerBeacon = APIResponse.last!                
            })
        }
        else
        {
            performSegue(withIdentifier: "login", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
