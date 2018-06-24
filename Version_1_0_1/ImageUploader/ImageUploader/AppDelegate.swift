//
//  AppDelegate.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 15.03.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseAuth


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,UNUserNotificationCenterDelegate, MessagingDelegate{

    var window: UIWindow?
    var imageSuccessfulyDetected:(()-> Void)?
    var tocken : [String : AnyObject]?
    var orientationLock = UIInterfaceOrientationMask.all


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NotificationCenter.default.addObserver(self, selector: #selector(handlerPostTocken), name: Notification.Name.init("DID_LOGIN"), object: nil)
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _,_ in   })
            // For iOS 10 data message (sent via FCM
            //  FIRMessaging.messaging().remoteMessageDelegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        
         FirebaseApp.configure()
        if Auth.auth().currentUser != nil {
            getUserInfo(userID: (Auth.auth().currentUser?.uid)!)
            let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let vc = storyboard.instantiateViewController(withIdentifier: "userB")
            self.window?.rootViewController = vc
           // try! Auth.auth().signOut()
        }
        // Override point for customization after application launch.
        
        UserDefaults.standard.set(nil, forKey: "unitID")
        return true
    }
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        if let refreshedToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            self.postToken(token: ["refreshedToken" : refreshedToken as AnyObject])
        }
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("fail")
        
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("user info = \(userInfo)")
        
        
        
    }
    
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
       // let vc : NotifaiViewController = NotifaiViewController()
        self.tocken = [Messaging.messaging().fcmToken!: Messaging.messaging().fcmToken! as AnyObject]
        self.postToken(token: tocken!)
    }
    
    
    func postToken(token:[String:AnyObject]){
        if Auth.auth().currentUser?.uid != nil {
        let ref = Database.database().reference()
        ref.child("fcmToken").child((Auth.auth().currentUser?.uid)!).updateChildValues(token)
        }
    }
    
    
    @objc func handlerPostTocken(){
        if Auth.auth().currentUser?.uid != nil  && self.tocken != nil{
            let ref = Database.database().reference()
            ref.child("fcmToken").child((Auth.auth().currentUser?.uid)!).updateChildValues(self.tocken!)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
       
        
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

    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([UNNotificationPresentationOptions.alert,UNNotificationPresentationOptions.sound,UNNotificationPresentationOptions.badge])
        print("userInfo = \(notification.request.content.userInfo)")
        
        self.perform(#selector(reloadFolowersView), with: nil, afterDelay: 1.3)
        
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    @objc func reloadFolowersView(){
        NotificationCenter.default.post(name: Notification.Name.init("Reload_following_request"), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name.init("RELOAD_FOLOWING_REQUESTS"), object: nil)
    }
    
    
    func getUserInfo(userID: String){
         Database.database().reference().child("User").child(userID).observe(.value) { (snapshot) in
            if let infoDict = snapshot.value as? [String : AnyObject]{
                UserModel.currentUser.name  = infoDict["Name"] as! String
                UserModel.currentUser.city  = infoDict["city"] as! String
                UserModel.currentUser.country  = infoDict["country"] as! String
                UserModel.currentUser.dateOfBirth  = infoDict["dateOfBirth"] as! String
                UserModel.currentUser.favoriteSubject  = infoDict["favoriteSubject"] as! String
                UserModel.currentUser.email  = infoDict["userEmailAddress"] as! String
                UserModel.currentUser.userID = infoDict["userID"] as! String
                do{
                    if let imageURL = URL.init(string: infoDict["imageURL"] as! String) {
                       let imageData = try Data.init(contentsOf: imageURL)
                        UserModel.currentUser.image = UIImage.init(data: imageData)
                    }
                    
                }catch _ {
                    
                }
                
            }
        }
    }

}

