//
//  ViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 15.03.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import FCAlertView



class UserSelectionViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var userType2Button: UIButton!
    @IBOutlet weak var userType1Button: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var segmentView: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textFieldTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tagLabel: UILabel!
    var user2VC: HomeViewController?
    var timer:Timer?
    var actInd: UIActivityIndicatorView?
    let lowerPriority = DispatchQueue.global(qos: .utility)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
        self.textField.layer.borderWidth = 2
        self.textField.layer.borderColor = UIColor.black.cgColor
        self.textField.isHidden = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.isHidden = true
        uploadButton.layer.cornerRadius = 5
        uploadButton.layer.borderWidth = 2
        uploadButton.layer.borderColor = UIColor.black.cgColor
        uploadButton.isHidden = true
        tagLabel.isHidden = true
        
        userType1Button.layer.cornerRadius = 5
        userType1Button.layer.borderWidth = 2
        userType1Button.layer.borderColor = UIColor.black.cgColor
        
        userType2Button.layer.cornerRadius = 5
        userType2Button.layer.borderWidth = 2
        userType2Button.layer.borderColor = UIColor.black.cgColor
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        segmentView.selectedSegmentIndex = 1
        self.textField.text = ""
        self.timer = nil
        UploadHelper.sharidInstanc.uploadTask = nil
        UploadHelper.sharidInstanc.isUploading = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func user1ButtonAction(_ sender: UIButton) {
        
         self.performSegue(withIdentifier: "cameraVC", sender: nil)
    }
    @IBAction func user2ButtonPressed(_ sender: UIButton) {
         self.performSegue(withIdentifier: "showUser2Camera", sender: nil)
    }
    
    @IBAction func segmentChangeAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.performSegue(withIdentifier: "showPhotoVC", sender: nil)
            return
        }
       
        
    }
    @IBAction func uploadButtonAction(_ sender: UIButton) {
       // self.perform(#selector(showUploadAlert), with: nil, afterDelay: 1)
        if self.imageView.image != nil {
            self.showActivityIndicatory(uiView: self.view)
            UploadHelper.sharidInstanc.uploadStringToServer(string: self.textField.text!, image: self.imageView.image!, block: { (status) in
                self.actInd?.stopAnimating()
                if status {
                    self.showAlertWith(title: "Upload Success", alertMessage: "")
                } else {
                    self.showAlertWith(title: "Upload Failed", alertMessage: "")
                }
                
            })
        }
    }
    
    
    
    func showActivityIndicatory(uiView: UIView) {
        actInd = UIActivityIndicatorView()
        actInd?.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
        actInd?.center = self.view.center
        actInd?.hidesWhenStopped = true
        actInd?.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        self.view.addSubview(actInd!)
        actInd?.startAnimating()
    }
    
    
   @objc func showUploadAlert(){
    
       self.performSegue(withIdentifier: "showResponsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cameraVC" {
            let vc = segue.destination as! CameraVC
            vc.handleDidTackenPhoto = { image, data in
                print()
                ResivedModel.sharedInstance().uploadedImage = image
                DispatchQueue.main.async {
                    self.imageView.image = image
                    self.imageView.isHidden = false
                    self.tagLabel.isHidden = false
                    self.textField.isHidden = false
                    self.uploadButton.isHidden = false
                    
                }
            }
        }
        
        if segue.identifier == "showUser2Camera" {
            
            DispatchQueue.main.async {
                self.imageView.image = nil
                self.imageView.isHidden = true
                self.tagLabel.isHidden = true
                self.textField.isHidden = true
                self.uploadButton.isHidden = true
                
            }
            self.user2VC = segue.destination as? HomeViewController
            self.user2VC?.imageCapturedBlock = { capturedImage in

                UploadHelper.sharidInstanc.uploadImageToServer(image: capturedImage!, queue: self.lowerPriority)
                
            }
            
            UploadHelper.sharidInstanc.imageFound = { image, tag, isFound in
                UploadHelper.sharidInstanc.imageFound = nil
                DispatchQueue.main.async {
                   // self.timer?.invalidate()
                    UploadHelper.sharidInstanc.uploadTask = nil
                    self.user2VC?.stopUploading()
                    self.user2VC?.imageSuccesFuluCaptured("Success")
                }
                ResivedModel.sharedInstance().resivedImage = image
                ResivedModel.sharedInstance().resivedObject = tag
                ResivedModel.sharedInstance().uploadedImage = self.imageView.image
                self.perform(#selector(self.showUploadAlert), with: nil, afterDelay: 1)
            }
            
            
            UploadHelper.sharidInstanc.imageNotFound = {
                UploadHelper.sharidInstanc.imageFound = nil
                UploadHelper.sharidInstanc.detectionCount = 0;
                DispatchQueue.main.async {
                    UploadHelper.sharidInstanc.uploadTask = nil
                   // self.timer?.invalidate()
                    self.user2VC?.stopUploading()
                    self.perform(#selector(self.showImageNotDetectedAlert), with: nil, afterDelay: 1)
                    
                }
            }
        }
    }
    
    
    @objc func showImageNotDetectedAlert() {
        self.user2VC?.imageNotDetected("")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textFieldTopConstraint.constant = 10
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldTopConstraint.constant = -70
    }
    
    
    func showAlertWith(title: String, alertMessage: String){
        let alert = FCAlertView.init()
        alert.showAlert(withTitle: title,
                        withSubtitle: alertMessage,
                        withCustomImage: UIImage.init(named: "checkbox"),
                        withDoneButtonTitle: "OK",
                        andButtons: nil)
    }
}

