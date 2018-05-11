//
//  CropViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 04.04.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit

class CropViewController: UIViewController {
    
    @IBOutlet weak var msCropView: MSCropView!
    
    @IBOutlet weak var topView: UIView!
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if let imageData = UserDefaults.standard.value(forKey: "capturedImage") as? Data {
            let image = UIImage.init(data: imageData)
            msCropView.setup(image: image!)
        }
        
        msCropView.imageView.bringSubview(toFront: topView)
        self.msCropView.bringSubview(toFront: topView)
        setupCropButton()
    }
    
    func setupCropButton(){
        let cropButton = UIButton.init(frame: CGRect.init(x: self.view.frame.size.width - 100,
                                                          y: self.view.frame.size.height - 80,
                                                           width: 80, height: 40))
        cropButton.setTitle("Crop", for: .normal)
        cropButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        cropButton.setTitleColor(UIColor.init(red: 255, green: 149, blue: 0), for: .normal)
        cropButton.addTarget(self, action: #selector(cropAction), for: .touchUpInside)
        msCropView.imageView.addSubview(cropButton)
    }
    
    
  @objc  func cropAction(){
    
    self.msCropView.cropImage()
   
    self.performSegue(withIdentifier: "showVC", sender: nil)
        
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
