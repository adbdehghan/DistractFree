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

        let steerImage:UIImageView = UIImageView(image: UIImage(named: "steering-wheel"))
        steerImage.frame = CGRect(x: self.view.frame.size.width/2 - 62.5, y:self.view.frame.size.height/2 - 62.5 , width: 125, height: 125)
        view.addSubview(steerImage)
        
        rotateView(targetView: steerImage,duration: 1, direction: 1)
        
        
        Timer.scheduledTimer(timeInterval: 2,
                             target: self,
                             selector: #selector(update),
                             userInfo: nil,
                             repeats: false)
    }
    
    private func rotateView(targetView: UIView, duration: Double = 1 ,direction:Double) {
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            targetView.transform = targetView.transform.rotated(by: CGFloat(Double.pi/4 * direction))
            
        }) { finished in
            self.rotateView(targetView: targetView, duration: duration,direction: -1 * direction)
        }
    }

    @objc func update() {
        
        let manager = DataManager()
        
        if TokenManager().Token != "" {
            manager.Beacons(completion: {(APIResponse)-> Void in
                
                if (APIResponse.count > 0)
                {
                    let glbData = GlobalData.sharedInstance
                    glbData.beacons = APIResponse
//                    glbData.passengerBeacon = APIResponse[1]
//                    glbData.backSeatBeacon = APIResponse.last!
                    
                    if PasswordManager().Password == ""
                    {
                        self.performSegue(withIdentifier: "setup", sender: self)
                    }
                    else
                    {
                        //                glbData.driverBeacon.calibrationValue = CalibrationManager().driverCalibValue
                        //                glbData.passengerBeacon.calibrationValue = CalibrationManager().passengerCalibValue
                        //                glbData.backSeatBeacon.calibrationValue = CalibrationManager().backSeatCalibValue
                        
                        self.performSegue(withIdentifier: "main", sender: self)
                    }
                }
                else
                {
                    
                }
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
