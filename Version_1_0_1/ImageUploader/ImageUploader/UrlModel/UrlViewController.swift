//
//  UrlViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 17.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import  WebKit

class UrlViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func plusButtonAction(_ sender: UIButton) {
        if let text = urlTextField.text as? String {
            if text != "" {
                if let url = URL.init(string: text) as? URL {
                 let urlObj = UrlObject()
                 urlObj.url = url
                 CurrentSession.currentSession.urlArray.append(urlObj)
                 urlTextField.text = ""
                }
            }
        }
       
    }
   
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refrefPageAction(_ sender: UIButton) {
        if let text = urlTextField.text as? String {
            if let url = URL.init(string: text) {
                webView.load(URLRequest(url: url))
            }
        }
        
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
