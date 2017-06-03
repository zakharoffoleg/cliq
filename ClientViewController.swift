//
//  clientViewController.swift
//  cliq
//
//  Created by Oleg Zakharov on 27/05/2017.
//  Copyright © 2017 Cliq. All rights reserved.
//

import UIKit
import MapKit

class ClientViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, ClientCliqController {

    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callCliqButton: UIButton!
    
    
    private var locationManager = CLLocationManager()
    private var clientLocation: CLLocationCoordinate2D?
    private var barberLocation: CLLocationCoordinate2D?
    private var timer = Timer()
    
    
    private var canCallCliq = true
    private var clientCandeledRequest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initializeLocationManager()
        CliqHandler.Instance.observeMessagesForClient()
        CliqHandler.Instance.clientDelegate = self
    }
    
    private func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locationManager.location?.coordinate {
            
            clientLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: clientLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            map.setRegion(region, animated: true)
            
            map.removeAnnotations(map.annotations)
            
            if barberLocation != nil {
                if !canCallCliq {
                    let barberAnnotation = MKPointAnnotation()
                    barberAnnotation.coordinate = barberLocation!
                    barberAnnotation.title = "Barber's Location"
                    map.addAnnotation(barberAnnotation)
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = clientLocation!
            annotation.title = "Client's Location"
            map.addAnnotation(annotation)
            
        }
    }
    
    func updateClientsLocation() {
        
        CliqHandler.Instance.updateClientLocation(lat: clientLocation!.latitude, long: clientLocation!.longitude)
    }
    
    @IBAction func logout(_ sender: Any) {
        if AuthProvider.Instance.logOut() {
            if !canCallCliq {
                CliqHandler.Instance.cancelCliq(status: false)
                timer.invalidate()
            }
            dismiss(animated: true, completion: nil)
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
    
    func barberAcceptedRequest(requestAccepted: Bool, barberName: String) {
        
        if !clientCandeledRequest {
            
            if requestAccepted {
                alertUser(title: "Cliq Accepted", message: "\(barberName) is coming")
            } else {
                CliqHandler.Instance.cancelCliq(status: false)
                alertUser(title: "Cliq Cancelled", message: "Try again")
                timer.invalidate()
            }
        }
        clientCandeledRequest = false
    }
    
    func updateBarbersLocation(lat: Double, long: Double) {
        
        barberLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    func checkPayment(barber_name: String, price: Double) {
        
        CliqHandler.Instance.price = price
        paymentRequest(title: "Payment Confirmation", message: "\(barber_name) has finished your haircut for \(price)$. Please confirm the payment.")
        timer.invalidate()
    }
    
    @IBAction func callCliq(_ sender: Any) {
        if clientLocation != nil {
            if canCallCliq {
                
                CliqHandler.Instance.requestCliq(latitude: Double(clientLocation!.latitude), longitude: Double(clientLocation!.longitude))
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(ClientViewController.updateClientsLocation), userInfo: nil, repeats: true)
                
            } else {
                
                clientCandeledRequest = true
                CliqHandler.Instance.cancelCliq(status: false)
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
    
    private func paymentRequest(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let accept = UIAlertAction(title: "Confirm", style: .default, handler: { (alertAction: UIAlertAction) in
            
            // inform barber that you confirmed
            
            CliqHandler.Instance.finishedHaircut(barber_name: CliqHandler.Instance.barber, client_name: CliqHandler.Instance.client, price: CliqHandler.Instance.price, paid: true)
            
            // delete payment request
            
            CliqHandler.Instance.deletePaymentRequest()
            
        })
    
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { (alertaction: UIAlertAction) in
            
            // inform barber that you canceled
            
            CliqHandler.Instance.finishedHaircut(barber_name: CliqHandler.Instance.barber, client_name: CliqHandler.Instance.client, price: CliqHandler.Instance.price, paid: false)
            
            // delete payment request
            
            CliqHandler.Instance.deletePaymentRequest()
        })
            
        alert.addAction(accept)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }


}
