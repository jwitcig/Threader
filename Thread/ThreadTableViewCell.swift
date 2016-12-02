//
//  ThreadTableViewCell.swift
//  Thread
//
//  Created by Developer on 11/28/16.
//  Copyright © 2016 JwitApps. All rights reserved.
//

import UIKit

import Cartography

class ThreadTableViewCell: UITableViewCell {
    override var reuseIdentifier: String? { return "ThreadTableViewCell" }
    
    @IBOutlet weak var threadNameLabel: UILabel!
    @IBOutlet weak var bannerView: UIImageView!
    
    var thread: Thread! {
        didSet {
            threadNameLabel.text = thread.name
//            bannerView.image = thread.banner
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        constrain(contentView, self) {
            $0.width == $1.width
            $0.height == $1.height
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
