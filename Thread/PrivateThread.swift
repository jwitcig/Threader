//
//  PrivateThread.swift
//  Thread
//
//  Created by Developer on 3/6/17.
//  Copyright © 2017 JwitApps. All rights reserved.
//

import FirebaseDatabase
import SwiftTools

struct PrivateThread {
    var key: String
    
    var participants: [String]
    
    let icon: UIImage?
    let banner: UIImage?
    
    init(name: String, participants: [String], icon: UIImage?, banner: UIImage?) {
        self.key = name
        self.participants = participants
        
        self.icon = icon
        self.banner = banner
    }
    
    init(snapshot: FIRDataSnapshot) {
        self.key = snapshot.key
        
        guard let value = snapshot.value as? [String : Any] else { fatalError() }
        
        self.participants = Array((value["participants"]! as! [String: Any]).keys)
        
        self.icon = nil
        self.banner = nil
    }
}

extension PrivateThread: DictionaryRepresentable {
    var dictionary: [String : Any] {
        return [
            "participants" : participants.reduce([String : Any]()) {
                var value = $0
                value[$1] = true
                return value
            },
        ]
    }
}
