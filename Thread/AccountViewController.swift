//
//  AccountViewController.swift
//  Thread
//
//  Created by Developer on 12/1/16.
//  Copyright © 2016 JwitApps. All rights reserved.
//

import UIKit

import FirebaseAuth

class AccountViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let user = FIRAuth.auth()?.currentUser else {
            return
        }

        if let url = user.photoURL {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let imageData = data {
                    DispatchQueue.main.sync {
//                        self.imageView.image = UIImage(data: imageData)
                    }
                }
            }.resume()
        }
    }
}
