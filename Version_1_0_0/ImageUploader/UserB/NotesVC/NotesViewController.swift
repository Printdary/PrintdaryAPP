//
//  NotesViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 05.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NotesViewController: UIViewController {
    
    @IBOutlet weak var menuCentralButton: UIButton!
    @IBOutlet weak var centralButtonRoundView: UIView!
    @IBOutlet weak var viewsView: UIView!
    @IBOutlet weak var manuView: UIView!
    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var introductionView : UIView!
    @IBOutlet weak var circleImageView: UIImageView!
    
    
    @IBOutlet weak var modelSegmentImageView: UIImageView!
    var imprintImage: UIImageView?
    var modelName: String?
    
    override func viewDidLoad() {
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.layer.masksToBounds = true
        
        introductionView.layer.borderWidth = 2
        introductionView.layer.borderColor = UIColor.init(red: 85, green: 203, blue: 255).cgColor
        introductionView.layer.cornerRadius = 10
        notesView.layer.cornerRadius = 10
        notesView.layer.borderWidth = 2
        notesView.layer.borderColor = UIColor.init(red: 85, green: 203, blue: 255).cgColor
        
        emailView.layer.cornerRadius = 10
        emailView.layer.borderWidth = 2
        emailView.layer.borderColor = UIColor.init(red: 85, green: 203, blue: 255).cgColor
        dayView.layer.cornerRadius = 10
        dayView.layer.borderWidth = 2
        dayView.layer.borderColor = UIColor.init(red: 85, green: 203, blue: 255).cgColor
        viewsView.layer.cornerRadius = 10
        viewsView.layer.borderWidth = 2
        viewsView.layer.borderColor = UIColor.init(red: 85, green: 203, blue: 255).cgColor
        manuView.layer.cornerRadius = manuView.frame.size.width / 2
        manuView.layer.borderWidth = 4
        manuView.layer.borderColor = UIColor.init(red: 86, green: 106, blue: 119).cgColor
        manuView.clipsToBounds = true
        centralButtonRoundView.layer.cornerRadius = centralButtonRoundView.frame.size.width / 2
        centralButtonRoundView.layer.borderWidth = 2
        centralButtonRoundView.layer.borderColor = UIColor.init(red: 86, green: 106, blue: 119).cgColor
        menuCentralButton.layer.cornerRadius = menuCentralButton.frame.size.width / 2
        circleImageView.layer.cornerRadius = circleImageView.frame.size.width / 2
        circleImageView.layer.borderWidth = 2
        circleImageView.layer.borderColor = UIColor.red.cgColor
        circleImageView.layer.masksToBounds = true
        circleImageView.isHidden = true
        circleImageView.backgroundColor = UIColor.white
        
        self.modelSegmentImageView.isHidden = true
        
        getModel(modelID: "-LBuBKJgxV7rvgv01gWC")
        
    }
    @IBAction func videoButtonAction(_ sender: UIButton) {
    }
    @IBAction func modelButtonAction(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            self.modelSegmentImageView.isHidden = false
             circleImageView.isHidden = false
            return
        }
         self.modelSegmentImageView.isHidden = true
         circleImageView.isHidden = true
        sender.tag = 0
    }
    @IBAction func closeButtonAction(_ sender: UIButton) {
         NotificationCenter.default.post(Notification.init(name: Notification.Name.init("SHOULDPRESENT"), object: nil, userInfo: nil))
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func urlButtonPressed(_ sender: UIButton) {
    }
    @IBAction func audioButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func imageButtonPressed(_ sender: UIButton) {
       
       
        if sender.tag == 0 {
            sender.tag = 1
            circleImageView.isHidden = false
            emailView.isHidden = true
            dayView.isHidden = true
            viewsView.isHidden = true
            self.view.backgroundColor = UIColor.init(red: 0, green: 166, blue: 255, alpha: 0.51)
            self.view.backgroundColor = UIColor.hexStringToUIColor(hex: "#00A6FF")
            imprintImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height / 2.6))
            imprintImage?.backgroundColor = UIColor.white
            self.view.addSubview(imprintImage!)
            return
        }
        sender.tag = 0
        circleImageView.isHidden = true
        emailView.isHidden = false
        dayView.isHidden = false
        viewsView.isHidden = false
        self.view.backgroundColor = UIColor.white
        imprintImage?.removeFromSuperview()
    }
    @IBAction func selectObjectButtonAction(_ sender: UIButton) {
        if !modelSegmentImageView.isHidden &&  modelSegmentImageView.image != nil {
            
            let activityIndicatior = UIActivityIndicatorView.init(frame: CGRect.init(x: (self.view.frame.size.width / 2) - 25, y: (self.view.frame.size.height / 2) - 25, width: 50, height: 50))
            
            activityIndicatior.activityIndicatorViewStyle = .whiteLarge
            activityIndicatior.center = self.view.center
             self.view.addSubview(activityIndicatior)
             activityIndicatior.startAnimating()
            DispatchQueue.global().async {
                if let model = UserDefaults.standard.value(forKey: "modelName") as? String{
                    self.downloadMTLObjectsFrom(url: "http://ec2-18-188-59-112.us-east-2.compute.amazonaws.com/models/\(model)/\(model).mtl")
                }
            }
            
        }
    }
    
    
    
    func getModel(modelID: String){
        Database.database().reference().child("ModelURL").child(modelID).observe(.value) { (snapshot) in
            print(snapshot.value ?? "")
            if let dict = snapshot.value as? NSDictionary{
                for (key, _ ) in dict {
                    let newDict = dict[key] as? [String: String]
                    let name = newDict!["dawnloadURL"]
                    self.modelName = name!
                    UserDefaults.standard.set(name, forKey: "modelName")
                    let name1 = name?.replacingOccurrences(of: " ", with: "_")
                    let urlStr = "http://ec2-18-188-59-112.us-east-2.compute.amazonaws.com/models/\(name1!)/\(name1!).jpg"
                    let url = URL.init(string: urlStr)
                    DispatchQueue.global().async {
                        do {
                            
                            if (url != nil) {
                                let data = try Data.init(contentsOf: url!)
                                let img = UIImage.init(data: data)
                                DispatchQueue.main.async {
                                    self.circleImageView.image = img
                                }
                            }
                            
                            
                        }catch let _{
                            print("load error")
                        }
                        
                    }
                    break
                }
                
            }
        }
    }
    
    
    
    func download3DObjectsFrom(url: String) {
        
        guard let url = URL(string: url) else { return }
        let urlData = NSData(contentsOf: url)
        if urlData != nil {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let filePath = "\(documentsPath)/objexample.obj"
            print("filePath = \(filePath)")
            urlData?.write(toFile: filePath, atomically: true)
            UserDefaults.standard.set(filePath, forKey: "filePath")
            
            //            ServerSideViewController.sharedInstance.objthreed(filePath: filePath)
            DispatchQueue.main.async {
                self.perform(#selector(self.moveNextVc), with: nil, afterDelay: 3)
            }
           
        }
    }
    
   @objc func moveNextVc(){
        self.performSegue(withIdentifier: "showModel", sender: nil)
    }
    
    func downloadMTLObjectsFrom(url: String) {
        
    
        
        guard let url = URL(string: url) else { return }
        let urlData = NSData(contentsOf: url)
        if urlData != nil {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let filePath = "\(documentsPath)/objexample.mtl"
            print("filePath = \(filePath)")
            urlData?.write(toFile: filePath, atomically: true)
            UserDefaults.standard.set(filePath, forKey: "filePathMtl")
            if let model = UserDefaults.standard.value(forKey: "modelName") as? String{
                self.download3DObjectsFrom(url: "http://ec2-18-188-59-112.us-east-2.compute.amazonaws.com/models/\(model)/\(model).obj")
            }

        }
    }
}

extension UIColor {
   class func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
    cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
    return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
    red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
    green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
    blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
    alpha: CGFloat(1.0)
    )
}
}



