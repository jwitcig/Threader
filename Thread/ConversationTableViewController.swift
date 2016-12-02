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
import FirebaseDatabase
import JSQMessagesViewController

struct Conversation {
    let firstName: String?
    let lastName: String?
    let preferredName: String?
    let smsNumber: String
    let id: String?
    let latestMessage: String?
    let isRead: Bool
}

class ConversationTableViewController: JSQMessagesViewController {
    var messages = [JSQMessage]()
    let defaults = UserDefaults.standard
    var conversation: Conversation?
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    fileprivate var displayName: String!
    
    var thread: Thread!
    
    lazy var mediaPicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeVideo as String]
        return picker
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("messages/"+thread.name).observe(.value, with: {
            self.messages = []
            
            let messages = ($0.children.allObjects as! [FIRDataSnapshot]).map(Message.init).sorted { $0.timestamp.compare($1.timestamp) == .orderedAscending }
            
            for message in messages {
                let senderName = self.messages.last?.senderDisplayName == message.creator ? "" : message.creator
                
                let visualMessage = JSQMessage(senderId: message.creator, senderDisplayName: senderName, date: message.timestamp, text: message.body)
                self.messages.append(visualMessage!)
                
                self.finishReceivingMessage(animated: true)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaults.set(true, forKey: Setting.removeAvatar.rawValue)
    
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        
        senderId = "jwitcig"
        senderDisplayName = "Jonah Witcig"
        
        setupBackButton()
        
        inputToolbar.contentView.leftBarButtonItem.removeFromSuperview()
        
        /**
         *  Override point:
         *
         *  Example of how to cusomize the bubble appearence for incoming and outgoing messages.
         *  Based on the Settings of the user display two differnent type of bubbles.
         *
         */
        
        if defaults.bool(forKey: Setting.removeBubbleTails.rawValue) {
            // Make taillessBubbles
            incomingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
            outgoingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).outgoingMessagesBubbleImage(with: UIColor.lightGray)
        } else {
            // Bubbles with tails
            incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
            outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.lightGray)
        }
        
        /**
         *  Example on showing or removing Avatars based on user settings.
         */
        
        if defaults.bool(forKey: Setting.removeAvatar.rawValue) {
            collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        } else {
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        }
        
        // Show Button to simulate incoming messages
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.jsq_defaultTypingIndicator(), style: .plain, target: self, action: #selector(receiveMessagePressed))
        
        // This is a beta feature that mostly works but to make things more stable it is diabled.
        collectionView?.collectionViewLayout.springinessEnabled = false
        
        automaticallyScrollsToMostRecentMessage = true
        
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
    }
    
    func setupBackButton() {
        let navigationBar = UINavigationBar()

        let back = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(ConversationTableViewController.backPressed))
    
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
    
    func receiveMessagePressed(_ sender: UIBarButtonItem) {
        /**
         *  DEMO ONLY
         *
         *  The following is simply to simulate received messages for the demo.
         *  Do not actually do this.
         */
        
        /**
         *  Show the typing indicator to be shown
         */
        self.showTypingIndicator = !self.showTypingIndicator
        
        /**
         *  Scroll to actually view the indicator
         */
        self.scrollToBottom(animated: true)
        
        /**
         *  Copy last sent message, this will be the new "received" message
         */
        var copyMessage = self.messages.last?.copy()
        
        if (copyMessage == nil) {
            copyMessage = JSQMessage(senderId: "jwitcig", displayName: "Jonah Witcig", text: "First received!")
        }
        
        var newMessage:JSQMessage!
        var newMediaData:JSQMessageMediaData!
        var newMediaAttachmentCopy:AnyObject?
        
        if (copyMessage! as AnyObject).isMediaMessage() {
            /**
             *  Last message was a media message
             */
            let copyMediaData = (copyMessage! as AnyObject).media
            
            switch copyMediaData {
            case is JSQPhotoMediaItem:
                let photoItemCopy = (copyMediaData as! JSQPhotoMediaItem).copy() as! JSQPhotoMediaItem
                photoItemCopy.appliesMediaViewMaskAsOutgoing = false
                
                newMediaAttachmentCopy = UIImage(cgImage: photoItemCopy.image!.cgImage!)
                
                /**
                 *  Set image to nil to simulate "downloading" the image
                 *  and show the placeholder view5017
                 */
                photoItemCopy.image = nil;
                
                newMediaData = photoItemCopy
            case is JSQLocationMediaItem:
                let locationItemCopy = (copyMediaData as! JSQLocationMediaItem).copy() as! JSQLocationMediaItem
                locationItemCopy.appliesMediaViewMaskAsOutgoing = false
                newMediaAttachmentCopy = locationItemCopy.location!.copy() as AnyObject?
                
                /**
                 *  Set location to nil to simulate "downloading" the location data
                 */
                locationItemCopy.location = nil;
                
                newMediaData = locationItemCopy;
            case is JSQVideoMediaItem:
                let videoItemCopy = (copyMediaData as! JSQVideoMediaItem).copy() as! JSQVideoMediaItem
                videoItemCopy.appliesMediaViewMaskAsOutgoing = false
                newMediaAttachmentCopy = (videoItemCopy.fileURL! as NSURL).copy() as AnyObject?
                
                /**
                 *  Reset video item to simulate "downloading" the video
                 */
                videoItemCopy.fileURL = nil;
                videoItemCopy.isReadyToPlay = false;
                
                newMediaData = videoItemCopy;
            case is JSQAudioMediaItem:
                let audioItemCopy = (copyMediaData as! JSQAudioMediaItem).copy() as! JSQAudioMediaItem
                audioItemCopy.appliesMediaViewMaskAsOutgoing = false
                newMediaAttachmentCopy = (audioItemCopy.audioData! as NSData).copy() as AnyObject?
                
                /**
                 *  Reset audio item to simulate "downloading" the audio
                 */
                audioItemCopy.audioData = nil;
                
                newMediaData = audioItemCopy;
            default:
                assertionFailure("Error: This Media type was not recognised")
            }
            
            newMessage = JSQMessage(senderId: "jwitcig", displayName: "Jonah Witcig", media: newMediaData)
        }
        else {
            /**
             *  Last message was a text message
             */
            
            newMessage = JSQMessage(senderId: "jwitcig", displayName: "Jonah Witcig", text: (copyMessage! as AnyObject).text)
        }
        
        /**
         *  Upon receiving a message, you should:
         *
         *  1. Play sound (optional)
         *  2. Add new JSQMessageData object to your data source
         *  3. Call `finishReceivingMessage`
         */
        
        self.messages.append(newMessage)
        self.finishReceivingMessage(animated: true)
        
        if newMessage.isMediaMessage {
            /**
             *  Simulate "downloading" media
             */
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                /**
                 *  Media is "finished downloading", re-display visible cells
                 *
                 *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
                 *
                 *  Reload the specific item, or simply call `reloadData`
                 */
                
                switch newMediaData {
                case is JSQPhotoMediaItem:
                    (newMediaData as! JSQPhotoMediaItem).image = newMediaAttachmentCopy as? UIImage
                    self.collectionView!.reloadData()
                case is JSQLocationMediaItem:
                    (newMediaData as! JSQLocationMediaItem).setLocation(newMediaAttachmentCopy as? CLLocation, withCompletionHandler: {
                        self.collectionView!.reloadData()
                    })
                case is JSQVideoMediaItem:
                    (newMediaData as! JSQVideoMediaItem).fileURL = newMediaAttachmentCopy as? URL
                    (newMediaData as! JSQVideoMediaItem).isReadyToPlay = true
                    self.collectionView!.reloadData()
                case is JSQAudioMediaItem:
                    (newMediaData as! JSQAudioMediaItem).audioData = newMediaAttachmentCopy as? Data
                    self.collectionView!.reloadData()
                default:
                    assertionFailure("Error: This Media type was not recognised")
                }
            }
        }
    }
    
    // MARK: JSQMessagesViewController method overrides
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        /**
         *  Sending a message. Your implementation of this method should do *at least* the following:
         *
         *  1. Play sound (optional)
         *  2. Add new <JSQMessageData> object to your data source
         *  3. Call `finishSendingMessage`
         */
        
        let visualMessage = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)!
        
        let databaseRef = FIRDatabase.database().reference()
        let threadMessages = databaseRef.child("messages/"+thread.name)
        let newMessageRef = threadMessages.childByAutoId()
        
        let message = Message(key: newMessageRef.key, creator: senderId, body: visualMessage.text)
            
        newMessageRef.setValue(message.dictionary, withCompletionBlock: { error, ref in
        
        })
        
        messages.append(visualMessage)
        finishSendingMessage(animated: true)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        
        let sheet = UIAlertController(title: "Media messages", message: nil, preferredStyle: .actionSheet)
        
        let photoVideoAction = UIAlertAction(title: "Send photo/video", style: .default) { action in
            self.launchMediaPicker()
        }
    
