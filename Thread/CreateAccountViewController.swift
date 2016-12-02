//
//  CreateAccountViewController.swift
//  Thread
//
//  Created by Developer on 11/30/16.
//  Copyright © 2016 JwitApps. All rights reserved.
//

import UIKit

import Cartography
import Firebase
import FirebaseDatabase
import TwitterKit

class CreateAccountViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    
    var username: String { return usernameField.text ?? "" }
    var displayName: String { return nameField.text ?? "" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        usernameField.addTarget(self, action: #selector(CreateAccountViewController.usernameFieldTextChanged), for: .editingChanged)
        
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            guard let session = session else {
                print("Error logging in with Twitter: \(error)")
                return
            }
            let credential = FIRTwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
        
            FIRAuth.auth()?.signIn(with: credential) { user, error in
                guard error == nil else {
                    print("Error signing in: \(error!)")
                    return
                }
                print("signed in as \(user!.displayName!)")
            }
        })
        view.addSubview(logInButton)
        constrain(logInButton, view) {
            $0.centerX == $1.centerX
            $0.centerY == $1.centerY * 1.5
        }
    }
    
    var timer: Timer?
    func usernameFieldTextChanged() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            self.checkUsernameExists(self.username)
        }
    }
    
    func checkUsernameExists(_ username: String) {
        let databaseRef = FIRDatabase.database().reference()
        let usersRef = databaseRef.child("users")
        usersRef.queryOrderedByKey().queryEqual(toValue: username).observeSingleEvent(of: .value, with: {
            
            if $0.childrenCount == 0 {
                print("you're good")
            } else {
                print("username taken")
            }
        })
    }
    
    @IBAction func createAccountPressed(sender: AnyObject) {
        let user = User(username: username, displayName: displayName)
        let databaseRef = FIRDatabase.database().reference()
        let usersRef = databaseRef.child("users")
    }
}
