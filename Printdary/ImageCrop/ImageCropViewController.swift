//
//  ImageCropViewController.swift
//  ARKitExample
//
//  Created by Wang on 10/31/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import SDWebImage
import JGProgressHUD

class ImageCropViewController: UIViewController {

    var snapshot: UIImage!
    var croppedImage: UIImage!
    
    @IBOutlet weak var cropImageView: UIImageView!
   
    var hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cropImageView.image = croppedImage
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoAssignVC" {
            
            if let assignVC = segue.destination as? AssignViewController {
                assignVC.croppedImage = self.croppedImage
            }
        }
    }
    
    
    // MARK: Animations
    
    @IBAction func btnCloseClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCropClicked(_ sender: UIButton) {
        
        // Overlay cleanup
        
        
        let cropVC = TOCropViewController(image: snapshot)
        cropVC.delegate = self
        self.present(cropVC, animated: true, completion: nil)
    }
    
    @IBAction func btnImageClicked(_ sender: UIButton) {
        
        if AppManager.shared.isSelected_A() {
            self.performSegue(withIdentifier: "gotoAssignVC", sender: nil)
        }
    }
    
    // MARK: Methods
    
    func setupUI() {
        
        croppedImage = snapshot
        
        hud?.textLabel.text = "Loading"
    }
}


// MARK: Crop Image
extension ImageCropViewController: TOCropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        
        self.croppedImage = image
        
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    
}
