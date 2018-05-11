//
//  LoginViewController.swift
//  VideoCapture
//
//  Created by Armen Nikodhosyan on 03.08.17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import RSLoadingView


class LoginViewController: UIViewController , UITextFieldDelegate{
    
    @IBOutlet  var signUpButtonConstrain: NSLayoutConstraint!
    @IBOutlet  var signInButtonConstrain: NSLayoutConstraint!
    @IBOutlet  var signUpImageView: UIImageView!
    @IBOutlet  var signInImageView: UIImageView!
    @IBOutlet  var userNameTextField: TJTextField!
    @IBOutlet  var passwordTextField: TJTextField!
    @IBOutlet  var confirmPasswordTextField: TJTextField!
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    @IBOutlet weak var signInButtonOutlet: UIButton!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet  var signInButton: UIButton!
    @IBOutlet  var signUpButton: UIButton!
    @IBOutlet  var userNameConstrain: NSLayoutConstraint!
    @IBOutlet  var passwordConstrain: NSLayoutConstraint!
    @IBOutlet  var confirmPasswordConstrain: NSLayoutConstraint!
    @IBOutlet  var backgroundConstrain: NSLayoutConstraint!
    
    var newConstUserName : NSLayoutConstraint?
    var newConstPassword : NSLayoutConstraint?
    var newConstSignIn : NSLayoutConstraint?
    var newConstSignUp : NSLayoutConstraint?
    var newConstSignInButton : NSLayoutConstraint?
    var newConstSignUpButton : NSLayoutConstraint?
    var newConstConfirmPassword : NSLayoutConstraint?
    var newConstBackground: NSLayoutConstraint?
    @IBOutlet  var signUpConstrain: NSLayoutConstraint!
    @IBOutlet  var signInConstrain: NSLayoutConstraint!

    var isSignUpTapped: Bool = false
    var isKeyboardOpen : Bool = false
    
