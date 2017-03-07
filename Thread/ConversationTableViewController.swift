//
//  ConversationTableViewController.swift
//  Thread
//
//  Created by Developer on 11/29/16.
//  Copyright © 2016 JwitApps. All rights reserved.
//

import MobileCoreServices
import UIKit

import Cartography
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

struct Conversation {
    let firstName: String?
    let lastName: String?
    let preferredName: String?
    let smsNumber: String
    let id: String?
    let latestMessage: String?
    let isRead: Bool
}

class ConversationViewController: UIViewController {
    var messages = [Message]()
    let defaults = UserDefaults.standard
    var conversation: Conversation?
    
    var thread: Thread!
    
    var bottomToolbarBottomConstraint: ConstraintGroup!
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MessageCell")
        return collectionView
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("send", for: .normal)
        
        button.addTarget(self, action: #selector(ConversationViewController.sendPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.collectionView, self.bottomStack])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    lazy var bottomStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.textField, self.sendButton])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector( ConversationViewController.keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        view.addSubview(mainStack)
        constrain(mainStack, view) {
            $0.top == $1.topMargin
            $0.bottom == $1.bottom
            $0.leading == $1.leading
            $0.trailing == $1.trailing
        }
        
        collectionView.backgroundView?.backgroundColor = .gray
        collectionView.backgroundColor = .red
        
        constrain(textField) {
            $0.height == 44
        }
        
        let databaseRef = FIRDatabase.database().reference()
        let activeRef = databaseRef.child("active")
        let currentActivityRef = activeRef.child(thread.name).child(FIRAuth.auth()!.currentUser!.uid)
        currentActivityRef.setValue(true)
        currentActivityRef.onDisconnectRemoveValue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let databaseRef = FIRDatabase.database().reference()
        self.messages = []
        databaseRef.child("messages/"+thread.name).observe(.childAdded, with: {
            self.messages.append(Message(snapshot: $0))
            
            self.collectionView.reloadData()
            
            let finalPath = IndexPath(row: self.messages.count-1, section: 0)
            self.collectionView.scrollToItem(at: finalPath, at: .bottom, animated: true)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let databaseRef = FIRDatabase.database().reference()
        let activeRef = databaseRef.child("active")
        let currentActivityRef = activeRef.child(thread.name).child(FIRAuth.auth()!.currentUser!.uid)
        currentActivityRef.removeValue()
    }
    
    func setupBackButton() {
        let navigationBar = UINavigationBar()

        let back = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(ConversationViewController.backPressed))
    
        let navigationItem = UINavigationItem()
        navigationItem.title = thread.name
        
        navigationItem.leftBarButtonItem = back
        navigationBar.items = [navigationItem]
        view.addSubview(navigationBar)
        constrain(navigationBar, view) {
            $0.top == $1.top + 20
            $0.leading == $1.leading
            $0.trailing == $1.trailing
            
            $0.height == 44
        }
       
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        
        let statusBarCover = UIView()
        statusBarCover.backgroundColor = .white
        view.addSubview(statusBarCover)
        constrain(statusBarCover, view) {
            $0.leading == $1.leading
            $0.trailing == $1.trailing
            $0.top == $1.top
            $0.bottom == $1.top + 20
        }
    }
    
    func backPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func sendPressed(_ sender: Any) {
        guard let text = textField.text else { return }
        guard text.characters.count > 0 else { return }
        
        let databaseRef = FIRDatabase.database().reference()
        let path = databaseRef.child("messages/"+thread.name).childByAutoId()
        
        let message = Message(key: path.key, creator: "jwitcig", body: text)
        path.setValue(message.dictionary)
    }
    
    func keyboardDidShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect else { return }
        
        print(keyboardFrame.height)
        
        
        constrain(mainStack) { (view: LayoutProxy) -> Void in
            view.bottom == view.superview!.bottom - keyboardFrame.height
        }
        
        view.layoutIfNeeded()
    }
}

extension ConversationViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.row]
        
        let label = UILabel()
        label.text = message.body
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .white
        cell.contentView.addSubview(label)
        constrain(label, cell.contentView) {
            $0.center == $1.center
            $0.size == $1.size
        }
        
        return cell
    }
}

extension ConversationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
