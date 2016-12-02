//
//  Message.swift
//  Thread
//
//  Created by Developer on 11/30/16.
//  Copyright © 2016 JwitApps. All rights reserved.
//

import FirebaseDatabase
import SwiftTools

struct User {
    let key: String
    var username: String { return key }
    let displayName: String
    let timestamp: Date
    
    init(username: String, displayName: String) {
        self.key = username
        self.displayName = displayName
        self.timestamp = Date()
    }
    
    init(snapshot: FIRDataSnapshot) {
        self.key = snapshot.key
        
        guard let value = snapshot.value as? [String: Any] else { fatalError() }
        
        self.displayName = value["displayName"]! as! String
        self.timestamp = Date(timeIntervalSince1970: value["timestamp"]! as! TimeInterval)
    }
}

extension User: DictionaryRepresentable {
    var dictionary: [String : Any] {
        return [
            "displayName" : displayName,
            "timestamp": timestamp.timeIntervalSince1970,
        ]
    }
}
