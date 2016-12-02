//
//  NewThreadViewController.swift
//  Thread
//
//  Created by Developer on 11/29/16.
//  Copyright © 2016 JwitApps. All rights reserved.
//

import MobileCoreServices
import UIKit

import Cartography

class NewThreadViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var uploadBannerButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var banner: UIImage?
    
    lazy var mediaPicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeImage as String]
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isHidden = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateSample()
        return true
    }
    
    func updateSample() {
        tableView.isHidden = banner == nil
        uploadBannerButton.isHidden = !tableView.isHidden
        
        tableView.reloadData()
    }
    
    @IBAction func uploadBannerPressed(sender: AnyObject) {
        present(mediaPicker, animated: true, completion: nil)
    }
}

extension NewThreadViewController: UINavigationControllerDelegate { }
extension NewThreadViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        image = image ?? info[UIImagePickerControllerOriginalImage] as? UIImage
        image = image ?? info[UIImagePickerControllerCropRect] as? UIImage
      
        banner = image
        updateSample()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.banner = nil
            self.updateSample()
        }
    }
}

extension NewThreadViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadTableViewCell") as? ThreadTableViewCell ?? Bundle.main.loadNibNamed("ThreadTableViewCell", owner: nil, options: nil)![0] as! ThreadTableViewCell
        
        cell.thread = Thread(name: nameField.text ?? "",
                           creator: "jwitcig",
                           icon: nil,
                           banner: banner)
        return cell
    }
}

extension NewThreadViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}
