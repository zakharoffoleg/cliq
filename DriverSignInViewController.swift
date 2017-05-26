//
//  DriverSignInViewController.swift
//  cliq
//
//  Created by Oleg Zakharov on 25/05/2017.
//  Copyright © 2017 Cliq. All rights reserved.
//

import UIKit
import FirebaseAuth

class DriverSignInViewController: UIViewController {
    
    private let DRIVER_SEGUE = "DriverVC";

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func login(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            AuthProvider.Instance.login(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                
                if message != nil {
                    self.alertUser(title: "Problem with authentication", message: message!)
                } else {
                    print("success")
                }
                
                })
        }
    }

    @IBAction func signup(_ sender: Any) {
    }
    
    private func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
