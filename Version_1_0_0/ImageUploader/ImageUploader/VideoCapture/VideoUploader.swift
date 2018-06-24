//
//  VideoUploader.swift
//  VideoCapture
//
//  Created by MacMini on 7/26/17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Firebase
import FirebaseDatabase

class VideoUploader: NSObject, URLSessionDelegate ,URLSessionDataDelegate{
    
    var dataTask: URLSessionDataTask?
    var session : URLSession?
    var videoURLs = [[String : Any]]()
    var isUploading = false
    
    static let sharedInstance: VideoUploader = {
        let instance = VideoUploader()
        return instance
    }()

    
    

    
    


   func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
       let progress = totalBytesSent// [[NSNumber numberWithInteger:totalBytesWritten] floatValue];
       let total = totalBytesExpectedToSend//[[NSNumber numberWithInteger: totalBytesExpectedToWrite] floatValue];
    let progress2 :Double = Double.init(progress)/Double.init(total)
       print("bytesSent = \(progress2)")
    }
    
    
 
    
    @objc func uploadVideoServer() {
        let currentDateString = self.getCurrentDate()
        self.isUploading = true
        let dict = VideoUploader.sharedInstance.videoURLs[0]
        let cell = dict["cell"] as! SessionCell
        let url = dict["url"] as! URL
        let pos = dict["type"] as! Int
        let name = dict["name"] as! String
        let uid = dict["uid"] as! String
        print("pos ==== \(pos)")
        cell.videoUploadIndicator.startAnimating()
        cell.playButton.isEnabled = false
        VideoUploader.sharedInstance.uploadVideoToServer(dateString : currentDateString,
                                                        sessionName : name,
                                                             videoUrl: url,
                                                             success: {[unowned self]  (result, strDate) in
                                                                print("UPLOAD TO SERVER SUCCESS")
                                                                DispatchQueue.main.async {
                                                                    cell.videoUploadIndicator.stopAnimating()
                                                                    cell.playButton.isEnabled = true
                                                                    
                                                                }
                                                                self.saveVideoPathToFirebaseDatabase(dateString:strDate,
                                                                                                     sessionName: name,
                                                                                    type: pos,
                                                                                    uid: uid,
                                                                                    success: {
                                                                                        
                                            if let VC = UIApplication.topViewController() as? SessionViewController {
                                                VC.chackRecordedVideos(sessionName:name ) {
                                                    
                                                }
                                                
                                            }
                                                
                                               self.videoURLs.removeFirst()
                                                if self.videoURLs.count > 0 {
                                                 print("uploaded to firebase \(pos)")
                                                    self.perform(#selector(self.uploadVideoServer), with: nil, afterDelay: 1.5)
                                                }else {
                                                    self.isUploading = false
                                                }
                                                                                        
                                               },
                                                failured: { (error) in
                                                print("Uploading to firebase failed")
                                if let rootViewController = UIApplication.topViewController() {
                                    let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: " \(pos) Upload failed")
                                    rootViewController.present(alert, animated: true, completion: nil)
                                }
                                                    self.videoURLs.removeFirst()
                                                    if self.videoURLs.count > 0 {
                                                self.perform(#selector(self.uploadVideoServer), with: nil, afterDelay: 1.5)
                                                    }else {
                                                        self.isUploading = false
                                                    }
                                               })
                                                                
                                                                
                },
                     failured: { (error, pos) in
                        print("error upload to server")
                        VideoUploader.sharedInstance.isUploading = false
                        print("error = \(error.localizedDescription)")
                        let dict = VideoUploader.sharedInstance.videoURLs[0]
                        let cell = dict["cell"] as! SessionCell
                        DispatchQueue.main.async {
                            cell.videoUploadIndicator.stopAnimating()
                            cell.playButton.isEnabled = true
                        }
                        if let rootViewController = UIApplication.topViewController() {
                            let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: " \(pos) Upload failed")
                            rootViewController.present(alert, animated: true, completion: nil)
                        }
                        VideoUploader.sharedInstance.videoURLs.removeFirst()
                        if self.videoURLs.count > 0 {
                            self.perform(#selector(self.uploadVideoServer), with: nil, afterDelay: 1.5)
                        }else {
                            self.isUploading = false
                        }
                        
            })
        
        
        
        
        
    }
    


    func getCurrentDate()-> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let currentDateString = formatter.string(from: Date())
        let trimmedString = currentDateString.removingWhitespaces()
        let str = trimmedString.replacingOccurrences(of: ":", with: "")
        let str1 = str.replacingOccurrences(of: "/", with: "")
        //let str2 = trimmedString.replacingOccurrences(of: ":", with: "")
        return str1
    }
 

    
    func saveVideoPathToFirebaseDatabase( dateString: String, sessionName: String,type: Int, uid: String, success:@escaping ()-> Void, failured:@escaping (_ error: Error)-> Void) {
        let dict = ["videoURL" : "http://52.175.233.168:52555/uploadedVideos/videos/\(sessionName)_\(type)_\(uid)_\(dateString).mov", "imageURL" : "http://52.175.233.168:52555/Videos/\(sessionName)_\(type)_\(uid)_\(dateString)_orginal.jpg"]
        //let pos = UserDefaults.standard.value(forKey: "position") as! Int
        let sessionName =  UserDefaults.standard.value(forKey: "sessionName") as! String
        let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(sessionName)
        ref.child("\(type)").updateChildValues(dict) { (error, reference) in
            if error != nil {
                failured(error!)
            } else{
                success()
            }
            
        }
    }
    
    
    
    func saveProcessedVideoPathToFirebaseDatabase(dateString: String, name: String, type: Int,  uid: String,  success:@escaping ()-> Void, failured:@escaping (_ error: Error)-> Void) {
        let dict = ["videoURL" : "http://52.175.233.168:52555/Videos/\(name)_\(type)_\(uid)_\(dateString)_.mov" , "imageURL" : "http://52.175.233.168:52555/Videos/\(name)_\(type)_\(uid)_\(dateString)_processed.jpg"]

        let pos = type
        let sessionName = name
        let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(sessionName)
        print("position === \(pos)")
        ref.child("\(pos)P").updateChildValues(dict) { (error, reference) in
            if error != nil {
                failured(error!)
            } else{
                
                success()
            }
            
        }
    }

    
   
    
    
  
    
    
    func checkUploadedVideosFor(session: String, callback:@escaping (_ _exitingVideos:[Int],  _ videoInfo: [[String: Any]])->Void)-> UIAlertController? {
        
    if VideoUploader.isConnected() {
        
        
        var exitingVideos = [Int]()
        var videoInfo = [["length" : "", "videoURL" : "",  "imageURL" : ""], ["length" : "", "videoURL" : "","imageURL" : ""] , ["length" : "", "videoURL" : "", "imageURL" : ""]]
        let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(session)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            ref.removeAllObservers()
            print(snapshot)
            if snapshot.hasChild("0") {
                if let value = snapshot.value as? [String : Any] {
                let dictInfo = value["0"] as? [String : String]
                    if let url =  dictInfo?["videoURL"] {
                        var dict = ["length" : "", "videoURL" : url,"imageURL" : ""]
                                if let imageURL =  dictInfo?["imageURL"] {
                                    dict ["imageURL"] = imageURL
                                }
                                videoInfo[0] = dict
                                exitingVideos.append(0)

                    }
                    

                
             }
            }
            if snapshot.hasChild("1") {
                if let value = snapshot.value as? [String : Any] {
                    let dictInfo = value["1"] as? [String : String]
                        if let url =  dictInfo?["videoURL"] {
                            var dict = ["length" : "", "videoURL" : url,"imageURL" : ""]
                            if let imageURL =  dictInfo?["imageURL"] {
                                dict ["imageURL"] = imageURL
                            }
                            videoInfo[1] = dict
                            exitingVideos.append(1)
                            
                        }
                    
                }
                
            }
            if snapshot.hasChild("2") {
                if let value = snapshot.value as? [String : Any] {
                    let dictInfo = value["2"] as? [String : String]
                        if let url =  dictInfo?["videoURL"] {
                            var dict = ["length" : "", "videoURL" : url,"imageURL" : ""]
                            if let imageURL =  dictInfo?["imageURL"] {
                                dict ["imageURL"] = imageURL
                            }
                            videoInfo[2] = dict
                            exitingVideos.append(2)
                            
                        }
                    
                }
                
            }
            callback(exitingVideos, videoInfo)
            
        })
            return nil
            
         }else {
            
            return  self.internetConnectionAlert()
        }
        
        
    }
    
    
    func checkUploadedProcessedVideosFor(session: String, callback:@escaping (_ _exitingVideos:[Int], _ videoInfo: [[String: Any]])->Void)-> UIAlertController? {
        if VideoUploader.isConnected() {
            var exitingVideos = [Int]()
            var videoInfo = [["videoURL" : "", "imageURL" : ""], ["videoURL" : "", "imageURL" : ""] , [ "videoURL" : "", "imageURL" : ""]]
            
            
            let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(session)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild("0P") {
                    if let value = snapshot.value as? [String : Any] {
                        let dict = value["0P"] as? [String : String]
                            if let url =  dict?["videoURL"] {
                                var dictInfo = ["videoURL" : url,"imageURL" : ""]
                                if let imageURL = dict?["imageURL"] {
                                    dictInfo["imageURL"] = imageURL
                                }
                                videoInfo[0] = dictInfo
                                exitingVideos.append(0)
                            }
                    }

                }
                if snapshot.hasChild("1P") {
                    if let value = snapshot.value as? [String : Any] {
                        let dict = value["1P"] as? [String : String]
                        if let url =  dict?["videoURL"] {
                            var dictInfo = ["videoURL" : url,"imageURL" : ""]
                            if let imageURL = dict?["imageURL"] {
                                dictInfo["imageURL"] = imageURL
                            }

                            videoInfo[1] = dictInfo
                            exitingVideos.append(1)
                        }
                    }

                }
                if snapshot.hasChild("2P") {
                    if let value = snapshot.value as? [String : Any] {
                        let dict = value["2P"] as? [String : String]
                        if let url =  dict?["videoURL"] {
                            var dictInfo = ["videoURL" : url,"imageURL" : ""]
                            if let imageURL = dict?["imageURL"] {
                                dictInfo["imageURL"] = imageURL
                            }

                            videoInfo[2] = dictInfo
                            exitingVideos.append(2)
                        }
                    }
                }
                callback(exitingVideos, videoInfo)
                
            })
            return nil
            
        }else {
            
            return  self.internetConnectionAlert()
        }
        
    }


    
    
    
    
    
    
    
    
    
    func uploadVideoToServer(dateString: String, sessionName:String, videoUrl: URL, success: @escaping(_ result: [String: Int], _ dateString: String)-> Void, failured: @escaping (_ error: Error, _ pos: String)-> Void) {
        
        var movieData: NSData?
        do {
            movieData = NSData.init(contentsOf: videoUrl)
        }
        if movieData == nil {
           return
        }
        let body = NSMutableData()
        body.append(movieData! as Data)
        let uid = Auth.auth().currentUser?.uid
        print("uid = \(uid!)")
        let token = UserDefaults.standard.value(forKey: "token") as! String
        print("token = \(token)")
       // let sessionName = UserDefaults.standard.value(forKey: "sessionName")
       // print("sessionName = \(sessionName!)")
        let pos = UserDefaults.standard.value(forKey: "position")
        print("pos = \(pos!)")
        print(movieData!.length)
        let urlStr = "http://52.175.233.168:5899/desktops/vahagn/\(sessionName)/\(token)/\(pos!)/\(movieData!.length)/\(uid!)/\(dateString)"
        print("urlSTR = \(urlStr)")
        let url = URL.init(string: urlStr)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = body as Data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("close", forHTTPHeaderField: "Connection")
        request.timeoutInterval = 120;
        request.setValue("\(uid!)_\(sessionName)_\(token)_\(pos!)_\(movieData!.length).mov", forHTTPHeaderField: "fileName")
        
        
        session = URLSession.init(configuration: .default, delegate: self, delegateQueue: .main)
        dataTask = session?.dataTask(with: request as URLRequest) { data,response,error in
            
            if (error != nil) {
                print("error = \(error?.localizedDescription ?? "error")")
                switch pos as! Int{
                case 0 :
                //failured(error!, "\("Frontal possition")")
                break
                case 1 :
                //failured(error!, "\("Right possition")")
                break
                case 2 :
                //failured(error!, "\("Left possition" )")
                break
                default :
                break
                    
                }
                
            }
            guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                failured(error!, "\(pos ?? "3")")
                return
            }
            
            let resultDict = ["type" : pos , "bytes" : movieData!.length]
            success(resultDict as! [String : Int], dateString)
        }
        dataTask?.resume()

    }
    
    
    
   
    
}


extension VideoUploader {
    
    class func isConnected()-> Bool {
        do {
            let rech = try Reachability.init()
            if (rech?.isConnectedToNetwork)!{
                return true
            }
            else {
                return false
            }
        }
        catch {
            return false
        }
    }
    
    
    
    func internetConnectionAlert () -> UIAlertController {
        
        let alert = UIAlertController(title: "Error", message: "You do not have internet access.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        return alert
        
    }
}

extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}


