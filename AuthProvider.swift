//
//  AuthProvider.swift
//  cliq
//
//  Created by Oleg Zakharov on 26/05/2017.
//  Copyright © 2017 Cliq. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias LoginHandler = (_ msg: String?) -> Void;

struct LoginErrorCode {
    static let INVALID_EMAIL = "Invalid Email";
    static let WRONG_PASSWORD = "Wrong password";
    static let PROBLEM_CONNECTING = "Problem connecting";
    static let USER_NOT_FOUND = "User not found";
    static let EMAIL_ALREADY_IN_USE = "Email already in use";
    static let WEAK_PASSWORD = "Weak password"
}

class AuthProvider {
    
    private static let _instance = AuthProvider();
    
    static var Instance: AuthProvider {
        return _instance
    }
    
    
    func login(withEmail: String, password: String, loginHandler: LoginHandler?) {
        
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: {(user, error) in
            
            if error != nil {
                self.handleErrors(err: error! as  NSError, loginHandler: loginHandler)
            } else {
                loginHandler?(nil);
            }
        })
        
    } //login func
    
    func signUp(withEmail: String, password: String, loginHandler: LoginHandler?) {
        
        Auth.auth().createUser(withEmail: withEmail, password: password, completion: {(user, error) in
        
            if error != nil {
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler)
            } else {
                
                if user?.uid != nil {
                    
                    //store into db
                    DBProvider.Instance.saveUser(withID: user!.uid, email: withEmail, password: password)
                    
                    //login
                    self.login(withEmail: withEmail, password: password, loginHandler: loginHandler)
                }
            }
        })
    }
    
    func logOut() -> Bool {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut();
                return true;
            } catch {
                return false;
            }
        }
        return true;
    }
    
    private func handleErrors(err: NSError, loginHandler: LoginHandler?) {
        
        if let errCode = AuthErrorCode(rawValue: err.code) {
            
            switch errCode {
                
            case .wrongPassword:
                loginHandler?(LoginErrorCode.WRONG_PASSWORD)
                break;
            case .invalidEmail:
                loginHandler?(LoginErrorCode.INVALID_EMAIL)
                break;
            case .userNotFound:
                loginHandler?(LoginErrorCode.USER_NOT_FOUND)
                break;
            case .emailAlreadyInUse:
                loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE)
                break;
            case .weakPassword:
                loginHandler?(LoginErrorCode.WEAK_PASSWORD)
                break;
            default:
                loginHandler?(LoginErrorCode.PROBLEM_CONNECTING)
                break;
            }
        }
    }
}
