//
//  UrlView.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 17.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit

class UrlView: UIView, UITextFieldDelegate {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var eImageView: UIImageView!
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var urlLabel: UILabel!
    var urlObj : UrlObject?
    override func awakeFromNib() {
        mView.layer.borderWidth = 1
        mView.layer.borderColor = UIColor.white.cgColor
        mView.layer.cornerRadius = 5
        urlTextField.delegate = self
    }

    @IBAction func delateButtonAction(_ sender: UIButton) {
        self.removeFromSuperview()
            NotificationCenter.default.post(name: Notification.Name.init("URLVIEWDELETED"),
                                            object: nil,
                                            userInfo: ["urlObj" : urlObj])
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.text != ""{
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.post(name: Notification.Name.init("TextFieldDidBeginEditing"),
                                        object: nil,
                                        userInfo: nil)
    }
    
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text != "" {
            urlObj?.url = URL.init(string: "https://\(textField.text!)")
        }
        return true
    }
    
    
}
