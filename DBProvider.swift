//
//  DBProvider.swift
//  cliq
//
//  Created by Oleg Zakharov on 27/05/2017.
//  Copyright © 2017 Cliq. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider {
    
    private static let _instance = DBProvider();
    
    static var Instance: DBProvider {
        return _instance
    }
    
    var dbRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var ridersRef: DatabaseReference {
        return dbRef.child(Constants.RIDERS)
    }
    
    var driversRef: DatabaseReference {
        return dbRef.child(Constants.DRIVERS)
    }
    
    var requestRef: DatabaseReference {
        return dbRef.child(Constants.CLIQ_REQUEST)
    }
    
    var requestAcceptedRef: DatabaseReference {
        return dbRef.child(Constants.CLIQ_ACCEPTED)
    }
    
    func saveUser(withID: String, email: String, password: String) {
        
        if Variables.isRider {
            
            let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password, Constants.isRider: true]
        
            ridersRef.child(withID).child(Constants.DATA).setValue(data)
        } else {
            
            let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password, Constants.isRider: false]
            
            driversRef.child(withID).child(Constants.DATA).setValue(data)
        }
    }
    
}
