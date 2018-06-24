//
//  Helper.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 05.04.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit
import FCAlertView
import Firebase
import UIKit
class Helper: NSObject {
    
    

   class func showAlertWith(title: String, alertMessage: String){
        let alert = FCAlertView.init()
         alert.showAlert(withTitle: title,
                        withSubtitle: alertMessage,
                        withCustomImage: UIImage.init(named: "checkbox"),
                        withDoneButtonTitle: "OK",
                        andButtons: nil)
    }
    
    
    class func generateAutoId(){
        let autoID = Database.database().reference().childByAutoId().key
        UserModel.currentUser.uploadID = autoID
        CurrentSession.currentSession.imageArray = [ImageObject]()
        CurrentSession.currentSession.audioArray = [AudioObject]()
        CurrentSession.currentSession.videosArray = [VideoObject]()
    }
    
    
}


class CurrentSession: NSObject {
    
    static var currentSession = CurrentSession()
    var audioArray   = [AudioObject]()
    var imageArray   = [ImageObject]()
    var videosArray  = [VideoObject]()
    var croppedImage: UIImage?
    var modelsArray  = [ModelObject]()
    var urlArray     = [UrlObject]()
    var title = ""
    var category = ""
    var folder = ""
    var note = ""
    
}

class PathModel: NSObject {
    static var shared = PathModel()
    var selectedTopic : String?
    var selectedChapter : String?
    var existingChapters = [ChapterModel]()
}

class Downloader : NSObject {
    class func load(url: URL, to localUrl: URL? , completion: @escaping (_ names: [String]) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = try! URLRequest.init(url: url)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                   
                    do {
                        let text2 = try String(contentsOf: tempLocalUrl, encoding: .utf8)
                        let namesArray = text2.components(separatedBy:"\n")
                         print("Success: \(text2)")
                         completion(namesArray)
                    }
                    catch {/* error handling here */}
                }
                
               
                
            } else {
                print("Failure: %@", error?.localizedDescription);
            }
        }
        task.resume()
    }
}

struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
}
