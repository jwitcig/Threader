//
//  AppDelegate.swift
//  Thread
//
//  Created by Developer on 11/28/16.
//  Copyright © 2016 JwitApps. All rights reserved.
//

import UIKit
import UserNotifications

import Fabric
import Firebase
import FirebaseMessaging
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FirebaseConfigurable, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Twitter.self])
        configureFirebase()
        
        // Messaging
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        connectToFCM()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        FIRInstanceID.instanceID().setAPNSToken(deviceToken as Data, type: .sandbox)
    }
    
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Let FCM know about the message for analytics etc.
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.childByAutoId().setValue(false)
    }
}

extension AppDelegate: FIRMessagingDelegate {
    /// The callback to handle data message received via FCM for devices running iOS 10 or above.
    public func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("something showed up!")
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
    }

    func connectToFCM() {
        // Won't connect since there is no token
        guard let token = FIRInstanceID.instanceID().token() else {
            return
        }
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        FIRDatabase.database().reference().child("users/"+uid).setValue(token)
        
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func sendDataMessageFailure(message: Notification) {
        let messageID = message.object
    }
    
    func sendDataMessageSuccess(message: Notification) {
        let messageID = message.object
        let userInfo = message.userInfo
    }
}

public protocol FirebaseConfigurable: class {
    var servicesFileName: String { get }
    
    func configureFirebase()
}

public extension FirebaseConfigurable {
    internal var bundle: Bundle {
        return Bundle(for: type(of: self) as AnyClass)
    }
    
    internal var servicesFileName: String {
        return bundle.infoDictionary!["Google Services File"] as! String
    }
    
    public func configureFirebase() {
        guard FIRApp.defaultApp() == nil else { return }
        
        let options = FIROptions(contentsOfFile: bundle.path(forResource: servicesFileName, ofType: "plist"))!
        FIRApp.configure(with: options)
    }
}