//        let locationAction = UIAlertAction(title: "Send location", style: .default) { action in
//            self.addMedia(self.buildLocationItem())
//        }
        
//        let audioAction = UIAlertAction(title: "Send audio", style: .default) { action in
//            self.addMedia(self.buildAudioItem())
//        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(photoVideoAction)
//        sheet.addAction(locationAction)
//        sheet.addAction(audioAction)
        sheet.addAction(cancelAction)
        present(sheet, animated: true, completion: nil)
    }
    
    func launchMediaPicker() {
        present(mediaPicker, animated: true, completion: nil)
    }
    
    func buildAudioItem() -> JSQAudioMediaItem {
        let sample = Bundle.main.path(forResource: "jsq_messages_sample", ofType: "m4a")
        let audioData = try? Data(contentsOf: URL(fileURLWithPath: sample!))
        
        let audioItem = JSQAudioMediaItem(data: audioData)
        
        return audioItem
    }
    
    func buildLocationItem() -> JSQLocationMediaItem {
        let ferryBuildingInSF = CLLocation(latitude: 37.795313, longitude: -122.393757)
        
        let locationItem = JSQLocationMediaItem()
        locationItem.setLocation(ferryBuildingInSF) {
            self.collectionView!.reloadData()
        }
        
        return locationItem
    }
    
    func addMedia(_ media: JSQMediaItem) {
        let message = JSQMessage(senderId: "jwitcig", displayName: "Jonah Witcig", media: media)!
        messages.append(message)
        
        //Optional: play sent sound
        
        finishSendingMessage(animated: true)
    }
    
    //MARK: JSQMessages CollectionView DataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        
        return messages[indexPath.item].senderId == "jwitcig" ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        let message = messages[indexPath.item]
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        /**
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         *  The other label text delegate methods should follow a similar pattern.
         *
         *  Show a timestamp for every 3rd message
         */
        if (indexPath.item % 3 == 0) {
            let message = self.messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item]
        
        // Displaying names above messages
        //Mark: Removing Sender Display Name
        /**
         *  Example on showing or removing senderDisplayName based on user settings.
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         */
        if defaults.bool(forKey: Setting.removeSenderDisplayName.rawValue) {
            return nil
        }
        
        if message.senderId == self.senderId {
            return nil
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        /**
         *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
         */
        
        /**
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         *  The other label height delegate methods should follow similarly
         *
         *  Show a timestamp for every 3rd message
         */
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        /**
         *  Example on showing or removing senderDisplayName based on user settings.
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         */
        if defaults.bool(forKey: Setting.removeSenderDisplayName.rawValue) {
            return 0.0
        }
        
        /**
         *  iOS7-style sender name labels
         */
        let currentMessage = self.messages[indexPath.item]
        
        if currentMessage.senderId == self.senderId {
            return 0.0
        }
        
        if indexPath.item > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
}

extension ConversationTableViewController: UINavigationControllerDelegate { }
extension ConversationTableViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        let videoUrl = info[UIImagePickerControllerMediaURL] as? URL
        if let path = videoUrl?.path, UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
            UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil)
        }
    
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        image = image ?? info[UIImagePickerControllerOriginalImage] as? UIImage
        image = image ?? info[UIImagePickerControllerCropRect] as? UIImage
        
        if let image = image {
            addMedia(JSQPhotoMediaItem(image: image))
        }
        if let url = videoUrl {
            addMedia(JSQVideoMediaItem(fileURL: url, isReadyToPlay: true))
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
}
