//
//  UserModel.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 05.04.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit

class UserModel: NSObject {
    
    static var currentUser = UserModel()
    
    var name: String = ""
    var dateOfBirth: String = ""
    var city: String = ""
    var favoriteSubject: String = ""
    var email: String = ""
    var password: String = ""
    var country: String = ""
    var image: UIImage?
    var userID: String = ""
    var uploadID: String = ""
    
}



