//
//  ProfileViewController.swift
//  VideoCapture
//
//  Created by Armen Nikodhosyan on 08.11.17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ProfileViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, HADropDownDelegate{
   
    
    
    
    @IBOutlet weak var inchesOrMetresView: HADropDown!
    @IBOutlet weak var kgOrMetresMiew: HADropDown!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    let datePickerView:UIDatePicker = UIDatePicker()
    var array = ["Male", "Female"]
    var typePickerView: UIPickerView = UIPickerView()
    
    override func viewDidLoad() {
        genderTextField.delegate = self
        heightTextField.delegate = self
        dobTextField.delegate = self
        weightTextField.delegate = self
        
        
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.showDatePicker()
        self.showPickerView()
        self.setupTextFields(textField: weightTextField)
        self.setupTextFields(textField: heightTextField)
        self.typePickerView.dataSource = self
        self.typePickerView.delegate = self
        inchesOrMetresView.items = ["Meters","Inches"]
        kgOrMetresMiew.items     = ["Kg","Pounds"]
        inchesOrMetresView.delegate = self
        kgOrMetresMiew.delegate = self
    }
    @IBAction func nextButtonAction(_ sender: UIButton) {
        let rech = try! Reachability.init()
         if (rech?.isConnectedToNetwork)!{
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference(fromURL: "https://zofie-15b4f.firebaseio.com/")
        let userReference = ref.child("users").child(uid!)
        var heigth  = "\(self.heightTextField.text ?? "N/A") \(inchesOrMetresView.title)"
        var weight  = "\(self.weightTextField.text ?? "N/A") \(kgOrMetresMiew.title)"
        var gender  = "\(self.genderTextField.text ?? "N/A")"
        var dob     = "\(self.dobTextField.text ?? "N/A")"
        if let title = self.heightTextField.text {
            if title == "" {
                heigth = "N/A"
            }
        }
        if let title = self.weightTextField.text {
            if title == "" {
                weight = "N/A"
            }
        }
        if let title = self.genderTextField.text {
            if title == "" {
                gender = "N/A"
            }
        }
        if let title = self.dobTextField.text {
            if title == "" {
                dob = "N/A"
            }
        }
       
            
        let values = ["Gender" : gender,
                      "Heigth" : heigth,
                         "DOB" : dob,
                      "Weight" : weight]
            
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print("err = \(err.debugDescription)")
                let alert = Alerts.sharedInstance.callToAlert(title: "Info", message: "\(err.debugDescription)")
                self.present(alert, animated: true, completion: nil)
                return
            }
        })
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let LEFSDataCallculationVC = storyboard.instantiateViewController(withIdentifier: "LEFSDataCallculationVC")
        let appObj = UIApplication.shared.delegate as! AppDelegate
         appObj.window?.rootViewController =  LEFSDataCallculationVC
         }else {
            let alert = Alerts.sharedInstance.callToAlert(title: "Info", message: "Internet Connection is required")
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
   
    
    func showDatePicker() {
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        // add toolbar to textField
        dobTextField.inputAccessoryView = toolbar
        datePickerView.datePickerMode = UIDatePickerMode.date
        dobTextField.inputView = datePickerView
        
    }
    
    func showPickerView() {
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([spaceButton,cancelButton], animated: false)
        // add toolbar to textField
        genderTextField.inputAccessoryView = toolbar
        genderTextField.inputView = typePickerView
    }
    
    func setupTextFields(textField: UITextField) {
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTextField))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
       
        toolbar.setItems([spaceButton,doneButton], animated: false)
        // add toolbar to textField
        textField.inputAccessoryView = toolbar
    }
    
    @objc func doneTextField() {
       self.view.endEditing(true)
    }
  
    
    @objc func donedatePicker(){
        //For date formate
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        dobTextField.text = formatter.string(from: datePickerView.date)
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        //cancel button dismiss datepicker dialog
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
   
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         return array[row] as String
    }
   
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         genderTextField.text = array[row]
         self.view.endEditing(true)
    }
  
    
    func didSelectItem(dropDown: HADropDown, at index: Int){
        
    }
    func didShow(dropDown: HADropDown){
        
    }
    func didHide(dropDown: HADropDown){
        
    }
    
}
