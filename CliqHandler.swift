//
//  CliqHandler.swift
//  cliq
//
//  Created by Oleg Zakharov on 28/05/2017.
//  Copyright © 2017 Cliq. All rights reserved.
//

import Foundation
import FirebaseDatabase

class CliqHandler {
    
    private static let _instance = CliqHandler()
    
    static var Instance: CliqHandler {
        return _instance
    }
    
    var rider = ""
    var driver = ""
    var rider_id = ""
    
    func requestCliq(latitude: Double, longitude: Double) {
        
        let data: Dictionary<String, Any> = [Constants.NAME: rider, Constants.LATITUDE: latitude, Constants.LONGITUDE: longitude]
        
        DBProvider.Instance.requestRef.childByAutoId().setValue(data)
        
    }
    
    
}
