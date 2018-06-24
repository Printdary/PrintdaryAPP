//
//  WebView.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 19.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit

class WebView: UIView, UITextFieldDelegate {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var webUrl: URL?
    @IBOutlet weak var mTextField: UITextField!
    @IBOutlet weak var mWebView: UIWebView!
    
    override func awakeFromNib() {
        mTextField.delegate = self
    }
    @IBAction func refreshAction(_ sender: UIButton) {
        if let url = URL.init(string: mTextField.text!) as? URL {
            webUrl = url
        if webUrl != nil { mWebView.loadRequest(URLRequest.init(url:webUrl!))
        }
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    func loadUrl(){
        mTextField.text = webUrl?.absoluteString
        if webUrl != nil { mWebView.loadRequest(URLRequest.init(url:webUrl!))
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
