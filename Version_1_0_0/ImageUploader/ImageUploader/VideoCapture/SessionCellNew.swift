//
//  SessionCellNew.swift
//  VideoCapture
//
//  Created by MacMini on 8/5/17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import UIKit

class SessionCellNew: UITableViewCell {
    
    var isCellSelected = false
    var appObj = UIApplication.shared.delegate as! AppDelegate
    var sessionName: String?
    @IBOutlet weak var cellTag: UIButton!
   
    @IBOutlet weak var labelForSessionName: UILabel!
    @IBOutlet weak var labelForDate: UILabel!
    
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var frontLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    @IBOutlet weak var leftImageViewIcon: UIImageView!
    @IBOutlet weak var frontImageViewIcon: UIImageView!
    @IBOutlet weak var rightImageViewIcon: UIImageView!
    
    @IBOutlet weak var bottomImageView: UIImageView!
    
    @IBOutlet weak var selectedCellImageView: UIImageView!
    
    var namePressed : ((_ name: String)-> Void)?
    
    @IBOutlet weak var thumbnailLeftImageView: UIImageView!
    @IBOutlet weak var thumbnailFrontImageView: UIImageView!
    @IBOutlet weak var thumbnailRightImageView: UIImageView!
    
    override func awakeFromNib() {
        selectedCellImageView.image = UIImage.init(named: "notselectedAbove")
        leftImageViewIcon.image = UIImage.init(named: "processedIcon")
        frontImageViewIcon.image = UIImage.init(named: "processedIcon")
        rightImageViewIcon.image = UIImage.init(named: "processedIcon")
        self.thumbnailLeftImageView.layer.cornerRadius = self.thumbnailLeftImageView.frame.size.width / 15.0
        self.thumbnailFrontImageView.layer.cornerRadius = self.thumbnailFrontImageView.frame.size.width / 15.0
        self.thumbnailRightImageView.layer.cornerRadius = self.thumbnailRightImageView.frame.size.width / 15.0
        
        
    }
 
    
    func setupCell( snapshot:[String : Any]) {
        
        
        if let name = snapshot["Session Name"] as? String {
            self.labelForSessionName.text = name
             sessionName = name
        }
        if let date = snapshot["Date"] as? String {
            self.labelForDate.text = date
        }
        if let obj = snapshot["0"] as? [String : Any] {
            if let imageURL = obj["imageURL"] as? String {
                if let image = appObj.videoThumbnail.object(forKey: "\(imageURL)0" as AnyObject) {
                    DispatchQueue.main.async {
                        self.thumbnailLeftImageView.image = (image as! UIImage)
                    }
                    
                }else {
                    setupImages(urlString: imageURL, type: 0)
                }
            }
           
        }
        if let obj = snapshot["1"] as? [String : Any] {
            if let imageURL = obj["imageURL"] as? String {
                if let image = appObj.videoThumbnail.object(forKey: "\(imageURL)1" as AnyObject) {
                     DispatchQueue.main.async {
                      self.thumbnailFrontImageView.image = (image as! UIImage)
                    }
                }else {
                     setupImages(urlString: imageURL, type: 1)
                }
            }
            
        }
        if let obj = snapshot["2"] as? [String : Any] {
            if let imageURL = obj["imageURL"] as? String {
                
                if let image = appObj.videoThumbnail.object(forKey: "\(imageURL)2" as AnyObject) {
                     DispatchQueue.main.async {
                      self.thumbnailRightImageView.image = (image as! UIImage)
                    }
                } else {
                    setupImages(urlString: imageURL, type: 2)
                }
            }
            
        }
        if sessionName != nil {
        if appObj.sessionsForDelate.contains(sessionName!) {
            selectedCellImageView.image = UIImage.init(named: "selectedAbove")
        } else {
            selectedCellImageView.image = UIImage.init(named: "notselectedAbove")
        }
        }
        
        
       
        
    }
    
    
    
    func setupImages(urlString: String, type: Int) {
        DispatchQueue.global().async {
            if let url = URL.init(string: urlString) {
            switch type {
            case 0:
                self.thumbnailLeftImageView.sd_setImage(with: url, completed: { (image, error, type, url) in
                    if image != nil {
                    self.appObj.videoThumbnail.setObject(image!, forKey: "\(url)0" as AnyObject)
                    }
                })
                
                break;
            case 1:
                self.thumbnailFrontImageView.sd_setImage(with: url, completed: { (image, error, type, url) in
                    if image != nil {
                    self.appObj.videoThumbnail.setObject(image!, forKey:   "\(url)1" as AnyObject)
                    }
                })
                break;
                
            case 2:
                self.thumbnailRightImageView.sd_setImage(with: url, completed: { (image, error, type, url) in
                    if image != nil {
                    self.appObj.videoThumbnail.setObject(image!, forKey:"\(url)2" as AnyObject)
                    }
                })
                break;
            default:
                break
                
                
            }

            }
            
            
        }
        
    }
    
    
    
    
    func getThumbnailPhoto(name: String, type: Int, complatition: @escaping ((UIImage?))-> Void) {
        let secondQueueName = "\(name)\(type)"
        let secondConcurrentQueue = DispatchQueue(label: secondQueueName, attributes: .concurrent)
        secondConcurrentQueue.sync {
        VideoDawnloader.sharedInstance.downloadVideoThumbnail(name: name, type: type, complatition: {(imgURL) in
            if imgURL != nil {
                    do {
                        let data = try Data.init(contentsOf: imgURL!)
                        let image = UIImage.init(data: data)
                        complatition(image)
                        
                    }
                    catch{
                        complatition(nil)
                    }
            }
        })
        }

    }
    
    
    
    
    @IBAction func selectCellAction(_ sender: Any) {
        let sessionName = self.labelForSessionName.text
        self.namePressed!(sessionName!)
        if !isCellSelected {
            isCellSelected = true
            selectedCellImageView.image = UIImage.init(named: "selectedAbove")
            appObj.sessionsForDelate.append(sessionName!)
        }else {
            isCellSelected = false
            selectedCellImageView.image = UIImage.init(named: "notselectedAbove")
            if let index = appObj.sessionsForDelate.index(of:sessionName!) {
                appObj.sessionsForDelate.remove(at: index)
            }
        }
        
    }
    
}
