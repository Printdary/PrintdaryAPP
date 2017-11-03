//
//  AssignViewController.swift
//  ARKitExample
//
//  Created by Wang on 10/31/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import JGProgressHUD

enum AssetType {
    case image
    case texture
}

class AssignViewController: UIViewController {

    var croppedImage: UIImage?
    var textureImage: UIImage?
    
    @IBOutlet weak var croppedImageView: UIImageView!
    @IBOutlet weak var textureImageView: UIImageView!
    
    @IBOutlet weak var buttonsView: UIView!
    
    let imagePickerController = UIImagePickerController()
    
    var hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        croppedImageView.image = croppedImage
        buttonsView.isHidden = false
        imagePickerController.delegate = self
        
        hud?.textLabel.text = "Uploading"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if textureImage != nil {
            buttonsView.isHidden = true
            textureImageView.image = self.textureImage
        } else {
            textureImageView.image = nil
        }
    }
    
    
    // MARK: Animations
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnTakePhotoClicked(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        }else{
            print("Camera not available")
        }
    }
    
    @IBAction func btnUploadPictureClicked(_ sender: UIButton) {
        
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func btnCheckClicked(_ sender: UIButton) {
        
        if textureImage == nil { return }
        
        var ciImg = croppedImage!.ciImage
        if(ciImg == nil){
            // this should never be needed but if for some reason both formats fail, we create a CIImage
            // change UIImage to CIImage
            ciImg = CIImage(image: croppedImage!)
        }
        
        ImageRecognitionManager.shared.detectScene(image: ciImg!) { (result, error) in
            if error != nil {
                print("Error - result")
            } else {
                print(result)
                
                let uploadImages: [UIImage] = [self.croppedImage!, self.textureImage!]
                let types: [AssetType] = [.image, .texture]
                var uploadRequiredNumber = uploadImages.count
                
                self.hud?.show(in: self.view, animated: true)
                self.showAlertWithSelection("Will you upload the recognized image?", message: "\(result) recognized.", ok: {
                    
                    for (i, image) in uploadImages.enumerated() {
                        
//                        let image = self.resizeImage(image: image, targetSize: CGSize.init(width: <#T##CGFloat#>, height: <#T##CGFloat#>))
                        APIManage.shared.upload(image: image, imgName: result, type: types[i], completion: { (success, result) in
                            if success {
                                print("Upload succeeded")
                                self.hud?.dismiss()
                                
                                uploadRequiredNumber -= 1
                                if uploadRequiredNumber == 0 {
                                    self.showAlert("Image uploading succeeded.", message: "", ok: {
                                        self.navigationController?.dismiss(animated: true, completion: {
                                            AppManager.shared.select_B()
                                        })
                                    })
                                }
                            } else {
                                print(result)
                                self.hud?.dismiss()
                                self.showAlert("Image uploading failed.", message: "")
                            }
                        })
                    }
                }, cancel: {
                    
                })
            }
        }
    }
}


// MARK: ImagePickerController Delegate

extension AssignViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if picker.sourceType == .photoLibrary {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.textureImage = pickedImage
            }
        } else if picker.sourceType == .camera {
            if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.textureImage = pickedImage
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
