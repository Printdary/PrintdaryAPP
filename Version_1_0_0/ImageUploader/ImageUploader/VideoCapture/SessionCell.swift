//
//  SessionCell.swift
//  VideoCapture
//
//  Created by MacMini on 7/25/17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import  AVKit

class SessionCell: UITableViewCell {
    
    var videoType: Int?
    var dawnloadTimer: Timer?
    var videoLength: String?
    var result: [String: Any]?
    var originalVideoURL : URL?
    var oprocessedVideoURL : URL?
    @IBOutlet weak var processedImage: UIImageView!
    @IBOutlet weak var originalImage: UIImageView!
    var sessionName: String?
    var parrentController: SessionViewController?
    var emptyVideoPressed: ((_ type: Int, _ cell : SessionCell)->Void)?
    
    @IBOutlet weak var processedIndicator: UIActivityIndicatorView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var videoUploadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signForOriginalVideo: UIImageView!
    @IBOutlet weak var signForProcessedVide: UIImageView!
    
   let appObj = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var labelForPosition: UILabel!
    
    var originalVideoExist: Bool = false
    var processedVideoExist: Bool = false
    var isOriginalVideoExist: Bool {
        set {
            self.originalVideoExist = newValue
        }
        get {
            return self.originalVideoExist
        }
    }
    var getSessionName : String {
        get {
            if self.sessionName != nil {
                return self.sessionName!
            }else {
                return ""
            }
        }
    }
    
    var getVideotype : Int {
        get {
            if self.videoType != nil {
                return self.videoType!
            }else {
                return 3
            }
        }
    }
    

    
    
    override func awakeFromNib() {
        
        self.originalImage.layer.cornerRadius = self.originalImage.frame.size.width / 10.0
        self.processedImage.layer.cornerRadius = self.processedImage.frame.size.width / 10.0
       

    }
    
       
    func addSuccessSign() {
        DispatchQueue.main.async {
            self.signForOriginalVideo.isHidden = false
        }
    }
    
    func addSuccessSignProcessed() {
        DispatchQueue.main.async {
           // self.signForOriginalVideo.isHidden = false
            self.signForProcessedVide.image = UIImage.init(named: "ptichka1")
        }
    }

    

    func setupCell(name: String?, type: Int, parrent : SessionViewController, length: String, videoURL: String, imageUrl : String) {
        self.signForOriginalVideo.isHidden = true
        self.sessionName = name
        self.videoType = type
        self.parrentController = parrent
        self.videoLength = length
        
        if let url = URL.init(string: videoURL) {
            self.originalVideoURL = url
            self.isOriginalVideoExist = true
            
           
        }
        
        if let url = URL.init(string: imageUrl) {
            if let image = appObj.videoThumbnail.object(forKey: "\(url)\(self.getVideotype)" as AnyObject) {
                self.originalImage.image = (image as! UIImage)
                self.addSuccessSign()
            } else {
              self.setupImages(url: url, type: type)
            }
        }
        
        
       
            let queueName = "\(sessionName)\(type)ProcessedCheck"
            let concurrentQueue = DispatchQueue(label: queueName, attributes: .concurrent)
            concurrentQueue.sync {
                self.sessionName = UserDefaults.standard.value(forKey: "sessionName") as? String
                self.checkIsProcessedVideoExistOnFirebase(succes: {
                self.processedVideoExist = true
                }, failured: {  
                    DispatchQueue.main.async {
                       // self.processedIndicator.startAnimating()
                       // self.signForProcessedVide.isHidden = true
                    }
                   
                  
                    
                    
                })
            }
        
            
    }
        

    
    
    func setupImages(url: URL, type: Int) {
        
        self.originalImage.sd_setImage(with: url, completed: { (image, error, type, url) in
            if image != nil {
            self.appObj.videoThumbnail.setObject(image!, forKey:   "\(url)\(type)" as AnyObject)
            self.addSuccessSign()
            }
        })
        
        
    }
    
    func setupProcessImages(url: URL, type: Int) {
        if let procImage = self.appObj.videoThumbnail.object(forKey: "\(url)\(type)Processed" as AnyObject) {
            self.processedImage.image = procImage as? UIImage
            self.processedVideoExist = true
            self.addSuccessSignProcessed()
        } else {

            self.processedImage.sd_setImage(with: url, completed: { (image, error, type, url) in
                if image != nil {
                DispatchQueue.main.async{
                    self.appObj.videoThumbnail.setObject(image!, forKey:   "\(url)\(type)Processed" as AnyObject)
                    self.addSuccessSignProcessed()
                    self.processedIndicator.stopAnimating()
                    self.signForProcessedVide.isHidden = false
                }
                }

        })
               }
    }

    
   
    
    func getVideoLenght() {
        VideoDawnloader.sharedInstance.getVideoLengthFromFirebase(sessionName: self.getSessionName, type: self.getVideotype, succes: { (lenght) in
        }) {
            print("error")
        }
    }
    
   
    
    
    @IBAction func playButtonAction(_ sender: Any) {
        
       
            if SessionCell.isConnected() {
                 if self.isOriginalVideoExist {
                        if (self.originalVideoURL != nil) {
                            
                            self.setupAvplayerViewController(videoURL: self.originalVideoURL!)
                        }
            
                 }
                  else {
                           self.emptyVideoPressed?(self.videoType!, self)
                         }
            } else {
                let alert = self.internetConnectionAlert()
                self.parrentController?.present(alert, animated: true, completion: nil)
            }
        
    }
    
    
    
    @IBAction func processedButtonAction(_ sender: Any) {
        
        if processedVideoExist {
        
            if SessionCell.isConnected() {
                self.setupAvplayerViewController(videoURL: self.oprocessedVideoURL!)

            } else {
                let alert = self.internetConnectionAlert()
                self.parrentController?.present(alert, animated: true, completion: nil)
            }
        }

        
       
    }
    
    func checkIsProcessedVideoExistOnFirebase( succes:@escaping ()->Void, failured:@escaping ()-> Void) {
     let alert =  VideoUploader.sharedInstance.checkUploadedProcessedVideosFor(session: self.getSessionName) { [unowned self] (existedVideos, videoInfo) in
        print(existedVideos)
            if existedVideos.contains(self.getVideotype) {
               let dict = videoInfo[self.getVideotype]
                    if let urlString = dict["videoURL"] {
                        if let url = URL.init(string: urlString as! String) {
                            self.oprocessedVideoURL = url
                            self.processedVideoExist = true
                            if let imageURL = dict["imageURL"] as? String{
                                if let url = URL.init(string: imageURL ) {
                                 self.setupProcessImages(url: url, type: self.getVideotype)
                                }
                            }
                            succes()
                        }
                        
                    }
                //failured()
                self.processedIndicator.stopAnimating()
                self.signForProcessedVide.isHidden = false
                
            } else
             {
                failured()
                self.processedIndicator.stopAnimating()
                self.signForProcessedVide.isHidden = false
             }
        }
        
        
        if alert != nil {
            self.parrentController?.present(alert!, animated: true, completion: nil)
        }
    }
    
    
 
  
    
    func setupAvplayerViewController(videoURL: URL) {
    
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
        playerViewController.player = player
        self.parrentController?.present(playerViewController, animated: true, completion: {
            playerViewController.player!.play()
        })
    }
}






extension SessionCell {
    
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
