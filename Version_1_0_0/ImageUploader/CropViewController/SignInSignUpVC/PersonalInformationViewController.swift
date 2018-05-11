//
//  PersonalInformationViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 04.04.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import AVFoundation



class PersonalInformationViewController: UIViewController,UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var favoritSubjectTextField: UITextField!
    
    @IBOutlet weak var dateOfBirthConstraint: NSLayoutConstraint!
    @IBOutlet weak var countryConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var subjectTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var cityTexfFieldConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var fon: UIImageView!
    var countries: [String] = []
    let thePicker = UIPickerView()
    
    
    var session: AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        dateOfBirthTextField.delegate = self
        countryTextField.delegate = self
        cityTextField.delegate = self
        favoritSubjectTextField.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(PersonalInformationViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(PersonalInformationViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
       
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
    
    @IBAction func createAccountButtonAction(_ sender: UIButton) {
        if self.checkTextFields() {
            Helper.showAlertWith(title: "Error", alertMessage: "All fields are required")
            return
        }
        self.registerNewUser()
    }
    
    func checkTextFields()->Bool{
        if dateOfBirthTextField.text! == "" || countryTextField.text! == "" || cityTextField.text! == "" || favoritSubjectTextField.text! == ""{
            
            return true
        }
        return false
        
    }
    
    
    @IBAction func dateOfBirthAction(_ sender: UITextField) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker ), for: UIControlEvents.valueChanged)
    }
  
    
    
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateOfBirthTextField.text = dateFormatter.string(from: sender.date)
        dateOfBirthTextField.resignFirstResponder()
    }
    
    
    @IBAction func countresAction(_ sender: UITextField) {
        
        sender.inputView = thePicker
        self.getCountres()
       
    }
    
    
    func getCountres(){
        
        
        for code in NSLocale.isoCountryCodes as [String] {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countries.append(name)
        }
          thePicker.delegate = self
          thePicker.dataSource = self
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryTextField.text = countries[row]
        countryTextField.resignFirstResponder()
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        UIView.animate(withDuration: 0.3) {
            if self.cityTextField.isEditing {
                self.cityTexfFieldConstraint.constant = -150;
                self.dateOfBirthConstraint.constant = -150
                self.countryConstraint.constant = -150
            }
            if self.favoritSubjectTextField.isEditing {
                self.cityTexfFieldConstraint.constant = -150;
                self.dateOfBirthConstraint.constant = -150
                self.countryConstraint.constant = -150
                self.subjectTextFieldConstraint.constant = -150;
            }
        }
        self.view.layoutIfNeeded();
        
        print(keyboardHeight);
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        UIView.animate(withDuration: 0.3) {
            
            self.cityTexfFieldConstraint.constant = 0
            self.backgroundBottomConstraint.constant = 0
            self.dateOfBirthConstraint.constant = 0
            self.countryConstraint.constant = 0
            self.subjectTextFieldConstraint.constant = 0
        }
        
        self.view.layoutIfNeeded();
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
   func registerNewUser(){
    
    let userModel = UserModel.currentUser
    userModel.dateOfBirth = dateOfBirthTextField.text!
    userModel.city = cityTextField.text!
    userModel.favoriteSubject = favoritSubjectTextField.text!
    userModel.country = countryTextField.text!
    let activIndi = UIActivityIndicatorView()
    activIndi.activityIndicatorViewStyle = .gray
    DispatchQueue.main.async {
        self.view.addSubview(activIndi)
        activIndi.center = self.view.center
        activIndi.startAnimating()
    }
    
         Auth.auth().createUser(withEmail: userModel.email, password: userModel.password) { (user, err) in
            if err != nil {
                Helper.showAlertWith(title: "Error", alertMessage: (err?.localizedDescription)!)
                activIndi.removeFromSuperview()
                return
            }
            activIndi.removeFromSuperview()
            if let uid = user?.uid {
               userModel.userID = uid
               self.saveUserToFirebase()
            }
            
        }
    
    }
    
    
    func saveUserToFirebase() {
        let user = UserModel.currentUser
        let accountDataRef = Database.database().reference().child("User").child(user.userID)
        
        
        var accountDict = [String: String]()
        accountDict.updateValue(user.userID, forKey: "userID")
        accountDict.updateValue(user.email, forKey: "userEmailAddress")
        accountDict.updateValue(user.name, forKey: "Name")
        accountDict.updateValue(user.dateOfBirth, forKey: "dateOfBirth")
        accountDict.updateValue(user.country, forKey: "country")
        accountDict.updateValue(user.city, forKey: "city")
        accountDict.updateValue(user.favoriteSubject, forKey: "favoriteSubject")
        accountDict.updateValue(user.favoriteSubject, forKey: "favoriteSubject")

        //Put users info into FirebaseDatabase accountData path
        let activIndi = UIActivityIndicatorView()
        activIndi.activityIndicatorViewStyle = .gray
        DispatchQueue.main.async {
           
            self.view.addSubview(activIndi)
            activIndi.center = self.view.center
            activIndi.startAnimating()
        }
        
        accountDataRef.updateChildValues(accountDict){
            (error, ref) in
            
            if error != nil{
                print("\n>>>CreateAccountVC -func accountDataRef() -\(String(describing: error?.localizedDescription))\n")
                activIndi.stopAnimating()
                activIndi.removeFromSuperview()
                Helper.showAlertWith(title: "Error", alertMessage: (error?.localizedDescription)!)
                return
            }
            
            //self.sendDataToMultipleFirebaseDatabaseNodes(userID: setUser.uid)
            let storageRef = Storage.storage().reference().child("image/user.png")
            if let userImage = user.image {
                if let uploadData = UIImagePNGRepresentation(userImage) {
                    storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                        if error != nil {
                            activIndi.removeFromSuperview()
                            Helper.showAlertWith(title: "Error", alertMessage: (error?.localizedDescription)!)
                            return
                            
                        } else {
                            // your uploaded photo url.
                            var accountDict = [String: Any]()
                            accountDict.updateValue((metadata?.downloadURL()?.absoluteString)!, forKey: "imageURL")
                            accountDataRef.updateChildValues(accountDict){
                                (error, ref) in
                                
                                if error != nil{
                                    Helper.showAlertWith(title: "Error", alertMessage: (error?.localizedDescription)!)
                                    activIndi.removeFromSuperview()
                                    return
                                } else {
                                    activIndi.removeFromSuperview()
                                    self.performSegue(withIdentifier: "showPhotoVC2", sender: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
            
            
            
        
        
    
    
}