    var isLogIn: Bool = true
    
    
    override func viewDidLoad() {
        
       self.userNameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        self.confirmPasswordTextField.isHidden = true
        self.signInButtonOutlet.setBackgroundImage(UIImage.init(named: "signInIcon"), for: .normal)
        self.signUpButtonOutlet.setBackgroundImage(UIImage.init(named: "signUpIcon"), for: .normal)
        
        userNameTextField.layer.cornerRadius = 10.0
        passwordTextField.layer.cornerRadius = 10.0
        confirmPasswordTextField.layer.cornerRadius = 10.0
        
        self.newConstUserName = NSLayoutConstraint.init(item: self.userNameTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.21, constant: 0)
        self.newConstPassword = NSLayoutConstraint.init(item: self.passwordTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.42, constant: 0)

        self.userNameConstrain.isActive = false
        self.passwordConstrain.isActive = false
        self.newConstUserName?.isActive = true
        self.newConstPassword?.isActive = true
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    @objc func keyboardWillAppear() {
        
        if !self.isKeyboardOpen {
            
        self.isKeyboardOpen = true
            if isLogIn == true {
                self.newConstUserName = NSLayoutConstraint.init(item: self.userNameTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.51, constant: 0)
                self.newConstPassword = NSLayoutConstraint.init(item: self.passwordTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.72, constant: 0)
            } else {
                self.newConstUserName = NSLayoutConstraint.init(item: self.userNameTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.3, constant: 0)
                self.newConstPassword = NSLayoutConstraint.init(item: self.passwordTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.51, constant: 0)
            }
        self.newConstConfirmPassword = NSLayoutConstraint.init(item: self.confirmPasswordTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.72, constant: 0)
        self.newConstBackground = NSLayoutConstraint.init(item: self.backgroundImage, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.3, constant: 0)
        self.newConstSignIn = NSLayoutConstraint.init(item: self.signInImageView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.98, constant: 0)
        self.newConstSignUp = NSLayoutConstraint.init(item: self.signUpImageView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.15, constant: 0)
         self.newConstSignUpButton = NSLayoutConstraint.init(item: self.signUpButton, attribute: .centerY, relatedBy: .equal, toItem: self.signUpImageView, attribute: .centerY, multiplier: 1, constant: 0)
         self.newConstSignInButton = NSLayoutConstraint.init(item: self.signInButton, attribute: .centerY, relatedBy: .equal, toItem: self.signInImageView, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.userNameConstrain.isActive = false//false
        self.passwordConstrain.isActive = false
        self.confirmPasswordConstrain?.isActive = false
        self.backgroundConstrain?.isActive = false
        self.signInConstrain.isActive = false
        self.signUpConstrain.isActive = false
        self.signInButtonConstrain.isActive = false
        self.signUpButtonConstrain.isActive = false
        self.newConstUserName?.isActive = true//true
        self.newConstPassword?.isActive = true
        self.newConstConfirmPassword?.isActive = true
        self.newConstBackground?.isActive = true
        self.newConstSignIn?.isActive = true
        self.newConstSignUp?.isActive = true
        self.newConstSignInButton?.isActive = true
        self.newConstSignUpButton?.isActive = true
        }
    }
    
    @objc func keyboardWillDisappear() {

        
        if self.isKeyboardOpen {
        self.isKeyboardOpen = false
        self.newConstUserName?.isActive = false//false
        self.newConstPassword?.isActive = false
        self.newConstConfirmPassword?.isActive = false
        self.newConstBackground?.isActive = false
        self.newConstSignIn?.isActive = false
        self.newConstSignUp?.isActive = false
        self.newConstSignInButton?.isActive = false
        self.newConstSignUpButton?.isActive = false
        self.userNameConstrain.isActive = true//true
        self.passwordConstrain.isActive = true
        self.confirmPasswordConstrain?.isActive = true
        self.backgroundConstrain?.isActive = true
        self.signInConstrain.isActive = true
        self.signUpConstrain.isActive = true
        self.signInButtonConstrain.isActive = true
        self.signUpButtonConstrain.isActive = true
            
            
            if isLogIn == true {
                self.newConstUserName = NSLayoutConstraint.init(item: self.userNameTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.21, constant: 0)
                self.newConstPassword = NSLayoutConstraint.init(item: self.passwordTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.42, constant: 0)
                
                self.userNameConstrain.isActive = false//true
                self.passwordConstrain.isActive = false
                self.newConstUserName?.isActive = true//false
                self.newConstPassword?.isActive = true
            } 
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func signInAction(_ sender: UIButton) {
        
        if isLogIn == true {
            
            
            do{
                let rech = try Reachability.init()
                if (rech?.isConnectedToNetwork)!{
                    print("Internet Connection Available!")
                    
                    self.userNameTextField.resignFirstResponder()
                    self.passwordTextField.resignFirstResponder()
                    self.confirmPasswordTextField.resignFirstResponder()
                    let loadingView =  RSLoadingView()
                    loadingView.show(on:self.view)
                    
                    guard let email = self.userNameTextField.text, let password = self.passwordTextField.text else {
                        print("Form is not valid")
                        let alert = Alerts.sharedInstance.callToAlert(title: "Info", message: "Form is not valid.")
                        self.present(alert, animated: true, completion: nil)
                        loadingView.hide()
                        return
                    }
                    
                    Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                        if error != nil {
                            print("error = \(error.debugDescription)")
                            let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "Wrong Email or Password.")
                            self.present(alert, animated: true, completion: nil)
                            loadingView.hide()
                            return
                        }
                        loadingView.hide()
                        //successfully logged in our user
                        loadingView.show(on:self.view)
                        self.dismiss(animated: true, completion: nil)
                    }

                }else{
                    let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "You do not have internet access.")
                    self.present(alert, animated: true, completion: nil)
                    print("Internet Connection not Available!")
                }
                
            }catch{
                print("ERROR")
            }


        }else {
            
            
            do{
                let rech = try Reachability.init()
                if (rech?.isConnectedToNetwork)!{
                    print("Internet Connection Available!")
                    
                    self.userNameTextField.resignFirstResponder()
                    self.passwordTextField.resignFirstResponder()
                    self.confirmPasswordTextField.resignFirstResponder()
                    let loadingView =  RSLoadingView()
                    loadingView.show(on:self.view)
                    
                    guard let email = self.userNameTextField.text, let password = passwordTextField.text else {
                        
                        print("Form is not valid")
                        let alert = Alerts.sharedInstance.callToAlert(title: "Info", message: "Form is not valid.")
                        self.present(alert, animated: true, completion: nil)
                        loadingView.hide()
                        return
                    }
                    if password != self.confirmPasswordTextField.text {
                        let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "Passwords are not matched.")
                        self.present(alert, animated: true, completion: nil)
                        loadingView.hide()
                        return
                    }
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user: User?, error) in
                        if error != nil {
                            print("error = \((error?.localizedDescription)!)")
                            
                            let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "\((error?.localizedDescription)!).")
                            self.present(alert, animated: true, completion: nil)
                            loadingView.hide()
                            return
                        }
                        //print("user = \(user)")
                        
                        guard let uid = user?.uid else {
                            loadingView.hide()
                            
                            return
                        }
                        
                        //Successfuly authenticated user
                        let ref = Database.database().reference(fromURL: "https://zofie-15b4f.firebaseio.com/")
                        let userReference = ref.child("users").child(uid)
                        let values = ["email" : email]
                        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                            if err != nil {
                                print("err = \(err.debugDescription)")
                                loadingView.hide()
                                
                                return
                            }
                            //self.dismiss(animated: true, completion: nil)
                            loadingView.hide()
                            
                            let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                            let sessionController = storyboard.instantiateViewController(withIdentifier: "navVC")
                            let appObj = UIApplication.shared.delegate as! AppDelegate
                            appObj.window?.rootViewController =  sessionController
                            print("Saved user successfully into Firebase db")
                        })
                    })
                }else{
                    let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "You do not have internet access.")
                    self.present(alert, animated: true, completion: nil)
                    print("Internet Connection not Available!")
                }
                
            }catch{
                print("ERROR")
            }
        }

    }
    
    
    @IBAction func signUpAction(_ sender: UIButton) {
        
        if isSignUpTapped == false {
            isSignUpTapped = true
        } else {
            isSignUpTapped = false
        }
        
        
        
        self.userNameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        
        
        if isSignUpTapped == true {
            self.userNameTextField.text = ""
            self.passwordTextField.text = ""
            self.confirmPasswordTextField.text = ""
            
            self.newConstUserName = NSLayoutConstraint.init(item: self.userNameTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0)
            self.newConstPassword = NSLayoutConstraint.init(item: self.passwordTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.21, constant: 0)
            
            self.userNameConstrain.isActive = true
            self.passwordConstrain.isActive = false
            self.newConstUserName?.isActive = false
            self.newConstPassword?.isActive = true
            
            self.confirmPasswordTextField.isHidden = false
            isLogIn = false
            self.signInButtonOutlet.setBackgroundImage(UIImage.init(named: "signUpIconBig"), for: .normal)
            self.signUpButtonOutlet.setBackgroundImage(UIImage.init(named: "signingInSmall"), for: .normal)
        }else {
            self.confirmPasswordTextField.isHidden = true
            self.newConstUserName = NSLayoutConstraint.init(item: self.userNameTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.21, constant: 0)
            self.newConstPassword = NSLayoutConstraint.init(item: self.passwordTextField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.42, constant: 0)
            
            self.userNameConstrain.isActive = false
            self.passwordConstrain.isActive = false
            self.newConstUserName?.isActive = true
            self.newConstPassword?.isActive = true
            
            self.userNameTextField.text = ""
            self.passwordTextField.text = ""
            self.confirmPasswordTextField.text = ""
            isLogIn = true
            self.signInButtonOutlet.setBackgroundImage(UIImage.init(named: "signInIcon"), for: .normal)
            self.signUpButtonOutlet.setBackgroundImage(UIImage.init(named: "signUpIcon"), for: .normal)
        }
    }
    
    
    
    // TextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(self.userNameTextField)
        self.userNameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.confirmPasswordTextField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
