//
//  LoginViewController.swift
//  Distract Free
//
//  Created by adb on 2/5/18.
//  Copyright © 2018 Arena. All rights reserved.
//

import UIKit
import ZAlertView
import CTKFlagPhoneNumber

class LoginViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    //MARK: Properties
    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet var registerView: UIView!
    @IBOutlet var loginView: UIView!
    @IBOutlet weak var registerNameField: UITextField!
    @IBOutlet weak var registerEmailField: UITextField!
    @IBOutlet weak var registerPasswordField: UITextField!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet var waringLabels: [UILabel]!
    @IBOutlet weak var loginEmailField: CTKFlagPhoneNumberTextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var cloudsView: UIImageView!
    @IBOutlet weak var cloudsViewLeading: NSLayoutConstraint!
    @IBOutlet var inputFields: [UITextField]!
    var loginViewTopConstraint: NSLayoutConstraint!
    var registerTopConstraint: NSLayoutConstraint!
    let imagePicker = UIImagePickerController()
    var isLoginViewVisible = true
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    func customization()  {
        self.darkView.alpha = 0
        
        loginEmailField.parentViewController = self
        loginEmailField.setFlag(for: "US")
        //LoginView customization
        self.view.insertSubview(self.loginView, belowSubview: self.cloudsView)
        self.loginView.translatesAutoresizingMaskIntoConstraints = false
        self.loginView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.loginViewTopConstraint = NSLayoutConstraint.init(item: self.loginView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 150)
        self.loginViewTopConstraint.isActive = true
        self.loginView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.37).isActive = true
        self.loginView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.loginView.layer.cornerRadius = 8
        //RegisterView Customization
        self.view.insertSubview(self.registerView, belowSubview: self.cloudsView)
        self.registerView.translatesAutoresizingMaskIntoConstraints = false
        self.registerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.registerTopConstraint = NSLayoutConstraint.init(item: self.registerView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 1000)
        self.registerTopConstraint.isActive = true
        self.registerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.37).isActive = true
        self.registerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.registerView.layer.cornerRadius = 8
    }
    
    func cloundsAnimation() {
        let distance = self.view.bounds.width - self.cloudsView.bounds.width
        self.cloudsViewLeading.constant = distance
        UIView.animate(withDuration: 15, delay: 0, options: [.repeat, .curveLinear], animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func showLoading(state: Bool)  {
        if state {
            self.darkView.isHidden = false
            self.spinner.startAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0.5
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0
            }, completion: { _ in
                self.spinner.stopAnimating()
                self.darkView.isHidden = true
            })
        }
    }
    
    func pushTomainView() {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Navigation") as! NavVC
//        self.show(vc, sender: nil)
    }
    
    @IBAction func switchViews(_ sender: UIButton) {
        if self.isLoginViewVisible {
            self.isLoginViewVisible = false
            sender.setTitle("Back", for: .normal)
            self.loginViewTopConstraint.constant = 1000
            self.registerTopConstraint.constant = 150
            sender.isHidden = false
        } else {
            self.isLoginViewVisible = true
            sender.isHidden = true
            self.loginViewTopConstraint.constant = 150
            self.registerTopConstraint.constant = 1000
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        for item in self.waringLabels {
            item.isHidden = true
        }
    }
    
    func switchViewsAuto(Login:Bool){
        
        if Login {
            self.isLoginViewVisible = false
            
            self.loginViewTopConstraint.constant = 1000
            self.registerTopConstraint.constant = 150
        } else {
            self.isLoginViewVisible = true
            
            self.loginViewTopConstraint.constant = 150
            self.registerTopConstraint.constant = 1000
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        for item in self.waringLabels {
            item.isHidden = true
        }
    }
    
    
    @IBAction func register(_ sender: Any) {
        for item in self.inputFields {
            item.resignFirstResponder()
        }
        self.showLoading(state: true)
        let manager = DataManager()
        manager.CheckCode(Code: registerPasswordField.text!, phonenumber: self.loginEmailField.getCountryPhoneCode()! + (self.loginEmailField.text?.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: ""))!, completion: {(APIResponse)-> Void in
            
            
            if  !APIResponse.result!
            {
                self.showLoading(state: false)
                let dialog = ZAlertView(title: "🙄", message: APIResponse.message , closeButtonText: "OK",closeButtonHandler:{alertView in
                    
                    alertView.dismissAlertView()
                })
                dialog.show()                
            }
            else
            {
                let tokenManager = TokenManager()
                tokenManager.SaveToken(Phonenumber: self.loginEmailField.getCountryPhoneCode()! + (self.loginEmailField.text?.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: ""))!, Token: APIResponse.token!, Password: self.registerPasswordField.text!)
                
                manager.Beacons(completion: {(APIResponse)-> Void in
                    self.showLoading(state: false)
                    
                    if APIResponse.count == 0
                    {
                        let dialog = ZAlertView(title: "🙄", message: "There is no beacon founded in your profile, for begin using app you should add your beacons in your profile!" , closeButtonText: "OK",closeButtonHandler:{alertView in
                            
                            alertView.dismissAlertView()
                        })
                        dialog.show()
                    }
                    else
                    {
                        let glbData = GlobalData.sharedInstance
                        glbData.beacons = APIResponse
//                        glbData.passengerBeacon = APIResponse[1]
//                        glbData.backSeatBeacon = APIResponse.last!                        
                                                
                        self.performSegue(withIdentifier: "next", sender: self)
                    }
                })
                
            }
            
            
        })
    }
    
    @IBAction func login(_ sender: Any) {
        for item in self.inputFields {
            item.resignFirstResponder()
        }
        self.showLoading(state: true)
        let manager = DataManager()
        
        manager.RegisterNumber(phonenumber:self.loginEmailField.getCountryPhoneCode()! + (self.loginEmailField.text?.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: ""))!, completion: {(APIResponse)-> Void in
            
            self.BackButton.isHidden = false
            self.showLoading(state: false)
            self.switchViewsAuto(Login: true)
        })
    }    
    
    //MARK: Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        for item in self.waringLabels {
            item.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.cloundsAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cloudsViewLeading.constant = 0
        self.cloudsView.layer.removeAllAnimations()
        self.view.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
