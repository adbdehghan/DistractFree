//
//  SetPasswordViewController.swift
//  Distract Free
//
//  Created by adb on 2/7/18.
//  Copyright © 2018 Arena. All rights reserved.
//

import UIKit
import PinCodeTextField

class SetPasswordViewController: UIViewController {

    @IBOutlet var passwordTextField: PinCodeTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func NextButtonAction(_ sender: Any) {
    }
    
    @IBAction func BackButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
