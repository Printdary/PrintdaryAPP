//
//  CacheHelper.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 20.06.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit

class CacheHelper: NSObject {
    
    let cache = NSCache<NSString, UIImage>()
 static var sharid = CacheHelper()
    
    func setObjectFor(key: String, object: UIImage){
        self.cache.setObject(object , forKey: key as NSString)
    }
    
    
    func getObjectForKey(key: String)-> UIImage? {
        return self.cache.object(forKey: key as NSString)
    }
}
