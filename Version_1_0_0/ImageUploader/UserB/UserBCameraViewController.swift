//
//  UserBCameraViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 05.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit

class UserBCameraViewController: UIViewController {
    
    var camerViewController: HomeViewController?
    var shouldPresent = true
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(changPresentationStatus), name: Notification.Name.init("SHOULDPRESENT"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSwipe), name: Notification.Name.init("DID_SWIPE"), object: nil)
        camerViewController = HomeViewController.init()
        UploadHelper.sharidInstanc.uploadTask = nil
        UploadHelper.sharidInstanc.isUploading = false
        self.shouldPresent = true
        
        self.camerViewController?.imageCapturedBlock = { capturedImage in
            UploadHelper.sharidInstanc.uploadImageToServer(image: capturedImage!, queue: DispatchQueue.global())
        }
        
        
        UploadHelper.sharidInstanc.imageFound = { [unowned self] image, tag, isFound in
            UploadHelper.sharidInstanc.imageFound = nil
            DispatchQueue.main.async { [unowned self] in
                UploadHelper.sharidInstanc.uploadTask = nil
                self.camerViewController?.stopUploading()
               // self.camerViewController?.imageSuccesFuluCaptured("Success")
            }

        }
        
        
        UploadHelper.sharidInstanc.imageNotFound = {
            self.stopUploadingImages()
            self.perform(#selector(self.showImageNotDetectedAlert), with: nil, afterDelay: 1)
        }
        
        
        self.camerViewController?.handleUserButtonPressed = { [unowned self] in
            self.shouldPresent = false
            self.camerViewController?.stopUploading()
            self.camerViewController?.dismiss(animated: false, completion: {
                print("self.camerViewController = \(self.camerViewController)")
                let notesVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "notesViewController")
                self.present(notesVC, animated: true, completion: nil)
            })
        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopUploadingImages()
    }
    
    func stopUploadingImages(){
        UploadHelper.sharidInstanc.imageFound = nil
        UploadHelper.sharidInstanc.detectionCount = 0;
        DispatchQueue.main.async {  [unowned self] in
            UploadHelper.sharidInstanc.uploadTask = nil
            self.camerViewController?.stopUploading()
        }
    }
    
    
    @objc func changPresentationStatus (){
        self.shouldPresent = true
    }
    
   @objc func imageDetected(){
        self.camerViewController?.imageCapturedBlock = nil
        let pinImageView = UIImageView.init(frame: CGRect.init(x: 40, y: 50, width: self.view.frame.size.width/3, height: self.view.frame.size.height / 5))
        let userButton = UIButton.init(frame: CGRect.init(x: 20, y: 0, width: pinImageView.frame.size.height / 2, height: pinImageView.frame.size.height / 2))
        pinImageView.image = UIImage.init(named: "Marker")
        userButton.setImage(UIImage.init(named: "administrator-male"), for: .normal)
       self.camerViewController?.setupPin(pinImageView, button: userButton)
    }
    
    @objc func userButtonClicked(){
        print("userButtonClicked")
    }
    
    @objc func didSwipe(){
       self.camerViewController?.stopUploading()
       self.camerViewController?.dismiss(animated: false, completion: {
         print("self.camerViewController = \(self.camerViewController)")
       })
         print("self.camerView = \(self.camerViewController)")
       self.shouldPresent = false
     
       self.performSegue(withIdentifier: "createUnitVC", sender: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if shouldPresent {
            self.present(camerViewController!, animated: false, completion: { [unowned self] in
                
        })
            
        }
        
        self.perform(#selector(imageDetected), with: nil, afterDelay: 5)
    }
    
    
    @objc func showImageNotDetectedAlert() {
        self.camerViewController?.imageNotDetected("")
    }
}
