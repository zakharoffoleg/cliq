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
}

protocol RiderCliqController: class {
    func canCallCliq(delegateCalled: Bool)
}

class CliqHandler {
    
    weak var driverDelegate: DriverCliqController?
    weak var riderDelegate: RiderCliqController?
    
    private static let _instance = CliqHandler()
    
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
        
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double{
                    if let longitude = data[Constants.LONGITUDE] as? Double{
                        self.driverDelegate?.acceptCliq(lat: latitude, long: longitude)
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
    }
    
    
}
