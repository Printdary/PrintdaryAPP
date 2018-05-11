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
        CurrentSession.currentSession.imageArray = [UIImage]()
        CurrentSession.currentSession.audioArray = [AudioObject]()
         CurrentSession.currentSession.videosImagesArray = [UIImage]()
         CurrentSession.currentSession.videosArray = [URL]()
         CurrentSession.currentSession.modelImagesArray = [UIImage]()
         CurrentSession.currentSession.modelUrlArray = [String]()
    }
    
    
}


class CurrentSession: NSObject {
    
    static var currentSession = CurrentSession()
    var audioArray = [AudioObject]()
    var imageArray = [UIImage]()
    var videosArray = [URL]()
    var videosImagesArray = [UIImage]()
    var modelImagesArray = [UIImage]()
    var modelUrlArray = [String]()
    var croppedImage: UIImage?
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
