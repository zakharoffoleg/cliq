//
//  FirstViewController.swift
//  cliq
//
//  Created by Oleg Zakharov on 28/05/2017.
//  Copyright © 2017 Cliq. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    private let CLIENT_SEGUE = "ClientSignInViewController"
    
    private let BARBER_SEGUE = "BarberSignInViewController"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func clientButton(_ sender: Any) {
        
        Variables.isClient = true
        
        self.performSegue(withIdentifier: CLIENT_SEGUE, sender: nil)
    }
    
    @IBAction func barberButton(_ sender: Any) {
        
        Variables.isClient = false
        
        self.performSegue(withIdentifier: BARBER_SEGUE, sender: nil)
    }
    
    
}
