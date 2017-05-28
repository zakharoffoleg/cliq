//
//  FirstViewController.swift
//  cliq
//
//  Created by Oleg Zakharov on 28/05/2017.
//  Copyright © 2017 Cliq. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func riderButton(_ sender: Any) {
        
        Variables.isRider = true
    }
    
    @IBAction func driverButton(_ sender: Any) {
        
        Variables.isRider = false
    }
    
}
