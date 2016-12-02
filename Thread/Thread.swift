//
//  Thread.swift
//  Thread
//
//  Created by Developer on 11/28/16.
//  Copyright © 2016 JwitApps. All rights reserved.
//

import FirebaseDatabase
import SwiftTools

struct Thread {
    var key: String
    var name: String { return key }
    let creator: String
    
    let icon: UIImage?
    let banner: UIImage?
    
    init(name: String, creator: String, icon: UIImage?, banner: UIImage?) {
        self.key = name
        self.creator = creator
        
        self.icon = icon
        self.banner = banner
    }
    
    init(snapshot: FIRDataSnapshot) {
        self.key = snapshot.key

        guard let value = snapshot.value as? [String: Any] else { fatalError() }
        
        self.creator = value["creator"]! as! String
        
        self.icon = nil
        self.banner = nil
    }
}

extension Thread: DictionaryRepresentable {
    var dictionary: [String : Any] {
        return [
            "creator" : creator,
        ]
    }
}
