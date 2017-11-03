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
    var overlayTextureImage: UIImage?
    
    @IBOutlet weak var cropImageView: UIImageView!
    let overlayView = UIView(frame: UIScreen.main.bounds)
    let imageView = UIImageView(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: UIScreen.main.bounds.size.width / 4, height: UIScreen.main.bounds.size.height / 4)))
    let textureImageView = UIImageView(frame: UIScreen.main.bounds)
   
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
        
        if AppManager.shared.isSelected_B() {
            
            overlayView.isHidden = false
            textureImageView.isHidden = false
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.showTexture))
            overlayView.addGestureRecognizer(tapGesture)
        }
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
        overlayView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.2)
        imageView.center = overlayView.center
        imageView.image = #imageLiteral(resourceName: "icn_image")
        imageView.contentMode = .scaleAspectFit
        overlayView.addSubview(imageView)
        self.view.insertSubview(overlayView, aboveSubview: cropImageView)
        self.view.insertSubview(textureImageView, aboveSubview: overlayView)
        
        overlayView.isHidden = true
        textureImageView.isHidden = true
        textureImageView.contentMode = .scaleAspectFit
        
        hud?.textLabel.text = "Loading"
    }
    
    @objc func showTexture() {
        if AppManager.shared.isSelected_B() {
            
            let baseURL = "http://ec2-18-220-220-31.us-east-2.compute.amazonaws.com/testing/testuploads/"
            
            var ciImg = croppedImage!.ciImage
            if(ciImg == nil){
                // this should never be needed but if for some reason both formats fail, we create a CIImage
                // change UIImage to CIImage
                ciImg = CIImage(image: croppedImage!)
            }
            
            hud?.show(in: self.view, animated: true)
            ImageRecognitionManager.shared.detectScene(image: ciImg!) { (result, error) in
                if error != nil {
                    print("Error - result")
                } else {
                    print(result)
                    
                    let textureURL = "\(baseURL)\(result)/texture.jpg"
                    if let url = URL(string: textureURL) {
                        self.textureImageView.sd_setImage(with: url, completed: { (image, error, type, url) in
                            self.hud?.dismiss()
                        })
                        self.textureImageView.isHidden = false
                    }
                }
            }
        }
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
