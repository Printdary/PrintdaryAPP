//
//  UploadHelper.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 17.03.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit
//old 172.83.9.243:6969

//http://172.31.14.231:6969/addImageIntoTrainData/
class UploadHelper: NSObject {
    
    static let sharidInstanc = UploadHelper()
    var imageFound:((_ image: UIImage?, _ tag: String, _ isFound: Bool)-> Void)?
    var uploadTask: URLSessionDataTask?
    var isImageFound = false
    var detectionCount = 0
    var imageNotFound:(()->())?
    let lowerPriority = DispatchQueue.global(qos: .userInitiated)
    var isUploading = false
    
    
    func uploadImageToServer(image:UIImage, queue: DispatchQueue){
        self.lowerPriority.async {
        if !self.isUploading {
        self.isUploading = true
        let imageData = UIImagePNGRepresentation(image)
        let request = NSMutableURLRequest(url: (NSURL(string: "http://ec2-18-220-100-17.us-east-2.compute.amazonaws.com:6969/queryImageFromTrainData/") as URL?)!)
        request.timeoutInterval = 90
        request.httpMethod = "POST"
        request.httpBody = imageData 
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        //request.addValue("application/json", forHTTPHeaderField: "Accept")
        //request.setValue("close", forHTTPHeaderField: "Connection")
        let session = URLSession.init(configuration: .default, delegate: nil, delegateQueue: .main)
        
        self.uploadTask = session.dataTask(with: request  as URLRequest) { (data, request, error) in
            if (error != nil) {
                print(error?.localizedDescription)
                 self.isUploading = false
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                let tag = json["tag"]
                DispatchQueue.main.async {
                    self.uploadTask?.cancel()
                }
                
                self.imageFound?(nil, tag as! String, true)
//                if let imageData = json["imageBase64"] as? String{
//              //  let dataDecoded : Data = Data.init(base64Encoded: imageData)!
//              //  let image = UIImage.init(data: dataDecoded )
//                  
//                } else {
//                    if self.detectionCount < 10 {
//                        self.detectionCount =  self.detectionCount  + 1
//                        self.isUploading = false
//                    }
//                    else {
//                        DispatchQueue.main.async {
//                            self.uploadTask?.cancel()
//                        }
//                        self.imageNotFound?()
//                    }
//                }
                
            } catch let error as NSError {
                 print(error)
                 self.isUploading = false
            }

        }
        
        
        
        
        
        self.uploadTask?.resume()
        }
    }
}
    
    func uploadStringToServer(string: String, image:UIImage, block:@escaping (_ status: Bool)->Void){
        
        let imageData = UIImagePNGRepresentation(image)
       // let request = NSMutableURLRequest(url: (NSURL(string: "http://172.31.14.231:6969/addImageIntoTrainData/\(string)") as URL?)!)
        let request = NSMutableURLRequest(url: (NSURL(string: "http://ec2-18-220-100-17.us-east-2.compute.amazonaws.com:6969/addImageIntoTrainData/\(string)") as URL?)!)
        request.httpMethod = "POST"
        request.httpBody = imageData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("close", forHTTPHeaderField: "Connection")
        let session = URLSession.init(configuration: .default, delegate: nil, delegateQueue: .main)
        
        let task = session.dataTask(with: request  as URLRequest) { (data, request, error) in
            if (error != nil) {
                print(error?.localizedDescription)
                block(false)
                return
            }
            block(true)
            let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("strData = \(strData ?? "" )")
        }
        
        
        
        
        
        task.resume()
    }
    
}
