//
//  RiderSingInViewController.swift
//  cliq
//
//  Created by Oleg Zakharov on 27/05/2017.
//  Copyright © 2017 Cliq. All rights reserved.
//

import UIKit

class RiderSingInViewController: UIViewController {
    
    private let RIDER_SEGUE = "RiderViewController"
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func mainMenu(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func login(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            AuthProvider.Instance.login(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                
                if message != nil {
                    self.alertUser(title: "Problem with authentication", message: message!)
                } else {
                    self.performSegue(withIdentifier: self.RIDER_SEGUE, sender: nil)
                }
                
            })
        } else {
            alertUser(title: "Email and password required", message: "Please enter email and password")
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            AuthProvider.Instance.signUp(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: {(message) in
                
                if message != nil {
                    self.alertUser(title: "Problem with creating new user", message: message!)
                } else {
                    self.performSegue(withIdentifier: self.RIDER_SEGUE, sender: nil)
                }
            })
        }
    }
    
    private func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
}
