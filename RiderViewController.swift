//
//  RiderViewController.swift
//  cliq
//
//  Created by Oleg Zakharov on 27/05/2017.
//  Copyright © 2017 Cliq. All rights reserved.
//

import UIKit
import MapKit

class RiderViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, RiderCliqController {

    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callCliqButton: UIButton!
    
    
    private var locationManager = CLLocationManager()
    private var riderLocation: CLLocationCoordinate2D?
    private var driverLocation: CLLocationCoordinate2D?
    private var timer = Timer()
    
    
    private var canCallCliq = true
    private var riderCandeledRequest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initializeLocationManager()
        CliqHandler.Instance.observeMessagesForRider()
        CliqHandler.Instance.riderDelegate = self
    }
    
    private func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locationManager.location?.coordinate {
            
            riderLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: riderLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            map.setRegion(region, animated: true)
            
            map.removeAnnotations(map.annotations)
            
            if driverLocation != nil {
                if !canCallCliq {
                    let driverAnnotation = MKPointAnnotation()
                    driverAnnotation.coordinate = driverLocation!
                    driverAnnotation.title = "Driver's Location"
                    map.addAnnotation(driverAnnotation)
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = riderLocation!
            annotation.title = "Rider's Location"
            map.addAnnotation(annotation)
            
        }
    }
    
    func updateRidersLocation() {
        
        CliqHandler.Instance.updateRiderLocation(lat: riderLocation!.latitude, long: riderLocation!.longitude)
    }
    
    @IBAction func logout(_ sender: Any) {
        if AuthProvider.Instance.logOut() {
            if !canCallCliq {
                CliqHandler.Instance.cancelCliq()
                timer.invalidate()
            }
        } else {
            alertUser(title: "Problem logging out", message: "Try again")
        }
    }
    
    func canCallCliq(delegateCalled: Bool) {
        
        if delegateCalled {
            callCliqButton.setTitle("Cancel Cliq", for: UIControlState.normal)
            canCallCliq = false
        } else {
            callCliqButton.setTitle("Call Cliq", for: UIControlState.normal)
            canCallCliq = true
        }
    }
    
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String) {
        
        if !riderCandeledRequest {
            
            if requestAccepted {
                alertUser(title: "Cliq Accepted", message: "\(driverName) is coming")
            } else {
                CliqHandler.Instance.cancelCliq()
                alertUser(title: "Cliq Cancelled", message: "Try again")
                timer.invalidate()
            }
        }
        riderCandeledRequest = false
    }
    
    func updateDriversLocation(lat: Double, long: Double) {
        
        driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    @IBAction func callCliq(_ sender: Any) {
        if riderLocation != nil {
            if canCallCliq {
                CliqHandler.Instance.requestCliq(latitude: Double(riderLocation!.latitude), longitude: Double(riderLocation!.longitude))
                
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(RiderViewController.updateRidersLocation), userInfo: nil, repeats: true)
            } else {
                riderCandeledRequest = true
                CliqHandler.Instance.cancelCliq()
                timer.invalidate()
            }
        }
    }
    
    private func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}
