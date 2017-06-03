//
//  barberViewController.swift
//  cliq
//
//  Created by Oleg Zakharov on 28/05/2017.
//  Copyright © 2017 Cliq. All rights reserved.
//

import UIKit
import MapKit

class BarberViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate, BarberCliqController {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var acceptCliqButton: UIButton!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    private var locationManager = CLLocationManager()
    private var barberLocation: CLLocationCoordinate2D?
    private var clientLocation: CLLocationCoordinate2D?
    private var timer = Timer()
    
    private var acceptedCliq = false
    private var barberCanceledCliq = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeLocationManager()
        
        self.acceptCliqButton.isHidden = true
        self.priceTextField.isHidden = true
        self.confirmButton.isHidden = true
        
        self.priceTextField.delegate = self
        
        CliqHandler.Instance.barberDelegate = self
        CliqHandler.Instance.observeMessagesForBarber()
    }
    
    private func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locationManager.location?.coordinate {
            
            barberLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: barberLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            map.setRegion(region, animated: true)
            
            map.removeAnnotations(map.annotations)
            
            if clientLocation != nil {
                if acceptedCliq {
                    let clientAnnotation = MKPointAnnotation()
                    clientAnnotation.coordinate = clientLocation!
                    clientAnnotation.title = "Client's Location"
                    map.addAnnotation(clientAnnotation)
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = barberLocation!
            annotation.title = "Barber's Location"
            map.addAnnotation(annotation)
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        priceTextField.resignFirstResponder()
        return true
    }
    
    func acceptCliq(lat: Double, long: Double) {
        if !acceptedCliq {
            cliqRequest(title: "Cliq Request", message: "You have a Cliq request on \(lat):\(long)", requestAlive: true)
        }
        
    }
    
    func clientCanceledCliq() {
        if !barberCanceledCliq {
            CliqHandler.Instance.cancelCliqForBarber(status: false)
            self.acceptedCliq = false
            self.acceptCliqButton.isHidden = true
            self.confirmButton.isHidden = true
            self.priceTextField.isHidden = true
            cliqRequest(title: "Cliq Canceled", message: "Client has canceled cliq", requestAlive: false)
        }
    }
    
    func canceledCliq() {
        acceptedCliq = false;
        acceptCliqButton.isHidden = true;
        timer.invalidate()
    }
    
    func updateClientsLocation(lat: Double, long: Double) {
        clientLocation = CLLocationCoordinate2D(latitude: lat, longitude: long);
    }
    
    @IBAction func logout(_ sender: Any) {
        
        if AuthProvider.Instance.logOut() {
            if acceptedCliq {
                barberCanceledCliq = true;
                acceptCliqButton.isHidden = true
                CliqHandler.Instance.cancelCliqForBarber(status: false)
                timer.invalidate()
            }
            self.acceptCliqButton.isHidden = true
            dismiss(animated: true, completion: nil)
        } else {
            cliqRequest(title: "Can't log out", message: "Try again later", requestAlive: false)
        }
    }
    
    @IBAction func cancelCliq(_ sender: Any) {
        if acceptedCliq {
            barberCanceledCliq = true;
            acceptCliqButton.isHidden = true;
            CliqHandler.Instance.cancelCliqForBarber(status: false);
            timer.invalidate()
        }
    }
    
    func updateBarbersLocation() {
        
        CliqHandler.Instance.updateBarberLocation(lat: barberLocation!.latitude, long: barberLocation!.longitude)
    }
    
    @IBAction func confirmPayment(_ sender: Any) {
        if acceptedCliq {
            if let price = Double(priceTextField.text!) {
                CliqHandler.Instance.finishHaircut(barber_name: CliqHandler.Instance.barber, client_name: CliqHandler.Instance.client, price: price)
                acceptedCliq = false
                timer.invalidate()
            } else {
                cliqRequest(title: "Please enter the price", message: "Enter price", requestAlive: false)
            }
        }
    }
    
    func informPaymentConfirmation(client_name: String, price: Double) {
        //deleteCliqRequest(title: "Payment confirmed", message: "Payment for \(price)$ successfully confirmed by \(client_name). Thank you.", requestAlive: false)
    }
    
    func informPaymentCancellation(client_name: String, price: Double) {
        //deleteCliqRequest(title: "Payment canceled", message: "Payment canceled, please try again.", requestAlive: false)
    }
    
    
    private func cliqRequest(title: String, message: String, requestAlive: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if requestAlive {
            let accept = UIAlertAction(title: "Accept", style: .default, handler: { (alertAction: UIAlertAction) in
                
                self.acceptedCliq = true
                self.acceptCliqButton.isHidden = false
                self.priceTextField.isHidden = false
                self.confirmButton.isHidden = false
                
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(BarberViewController.updateBarbersLocation), userInfo: nil, repeats: true)
                
                CliqHandler.Instance.cliqAccepted(lat: Double(self.barberLocation!.latitude), long: Double(self.barberLocation!.longitude))
                
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { (alertaction: UIAlertAction) in
                
                self.acceptCliqButton.isHidden = true
                //CliqHandler.Instance.cancelCliqForBarber();
            })
            
            alert.addAction(accept)
            alert.addAction(cancel)
            
        } else {
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(ok)
        }
        
        
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteCliqRequest(title: String, message: String, requestAlive: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (alertActrion: UIAlertAction) in
            
            CliqHandler.Instance.cancelCliqForBarber(status: false)
        })
            
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
}
