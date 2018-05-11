//
//  VideoDawnloader.swift
//  VideoCapture
//
//  Created by MacMini on 7/27/17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Firebase
import FirebaseDatabase
import Photos

class VideoDawnloader: NSObject {
    
    static let sharedInstance: VideoDawnloader = {
        let instance = VideoDawnloader()
        return instance
    }()

    var videoURLs = [[String : Any]]()
    var session = URLSession.shared
    var task : URLSessionDownloadTask?
    var isDawnloading  = false
    
    
    
    func downloadVideo(sessionName: String, type:Int, success:@escaping (_ videoURL: URL)->Void, failured: @escaping(_ error: String)->Void) {
        let uid = Auth.auth().currentUser?.uid
        let videoImageUrl = "http://52.175.233.168:52555/Videos/\(sessionName)_\(type)_\(uid!)_.mov"
        print("videoImageUrl = \(videoImageUrl)")
        let url = URL.init(string: videoImageUrl)
        self.isDawnloading = true
        
        task = session.downloadTask(with: url!, completionHandler: { (location: URL?, response: URLResponse?, error: Error?) -> Void in
            
            if location != nil{
                let data: NSData! = NSData.init(contentsOf: url!)
                do{
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                    let filePath="\(documentsPath)/tempFile.mp4";
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                       
                        data.write(toFile: filePath, atomically: true)
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: NSURL(fileURLWithPath: filePath) as URL)
                        }) { completed, error in
                            if completed {
                                success(NSURL(fileURLWithPath: filePath) as URL)
                                print("Video is saved!")
                            }
                        }
                    })
                }catch{
                    print("something went wrong, try again")
                    failured("Error dawnload")
                }
            }
        })
        task?.resume()
        
        
        
    }
    
    
    
    

    
    
    
    
    
    func getVideoLengthFromFirebase(sessionName: String, type: Int, succes:@escaping (_ lenght: String)->Void, failure: @escaping ()-> Void) {
        let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(sessionName).child("\(type)")
        ref.observeSingleEvent(of: .value, with: { [unowned self] (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let videoLenght = dict["length"]
                succes(videoLenght as! String)
            }else{
                failure()
            }
            
        })

        
    }
    
    
    
    func downloadVideoFromFirebase(sessionName: String, type: Int, success:@escaping(_ videoURL: URL)-> Void, failured:@escaping (_ error: Error)-> Void) {
        
       let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(sessionName).child("\(type)")
        ref.observeSingleEvent(of: .value, with: { [unowned self] (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let videoPath = dict["videoURL"]
                self.downloadVideoFromStorage(videoURL: videoPath! as! String, success: { (url) in
                    
                    success(url)
                },failured: { (error) in
                    failured(error)
                })
            }
            
        })
        
    }
    
    fileprivate func downloadVideoFromStorage(videoURL: String, success:@escaping(_ videoURL: URL)-> Void, failured:@escaping (_ error: Error)-> Void) {
        
   
        let storageRef = Storage.storage().reference(forURL: videoURL)
        storageRef.getData(maxSize: INT64_MAX) { (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            storageRef.getMetadata(completion: { (metadata, metadataErr) in
                
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    failured(error)
                    return
                }
                if (metadata?.contentType == "video/mov") {
                    print("It is video ")
                } else {
                    let downloadUrl = metadata?.downloadURL()
                    if downloadUrl != nil{
                        success(downloadUrl!)
                        //You will get your Video Url Here
                    }
                    
                }
            })
        }
        
     }
    
    
    
    func downloadProcessedVideoFromFirebase(sessionName: String, type: Int, success:@escaping(_ videoURL: URL)-> Void, failured:@escaping (_ error: Error)-> Void) {
        
        let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(sessionName).child("\(type)P")
        ref.observeSingleEvent(of: .value, with: { [unowned self] (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let videoPath = dict["videoURL"]
                self.downloadVideoFromStorage(videoURL: videoPath! as! String, success: { (url) in
                    
                    success(url)
                },failured: { (error) in
                    failured(error)
                })
            }
            
        })
        
    }
    
    
    
    func downloadVideoThumbnail(name: String, type: Int, complatition:@escaping (_ image: URL?)-> Void) {
        
        let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(name).child("\(type)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let img = (snapshot.value as! [String: Any])["imageURL"] {
                let url = URL.init(string: img as! String)
                complatition(url )
                return
            }
            complatition(nil)
        })
    }

    
    
}
