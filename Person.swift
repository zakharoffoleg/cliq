//
//  Person.swift
//  cliq
//
//  Created by Oleg Zakharov on 25/05/2017.
//  Copyright © 2017 Cliq. All rights reserved.
//

import Foundation

class Person {
    
    private var _name = "";
    private var _last_name = "";
    
    var name: String {
        
        get {
            return _name;
        }
        
        set {
            _name = newValue;
        }
    }
}
