//
//  CliqHandler.swift
//  cliq
//
//  Created by Oleg Zakharov on 28/05/2017.
//  Copyright © 2017 Cliq. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol BarberCliqController: class {
    func acceptCliq(lat: Double, long: Double)
    func clientCanceledCliq()
    func canceledCliq()
    func updateClientsLocation(lat: Double, long: Double)
    func informPaymentConfirmation(client_name: String, price: Double)
    func informPaymentCancellation(client_name: String, price: Double)
}

protocol ClientCliqController: class {
    func canCallCliq(delegateCalled: Bool)
    func barberAcceptedRequest(requestAccepted: Bool, barberName: String)
    func updateBarbersLocation(lat: Double, long: Double)
    func checkPayment(barber_name: String, price: Double)
}

class CliqHandler {
    
    private static let _instance = CliqHandler()
    
    weak var barberDelegate: BarberCliqController?
    weak var clientDelegate: ClientCliqController?
    
    static var Instance: CliqHandler {
        return _instance
    }
    
    var client = ""
    var barber = ""
    var client_id = ""
    var barber_id = ""
    var price = 0.0
    
    func observeMessagesForBarber() {
        
        // client REQUESTED AN UBER
        
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGITUDE] as? Double {
                        if let status = data[Constants.STATUS] as? Bool {
                            if status {
                                if let client = data[Constants.CLIENT_NAME] as? String {
                                    self.client = client;
                                }
                                self.barberDelegate?.acceptCliq(lat: latitude, long: longitude);
                            }
                        }
                    }
                }
            }
        
            // client CANCELED UBER
            
            DBProvider.Instance.requestRef.observe(DataEventType.childChanged, with: { (snapshot: DataSnapshot) in
            
                if let data = snapshot.value as? NSDictionary {
                    if let client = data[Constants.CLIENT_NAME] as? String {
                        if let status = data[Constants.STATUS] as? Bool {
                            if !status {
                                if client == self.client {
                                    self.client = "";
                                    self.barberDelegate?.clientCanceledCliq();
                                }
                            }
                        }
                    }
                }
            })
        }
        
        // Update clients location
        
        DBProvider.Instance.requestRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let client = data[Constants.CLIENT_NAME] as? String {
                    if client == self.client {
                        if let longitude = data[Constants.LONGITUDE] as? Double {
                            if let latitude = data[Constants.LATITUDE] as? Double {
                                self.barberDelegate?.updateClientsLocation(lat: latitude, long: longitude)
                            }
                        }
                    }
                }
            }
        }
        
        // Check if barber accepts cliq
        
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let barber = data[Constants.BARBER_NAME] as? String {
                    if let status = data[Constants.STATUS] as? Bool {
                        if status {
                            if barber == self.barber {
                                self.barber_id = snapshot.key
                            }
                        }
                    }
                }
            }
        }
        
        // barber canceled cliq
        
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let barber = data[Constants.BARBER_NAME] as? String {
                    if let status = data[Constants.STATUS] as? Bool {
                        if !status {
                            if barber == self.barber {
                                self.barberDelegate?.canceledCliq()
                            }
                        }
                    }
                }
            }
        }
        
        DBProvider.Instance.finishHaircutRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let barber = data[Constants.BARBER_NAME] as? String {
                    if barber == self.barber {
                        self.barber_id = snapshot.key
                    }
                }
            }
        }
        
        //check if cliend paid or canceled payment
        
        DBProvider.Instance.finishedHaircutRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let barber = data[Constants.BARBER_NAME] as? String {
                    if let client = data[Constants.CLIENT_NAME] as? String {
                        if let price = data[Constants.PRICE] as? Double {
                            if let paid = data[Constants.HAIRCUT_PAID] as? Bool {
                                self.client_id = snapshot.key
                                if paid {
                                    self.barberDelegate?.informPaymentConfirmation(client_name: client, price: price)
                                } else {
                                    self.barberDelegate?.informPaymentCancellation(client_name: client, price: price)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func observeMessagesForClient() {
        
        //Calling Cliq
        
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let client = data[Constants.CLIENT_NAME] as? String {
                    if let status = data[Constants.STATUS] as? Bool {
                        if status {
                            if client == self.client {
                                self.client_id = snapshot.key
                                self.clientDelegate?.canCallCliq(delegateCalled: true)
                            }
                        }
                    }
                }
            }
            
            //Cancelling Cliq
            
            DBProvider.Instance.requestRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
                
                if let data = snapshot.value as? NSDictionary {
                    if let client = data[Constants.CLIENT_NAME] as? String {
                        if let status = data[Constants.STATUS] as? Bool {
                            if !status {
                                if client == self.client {
                                    self.clientDelegate?.canCallCliq(delegateCalled: false)
                                }
                            }
                        }
                    }
                }
            }
        }
    
        // barber accepted cliq
        
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let barber = data[Constants.BARBER_NAME] as? String{
                    if let status = data[Constants.STATUS] as? Bool {
                        if status {
                            if self.barber == "" {
                                self.barber = barber
                                self.clientDelegate?.barberAcceptedRequest(requestAccepted: true, barberName: barber)
                            }
                        }
                    }
                }
            }
        }
        
        // barber cancelled cliq
        
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let barber = data[Constants.BARBER_NAME] as? String {
                    if let status = data[Constants.STATUS] as? Bool {
                        if !status {
                            if barber == self.barber {
                                self.barber = ""
                                self.clientDelegate?.barberAcceptedRequest(requestAccepted: false, barberName: barber)
                            }
                        }
                    }
                }
            }
            
        }
        
        
        
        // Updating barber location
        
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let barber = data[Constants.BARBER_NAME] as? String {
                    if barber == self.barber {
                        if let longitude = data[Constants.LONGITUDE] as? Double {
                            if let latitude = data[Constants.LATITUDE] as? Double {
                                self.clientDelegate?.updateBarbersLocation(lat: latitude, long: longitude)
                            }
                        }
                    }
                }
            }
        }
        
        // Check if haircut is finished
        
        DBProvider.Instance.finishHaircutRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let client = data[Constants.CLIENT_NAME] as? String {
                    if let barber = data[Constants.BARBER_NAME] as? String {
                        if let price = data[Constants.PRICE] as? Double {
                            if client == self.client {
                                self.barber_id = snapshot.key
                                self.clientDelegate?.checkPayment(barber_name: barber, price: price)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func requestCliq(latitude: Double, longitude: Double) {
        
        let data: Dictionary<String, Any> = [Constants.CLIENT_NAME: client, Constants.LATITUDE: latitude, Constants.LONGITUDE: longitude, Constants.STATUS: true]
        
        DBProvider.Instance.requestRef.childByAutoId().setValue(data)
    }
    
    func cancelCliq(status: Bool) {
        
        DBProvider.Instance.requestRef.child(client_id).updateChildValues([Constants.STATUS: false])
    }
    
    
    func cliqAccepted(lat: Double, long: Double) {
        
        let data: Dictionary<String, Any> = [Constants.BARBER_NAME: barber, Constants.LATITUDE: lat, Constants.LONGITUDE: long, Constants.STATUS: true]
        
        DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data)
    }
    
    func cancelCliqForBarber(status: Bool) {
        
        DBProvider.Instance.requestAcceptedRef.child(barber_id).updateChildValues([Constants.STATUS: false])
    }
    
    func updateBarberLocation(lat: Double, long: Double) {
        
        DBProvider.Instance.requestAcceptedRef.child(barber_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE:long])
    }
    
    func updateClientLocation(lat: Double, long: Double) {
        
        DBProvider.Instance.requestRef.child(client_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long])
    }
    
    func finishHaircut(barber_name: String, client_name: String, price: Double) {
        
        let data: Dictionary<String, Any> = [Constants.BARBER_NAME: barber_name, Constants.CLIENT_NAME: client_name, Constants.PRICE: price]
        
        DBProvider.Instance.finishHaircutRef.childByAutoId().setValue(data)
    }
    
    
    func finishedHaircut(barber_name: String, client_name: String, price: Double, paid: Bool) {
        
        let data: Dictionary<String, Any> = [Constants.BARBER_NAME: barber_name, Constants.CLIENT_NAME: client_name, Constants.PRICE: price, Constants.HAIRCUT_PAID: paid]
        
        DBProvider.Instance.finishedHaircutRef.childByAutoId().setValue(data)
    }
    
    func deletePaymentRequest() {
        
        DBProvider.Instance.finishHaircutRef.child(barber_id).removeValue();
    }
    
}
