//
//  CliqHandler.swift
//  cliq
//
//  Created by Oleg Zakharov on 28/05/2017.
//  Copyright © 2017 Cliq. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol DriverCliqController: class {
    func acceptCliq(lat: Double, long: Double)
    func riderCanceledCliq()
    func canceledCliq()
}

protocol RiderCliqController: class {
    func canCallCliq(delegateCalled: Bool)
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String)
}

class CliqHandler {
    
    private static let _instance = CliqHandler()
    
    weak var driverDelegate: DriverCliqController?
    weak var riderDelegate: RiderCliqController?
    
    static var Instance: CliqHandler {
        return _instance
    }
    
    var rider = ""
    var driver = ""
    var rider_id = ""
    var driver_id = ""
    
    func requestCliq(latitude: Double, longitude: Double) {
        
        let data: Dictionary<String, Any> = [Constants.NAME: rider, Constants.LATITUDE: latitude, Constants.LONGITUDE: longitude]
        
        DBProvider.Instance.requestRef.childByAutoId().setValue(data)
        
    }
    
    func cancelCliq() {
        
        DBProvider.Instance.requestRef.child(rider_id).removeValue()
    }
    
    func observeMessagesForDriver() {
        
        // RIDER REQUESTED AN UBER
        
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGITUDE] as? Double {
                        self.driverDelegate?.acceptCliq(lat: latitude, long: longitude);
                    }
                }
                
                if let name = data[Constants.NAME] as? String {
                    self.rider = name;
                }
                
            }
        
            // RIDER CANCELED UBER
            
            DBProvider.Instance.requestRef.observe(DataEventType.childRemoved, with: { (snapshot: DataSnapshot) in
            
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.NAME] as? String {
                        if name == self.rider {
                            self.rider = "";
                            self.driverDelegate?.riderCanceledCliq();
                        }
                    }
                }
            })
        }
        
        // Check if driver accepts cliq
        
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        self.driver_id = snapshot.key
                    }
                }
            }
        }
        
        // Driver canceled cliq
        
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        self.driverDelegate?.canceledCliq()
                    }
                }
            }
        }
    }
    
    
    func observeMessagesForRider() {
        
        //Calling Cliq
        
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        self.rider_id = snapshot.key
                        self.riderDelegate?.canCallCliq(delegateCalled: true)
                    }
                }
            }
        }
    
        
        //Cancelling Cliq
        
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        self.riderDelegate?.canCallCliq(delegateCalled: false)
                    }
                }
            }
        }
        
        // Driver accepted cliq
        
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String{
                    if self.driver == "" {
                        self.driver = name
                        self.riderDelegate?.driverAcceptedRequest(requestAccepted: true, driverName: name)
                    }
                }
            }
        }
        
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        self.driver = ""
                        self.riderDelegate?.driverAcceptedRequest(requestAccepted: false, driverName: name)
                    }
                }
            }
            
        }
        
    }
    
    func cliqAccepted(lat: Double, long: Double) {
        
        let data: Dictionary<String, Any> = [Constants.NAME: driver, Constants.LATITUDE: lat, Constants.LONGITUDE: long]
        
        DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data)
        
    }
    
    func cancelCliqForDriver() {
        DBProvider.Instance.requestAcceptedRef.child(driver_id).removeValue();
    }
    
}
