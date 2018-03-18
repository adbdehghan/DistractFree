//
//  SetPasswordViewController.swift
//  Distract Free
//
//  Created by adb on 2/7/18.
//  Copyright © 2018 Arena. All rights reserved.
//

import UIKit
import PinCodeTextField
import ZAlertView

class SetPasswordViewController: UIViewController {

    @IBOutlet var passwordTextField: PinCodeTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField.keyboardType = .numberPad
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func NextButtonAction(_ sender: Any) {
        
        if passwordTextField.text?.count == 6 {
            let manager = PasswordManager()
            manager.SavePassword(Password: passwordTextField.text!)
            performSegue(withIdentifier: "next", sender: self)
        }
        else
        {
            let dialog = ZAlertView(title: "🙄", message: "Please choose a password" , closeButtonText: "OK",closeButtonHandler:{alertView in
                
                alertView.dismissAlertView()
            })
            dialog.show()
        }
        
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
