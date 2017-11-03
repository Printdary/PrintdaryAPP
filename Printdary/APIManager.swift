//
//  APIManager.swift
//  ARKitExample
//
//  Created by Wang on 10/31/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation

final class APIManage {
    
    static let shared = APIManage()
    
    // Upload Image
    func upload(image: UIImage, imgName: String, type: AssetType, completion: @escaping (_ success: Bool, _ result: String) -> ()) {
        
        guard let url = URL(string: "http://ec2-18-220-220-31.us-east-2.compute.amazonaws.com/testing/service.php") else {
            completion(false, "Uploading failed.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        var assetType: String = ""
        switch type {
        case .image:
            assetType = "Image"
        case .texture:
            assetType = "Texture"
        }
        
        let param = [
            "image_name": imgName,
            "asset_type": assetType
        ]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.3) else {
            completion(false, "Failed to convert image data.")
            return
        }
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData, boundary: boundary)
        
        //        activityIndicator.startAnimating();
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                completion(false, error!.localizedDescription)
            }
            
            // You can print out response object
            print("******* response = \(response)")
            
            // Print out reponse body
            let responseString = String.init(data: data!, encoding: String.Encoding.utf8)
            print("****** response data = \(responseString!)")
            
            completion(true, "Uploading done")
        }
        
        task.resume()
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        var body = Data()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        
        let filename = parameters == nil ? "image.jpg" : "\(parameters!["image_name"]).jpg"
        let mimetype = "image/jpg"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageDataKey)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}
