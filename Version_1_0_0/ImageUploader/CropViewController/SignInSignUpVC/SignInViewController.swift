//
//  SignInViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 04.04.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import AVFoundation


class SignInViewController: UIViewController,UITextFieldDelegate{
    
    
    var session: AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
  
    
    @IBOutlet weak var fon: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordFextField: UITextField!
    var email: String {
        if ((emailTextField?.text) != nil) {
          return  (emailTextField?.text)!
        }
        return ""
    }
    
    var password: String {
        if ((passwordFextField?.text) != nil) {
            return  (passwordFextField?.text)!
        }
        return ""
    }
    
    override func viewDidLoad() {
        self.configTextFields()
       
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        session = AVCaptureSession()
        let camera = getDevice(position: .back)
        do {
            input = try AVCaptureDeviceInput(device: camera!)
            if(session?.canAddInput(input!) == true){
                
                //Add the input to the session
                
                session?.addInput(input!)
            }
            output?.outputSettings = [AVVideoCodecKey : AVVideoCodecType.jpeg]
            previewLayer = AVCaptureVideoPreviewLayer(session: session!)
            
            //            if(session?.canAddOutput(output!) == true){
            //                session?.addOutput(output!)
            //            }
            previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            previewLayer?.frame = self.fon.frame
            self.view.layer.addSublayer(previewLayer!)
            session?.startRunning()
            // self.view.addSubview(fon)
            for subview in self.view.subviews {
                self.view.bringSubview(toFront: subview)
            }
            
        } catch let error as NSError {
            print(error)
            input = nil
        }
        
    }

    
    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devices() as NSArray;
        for de in devices {
            let deviceConverted = de as! AVCaptureDevice
            if(deviceConverted.position == position){
                return deviceConverted
            }
        }
        return nil
    }
    
    func configTextFields(){
        emailTextField.delegate = self
        passwordFextField.delegate = self
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                               attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(red: 55, green: 161, blue: 252)])
        passwordFextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                  attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(red: 55, green: 161, blue: 252)])
    }
    
    
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        
        if self.checkTextFields(){
           Helper.showAlertWith(title: "Error", alertMessage: "All fields are required")
           return
        }
        
        let activIndi = UIActivityIndicatorView()
        activIndi.activityIndicatorViewStyle = .gray
        DispatchQueue.main.async {
            self.view.addSubview(activIndi)
            activIndi.center = self.view.center
            activIndi.startAnimating()
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            if err != nil {
                Helper.showAlertWith(title: "Error", alertMessage: (err?.localizedDescription)!)
                activIndi.removeFromSuperview()
            }
            activIndi.removeFromSuperview()
            self.performSegue(withIdentifier: "showPhotoVC", sender: nil)
        }
    }
    
    @IBAction func forgotBasswordButtonAction(_ sender: UIButton) {
    }
    
    @IBAction func signUpButtonAction(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "signUP")
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func continueAsGuestButtonAction(_ sender: UIButton) {
    }
    
    
    func checkTextFields()->Bool{
        if emailTextField.text == "" || passwordFextField.text == "" {
            
            return true
        }
        return false
        
    }
    
    
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
  }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
    }
}
