//
//  Message.swift
//  Thread
//
//  Created by Developer on 11/30/16.
//  Copyright © 2016 JwitApps. All rights reserved.
//

import FirebaseDatabase
import SwiftTools

struct Message {
    let key: String
    let creator: String
    let body: String
    let timestamp: Date
    
    init(key: String, creator: String, body: String, timestamp: Date = Date()) {
        self.key = key
        self.creator = creator
        self.body = body
        self.timestamp = timestamp
    }
    
    init(snapshot: FIRDataSnapshot) {
        self.key = snapshot.key
        
        guard let value = snapshot.value as? [String: Any] else { fatalError() }
        
        self.creator = value["creator"]! as! String
        self.body = value["body"]! as! String
        self.timestamp = Date(timeIntervalSince1970: value["timestamp"]! as! TimeInterval)
    }
}

extension Message: DictionaryRepresentable {
    var dictionary: [String : Any] {
        return [
            "creator" : creator,
            "body" : body,
            "timestamp": timestamp.timeIntervalSince1970,
        ]
    }
}
