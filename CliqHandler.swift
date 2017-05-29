//
//  CliqHandler.swift
//  cliq
//
//  Created by Oleg Zakharov on 28/05/2017.
//  Copyright © 2017 Cliq. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol CliqController: class {
    func acceptCliq(lat: Double, long: Double)
}

class CliqHandler {
    
    weak var delegate: CliqController?
    
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
    
    func observeMessagesForDriver() {
        
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                
                if let latitude = data[Constants.LATITUDE] as? Double{
                    if let longitude = data[Constants.LONGITUDE] as? Double{
                        
                        self.delegate?.acceptCliq(lat: latitude, long: longitude)
                    }
                }
            }
            
        }
    }
    
    
}
