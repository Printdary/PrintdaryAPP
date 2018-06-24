//
//  AppDelegate.swift
//  VideoCapture
//
//  Created by MacMini on 7/1/17.
//  Copyright © 2017 com.armomik. All rights reserved.
//
import UIKit
import Firebase
import UserNotifications
import Fabric
import Crashlytics




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var videoThumbnail = NSCache<AnyObject, AnyObject>()
    var sessionsForDelate = [String]()
    var newSessionButtonPressed = false
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
        -> Bool {
            
            
            Fabric.with([Crashlytics.self])
            UIApplication.shared.applicationIconBadgeNumber = 0
            //window = UIWindow(frame: UIScreen.main.bounds)
            //window?.makeKeyAndVisible()
            //window?.rootViewController = UINavigationController(rootViewController: ViewController())
            
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
            
            do {
                Network.reachability = try Reachability(hostname: "www.google.com")
                do {
                    try Network.reachability?.start()
                } catch let error as Network.Error {
                    print(error)
                } catch {
                    print(error)
                }
            } catch {
                print(error)
            }
           UIApplication.shared.statusBarStyle = .lightContent
            return true
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("not", deviceToken)
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02.2hhx", $1)})
        
        // Print it to console
        print("APNs device token: \(deviceTokenString)")
        UserDefaults.standard.set(deviceTokenString, forKey: "token")
        UserDefaults.standard.synchronize()
        
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
         print("fail")
        
    }
    
    
        
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("user info = \(userInfo)")
       
        if let dict = userInfo["aps"] as? [String: Any] {
            
            let arr = self.separateUserInfo(par: dict["alert"] as! String)
            let dict = ["Name" :arr[0], "Type" : Int.init(arr[1])!] as [String : Any]
            VideoDawnloader.sharedInstance.videoURLs.append(dict)
           if !VideoDawnloader.sharedInstance.isDawnloading {
                self.dawnloadVideo()
            }
        }
        
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
        if Auth.auth().currentUser?.uid == nil {
            
        }else {
          if let _ = userInfo["aps"] as? [String: Any] {
             let name = userInfo["sessionName"] as! String
                    _ = userInfo["userId"]
            let type = userInfo["type"] as! String
            let date =  userInfo["date"] as! String

            let dict = ["Name" :name, "Type" : Int.init(type)!, "date": date] as [String : Any]
            VideoDawnloader.sharedInstance.videoURLs.append(dict)
            if !VideoDawnloader.sharedInstance.isDawnloading {
                self.dawnloadVideo()
            }
            
        }
    }
        
    switch application.applicationState {
        
    case .inactive:
    print("Inactive")
    //Show the view with the content of the push
    completionHandler(.newData)
    
    case .background:
    print("Background")
    //Refresh the local model
    completionHandler(.newData)
    
    case .active:
    print("Active")
    //Show an in-app banner
    completionHandler(.newData)
    }
    }
    
    
     func dawnloadVideo( ) {
        
        if Auth.auth().currentUser?.uid == nil {
            
        } else {
        let dict = VideoDawnloader.sharedInstance.videoURLs[0]
        if let name = dict["Name"] as? String, let type = dict["Type"] as? Int ,let strDate = dict["date"] as? String {
            let queueName = "\(name)\(type)Download"
            
            let uid = Auth.auth().currentUser?.uid
            let concurrentQueue = DispatchQueue(label: queueName, attributes: .concurrent)
            concurrentQueue.sync {
                
                VideoUploader.sharedInstance.saveProcessedVideoPathToFirebaseDatabase(dateString: strDate, name: name, type: type, uid: uid!, success: {
                    print("SUCCESS saveProcessedVideoPathToFirebaseDatabase")
                    if VideoDawnloader.sharedInstance.videoURLs.count > 0 {
                    VideoDawnloader.sharedInstance.videoURLs.removeFirst()
                    }
                    if let VC = UIApplication.topViewController() as? SessionViewController {
                        VC.chackRecordedVideos(sessionName: name) {
                            
                        }
                    }
                    
                    if VideoDawnloader.sharedInstance.videoURLs.count > 0 {
                        self.dawnloadVideo()
                    } else {
                        VideoDawnloader.sharedInstance.isDawnloading = false
                    }
                    
                }, failured: { (error) in
                    print("FAIL saveProcessedVideoPathToFirebaseDatabase")
                    
                    VideoDawnloader.sharedInstance.videoURLs.removeFirst()
                    if let VC = UIApplication.topViewController() as? SessionViewController {
                        VC.chackRecordedVideos(sessionName: name) {
                            
                        }
                        
                    }
                    
                    if VideoDawnloader.sharedInstance.videoURLs.count > 0 {
                        self.dawnloadVideo()
                    } else {
                        VideoDawnloader.sharedInstance.isDawnloading = false
                    }
                    
                    
                })
                
            }
        }
        }

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
        

        
    }

    func separateUserInfo(par: String) -> Array<String> {
        let array = par.components(separatedBy: "_")
        return array
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


}


extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}











