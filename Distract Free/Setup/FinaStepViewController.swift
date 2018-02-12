//
//  FinaStepViewController.swift
//  Distract Free
//
//  Created by adb on 2/11/18.
//  Copyright © 2018 Arena. All rights reserved.
//

import UIKit

class FinaStepViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func NextButtonAction(_ sender: Any) {
        
        performSegue(withIdentifier: "main", sender: self)
        
    }
    
    @IBAction func BackButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }


}
