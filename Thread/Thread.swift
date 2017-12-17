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
    var name: String {
        let tags = key.components(separatedBy: "|")
        return "#" + tags.sorted(by: {
            tagOrder[tags.index(of: $0)!] < tagOrder[tags.index(of: $1)!]
        }).joined(separator: " #")
    }
    let creator: String
    
    let icon: UIImage?
    let banner: UIImage?
    
    let tagOrder: [Int]
    
    init(tags: [String], creator: String, icon: UIImage?, banner: UIImage?) {
        let alphabeticalTags = tags.sorted()
       
        self.key = alphabeticalTags.joined(separator: "|")
        self.creator = creator
        
        self.tagOrder = alphabeticalTags.map { tags.index(of: $0)! }
        
        self.icon = icon
        self.banner = banner
    }
    
    init(snapshot: FIRDataSnapshot) {
        self.key = snapshot.key

        guard let value = snapshot.value as? [String: Any] else { fatalError() }
        
        self.tagOrder = value["tag_order"]! as! [Int]
        
        self.creator = value["creator"]! as! String
        
        self.icon = nil
        self.banner = nil
    }
}

extension Thread: DictionaryRepresentable {
    var dictionary: [String : Any] {
        return [
            "creator" : creator,
          "tag_order" : tagOrder,
        ]
    }
}
