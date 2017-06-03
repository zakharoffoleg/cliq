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
    
    var clientsRef: DatabaseReference {
        return dbRef.child(Constants.CLIENTS)
    }
    
    var barbersRef: DatabaseReference {
        return dbRef.child(Constants.BARBERS)
    }
    
    var requestRef: DatabaseReference {
        return dbRef.child(Constants.CLIQ_REQUEST)
    }
    
    var requestAcceptedRef: DatabaseReference {
        return dbRef.child(Constants.CLIQ_ACCEPTED)
    }
    
    var finishHaircutRef: DatabaseReference {
        return dbRef.child(Constants.FINISH_HAIRCUT)
    }
    
    var finishedHaircutRef: DatabaseReference {
        return dbRef.child(Constants.FINISHED_HAIRCUTS)
    }
    
    func saveUser(withID: String, email: String, password: String) {
        
        if Variables.isClient {
            
            let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password, Constants.isClient: true]
            clientsRef.child(withID).child(Constants.DATA).setValue(data)
            
        } else {
            
            let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password, Constants.isClient: false]
            barbersRef.child(withID).child(Constants.DATA).setValue(data)
        }
    }
    
}
