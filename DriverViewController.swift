//
//  DriverViewController.swift
//  cliq
//
//  Created by Oleg Zakharov on 28/05/2017.
//  Copyright © 2017 Cliq. All rights reserved.
//

import UIKit
import MapKit

class DriverViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, DriverCliqController {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var acceptCliqButton: UIButton!
    
    
    private var locationManager = CLLocationManager()
    private var driverLocation: CLLocationCoordinate2D?
    //private var riderLocation: CLLocationCoordinate2D
    
    private var acceptedCliq = false
    private var driverCanceledCliq = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeLocationManager()
        
        CliqHandler.Instance.driverDelegate = self
        CliqHandler.Instance.observeMessagesForDriver()
    }
    
    private func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locationManager.location?.coordinate {
            
            driverLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: driverLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            map.setRegion(region, animated: true)
            
            map.removeAnnotations(map.annotations)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = driverLocation!
            annotation.title = "Driver's Location"
            map.addAnnotation(annotation)
            
        }
    }
    
    func acceptCliq(lat: Double, long: Double) {
        if !acceptedCliq {
            cliqRequest(title: "Cliq Request", message: "You have a Cliq request on \(lat):\(long)", requestAlive: true)
        }
        
    }
    
    func riderCanceledCliq() {
        if !driverCanceledCliq {
            CliqHandler.Instance.cancelCliqForDriver()
            self.acceptedCliq = false
            self.acceptCliqButton.isHidden = true
            cliqRequest(title: "Cliq Canceled", message: "The client has canceled cliq", requestAlive: false)
        }
    }
    
    func canceledCliq() {
        acceptedCliq = false;
        acceptCliqButton.isHidden = true;
        //invalidate timer
    }
    
    @IBAction func logout(_ sender: Any) {
        
        if AuthProvider.Instance.logOut() {
            dismiss(animated: true, completion: nil)
        } else {
            cliqRequest(title: "Can't log out", message: "Try again later", requestAlive: false)
        }
    }
    
    @IBAction func cancelCliq(_ sender: Any) {
        if acceptedCliq {
            driverCanceledCliq = true;
            acceptCliqButton.isHidden = true;
            CliqHandler.Instance.cancelCliqForDriver();
        }
    }
    
    
    
    private func cliqRequest(title: String, message: String, requestAlive: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if requestAlive {
            let accept = UIAlertAction(title: "Accept", style: .default, handler: { (alertAction: UIAlertAction) in
                
                self.acceptedCliq = true
                self.acceptCliqButton.isHidden = false
                
                CliqHandler.Instance.cliqAccepted(lat: Double(self.driverLocation!.latitude), long: Double(self.driverLocation!.longitude))
                
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
            alert.addAction(accept)
            alert.addAction(cancel)
        } else {
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
        }
        
        
        present(alert, animated: true, completion: nil)
    }

}
