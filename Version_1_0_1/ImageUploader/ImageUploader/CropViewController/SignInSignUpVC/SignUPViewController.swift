//
//  SignUPViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 04.04.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import AVFoundation

class SignUPViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextFieldDelegate  {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    let imagePicker = UIImagePickerController()
   
    @IBOutlet weak var passwordTextFieldConstrain: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomBtnNext: NSLayoutConstraint!
    @IBOutlet weak var nameConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailConstraint: NSLayoutConstraint!
    @IBOutlet weak var fon: UIImageView!
    
    
    var session: AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    
    
    override func viewDidLoad() {
        passwordTextField.delegate = self
        nameTextField.delegate = self
        emailTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        
          AppUtility.lockOrientation(.portrait)
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(SignUPViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(SignUPViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
      
    }
    
    
  override  func viewWillAppear(_ animated: Bool) {
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
    
    @IBAction func backButtonAction(_ sender: UIButton) {
       self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadImageButtonAction(_ sender: UIButton) {
        self.getUserImage()
    }
    @IBAction func checkboxButtonAction(_ sender: UIButton) {
        if checkboxImageView.image == nil {
            checkboxImageView.image = UIImage.init(named: "CheckedBox")
            return
        }
        checkboxImageView.image = nil
    }
    @IBAction func continueButtonAction(_ sender: UIButton) {
        if self.checkTextFields() {
           Helper.showAlertWith(title: "Error", alertMessage: "All fields are required")
            return
        }
        if passwordTextField.text != confirmPasswordTextField.text {
             Helper.showAlertWith(title: "Error", alertMessage: "Password does not match the confirm password")
            return
        }
        if checkboxImageView.image == nil {
             Helper.showAlertWith(title: "Error", alertMessage: "You must agree to the terms and conditions before register.")
            return
        }
        self.createNewUser()
    }
    
    
    func createNewUser(){
        let user = UserModel.currentUser
        user.name = nameTextField.text!
        user.email = emailTextField.text!
        user.password = passwordTextField.text!
        user.image = userImageView.image
        self.performSegue(withIdentifier: "showPIVC", sender: nil)
    }
    
   
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        UIView.animate(withDuration: 0.3) {
            if self.confirmPasswordTextField.isEditing {
               self.passwordTextFieldConstrain.constant = -150
               self.constraintBottomBtnNext.constant = -150;
               self.nameConstraint.constant = -150
               self.emailConstraint.constant = -150
                
            }
            if self.passwordTextField.isEditing {
               self.passwordTextFieldConstrain.constant = -150;
               self.nameConstraint.constant = -150
               self.emailConstraint.constant = -150
            }
        }
        self.view.layoutIfNeeded();
        
        print(keyboardHeight);
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        UIView.animate(withDuration: 0.3) {
            
            self.constraintBottomBtnNext.constant = 0;
            self.passwordTextFieldConstrain.constant = 0
            self.nameConstraint.constant = 0
            self.emailConstraint.constant = 0
        }
        
        self.view.layoutIfNeeded();
    }
    
    
    
    func checkTextFields()->Bool{
        if confirmPasswordTextField.text! == "" || passwordTextField.text! == "" || emailTextField.text! == "" || nameTextField.text! == ""{
            
            return true
        }
        return false
        
    }
    
    func getUserImage() {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum;
            self.imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userImageView.contentMode = .scaleAspectFit
            userImageView.layer.masksToBounds = true
            userImageView.image = pickedImage
            self.dismiss(animated: true, completion: { () -> Void in
                
            })
        }

    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
   
}


