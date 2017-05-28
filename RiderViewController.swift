//
//  RiderViewController.swift
//  cliq
//
//  Created by Oleg Zakharov on 27/05/2017.
//  Copyright © 2017 Cliq. All rights reserved.
//

import UIKit
import MapKit

class RiderViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logout(_ sender: Any) {
        if AuthProvider.Instance.logOut() {
            dismiss(animated: true, completion: nil)
        } else {
            alertUser(title: "Problem logging out", message: "Try again")
        }
    }
    
    @IBAction func callCliq(_ sender: Any) {
    }
    
    private func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}
