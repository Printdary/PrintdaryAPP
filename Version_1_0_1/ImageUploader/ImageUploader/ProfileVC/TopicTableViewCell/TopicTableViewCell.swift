//
//  TopicTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 23.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import AKPickerView
import Firebase

class TopicTableViewCell: UITableViewCell, AKPickerViewDelegate, AKPickerViewDataSource {
   
    
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var viewForPicker: UIView!
    @IBOutlet weak var menuHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var picker: AKPickerView!
    var rootViewController : ProfileViewController?
    var topicsArray = [TopickModel]()
    var picker1 : AKPickerView?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        menuHeightConstraint.constant = 0
       // self.picker?.delegate = self
       // self.picker?.dataSource = self
        self.picker?.pickerViewStyle = .style3D
        self.picker?.interitemSpacing = 80
        self.picker?.fisheyeFactor = 0.001
        
        addPicker()
        
       
        
        
    }
    
    func addNotificationObservers(){
    NotificationCenter.default.addObserver(self, selector: #selector(reloadTopics(info:)), name: Notification.Name.init("RELOAD_TOPICS"), object: nil)
    
    
    NotificationCenter.default.addObserver(self, selector: #selector(handleBlurTopics(info:)), name: Notification.Name.init("BLUR_TOPICS"), object: nil)
    }
    
    
    func unwatchFrameChanges(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init("RELOAD_TOPICS"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init("BLUR_TOPICS"), object: nil)
    }
    
    
    @objc func handleBlurTopics(info: Notification){
         NotificationCenter.default.post(name: Notification.Name.init("ADD_BLUR"), object: nil, userInfo: ["area": self.frame])
    }
    
    
    func addPicker() {
        if  (self.picker1 != nil) {
             self.picker1?.removeFromSuperview()
        }
        self.picker1 = AKPickerView.init(frame: self.picker.frame)
        
        self.picker1?.delegate = self
        self.picker1?.dataSource = self
        self.picker1?.pickerViewStyle = .style3D
        self.picker1?.interitemSpacing = 80
        self.picker1?.fisheyeFactor = 0.001
        self.picker.addSubview(self.picker1!)
        self.picker1?.translatesAutoresizingMaskIntoConstraints = false
        
         let top = NSLayoutConstraint.init(item: self.picker1!, attribute: .top, relatedBy: .equal, toItem: self.picker, attribute: .top, multiplier: 1, constant: 0)
         let bottom = NSLayoutConstraint.init(item: self.picker1!, attribute: .bottom, relatedBy: .equal, toItem: self.picker, attribute: .bottom, multiplier: 1, constant: 0)
         let left = NSLayoutConstraint.init(item: self.picker1!, attribute: .trailing , relatedBy: .equal, toItem: self.picker, attribute: .trailing, multiplier: 1, constant: 0)
         let right = NSLayoutConstraint.init(item: self.picker1!, attribute: .leading , relatedBy: .equal, toItem: self.picker, attribute: .leading, multiplier: 1, constant: 0)
        picker.addConstraint(top)
        picker.addConstraint(bottom)
        picker.addConstraint(left)
        picker.addConstraint(right)
        
        top.isActive = true
        bottom.isActive = true
        left.isActive = true
        right.isActive = true

        
        
    }
    
    @objc func reloadTopics(info: Notification){
        DispatchQueue.global(qos: .background).async {
      
        Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Topics").observeSingleEvent(of:.value) { (snapshot) in
            if snapshot.childrenCount == 0 {
                let ref =  Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Topics").childByAutoId()
                
                let interval = Date.timeIntervalSinceReferenceDate
                ref.updateChildValues(["createdDate" : interval, "topicID" : ref.key, "name" : "Topic 1"])
                
                
                PathModel.shared.selectedTopic = ref.key
                let ref1 = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Chapters").childByAutoId()
                ref1.updateChildValues(["createdDate" : interval, "chapterID" : ref1.key, "name": "Chapter 1"
                    , "topicID": PathModel.shared.selectedTopic!]) { (error,ref ) in
                    NotificationCenter.default.post(name: Notification.Name.init("RELOAD_TOPICS"), object: nil, userInfo: nil)
                }
                
            }else {
                
                if let object = snapshot.value as? [String : AnyObject] {
                    print(object.keys)
                    self.topicsArray.removeAll()
                    for key in object.keys {
                        if let value = object[key] as? [String : AnyObject] {
                            print(value)
                            let topickModel = TopickModel()
                            topickModel.topickID    = value["topicID"] as? String
                            topickModel.createdDate = value["createdDate"] as? Double
                            topickModel.name = value["name"] as? String
                            self.topicsArray.append(topickModel)
                            print("---------- \(self.topicsArray.count)----------------")
                        }
                        
                    }
                   self.topicsArray.sort(by: {$0.createdDate! < $1.createdDate!})
                    DispatchQueue.main.async {
                        self.addPicker()
                        self.picker1?.reloadData()
                        if self.topicsArray.indices.contains(0) {
                            self.picker1?.selectItem(0, animated: false)
                        }
                    }
                    
//                    Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { (timer) in
//                        if self.topicsArray.indices.contains(0) {
//                        NotificationCenter.default.post(name: Notification.Name.init("DID_SELECT_TOPIC"), object: nil, userInfo: ["topic" : self.topicsArray[Int.init(bitPattern:self.picker.selectedItem)].topickID!])
//                        }
//                    }
                  
                }
            }
        }
        
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func viewsButtonAction(_ sender: UIButton) {
    }
    @IBAction func renameButtonAction(_ sender: UIButton) {
        moreButtonActio(moreButton)
        let renameAlertView = Bundle.main.loadNibNamed("ChangeChapterNameAlert", owner: ChangeChapterNameAlert(), options: nil)?.first as! ChangeChapterNameAlert
        renameAlertView.frame = CGRect.init(x: 62, y: 100, width: 280, height: 250)
        renameAlertView.titleLabel.text = "Change topic name"
        renameAlertView.tag = 1
        self.rootViewController?.view.addSubview(renameAlertView)
    }
    
    @IBAction func moreButtonActio(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            sender.setImage(UIImage.init(named: "other"), for: .normal)
            UIView.animate(withDuration: 1.0) {
                self.menuHeightConstraint.constant = 190
            }
            NotificationCenter.default.post(name: Notification.Name.init("ADD_BLUR"), object: nil, userInfo: ["area": self.frame])
            return
        }
        sender.setImage(UIImage.init(named: "circle"), for: .normal)
        UIView.animate(withDuration: 1.0) {
              self.menuHeightConstraint.constant = 0
        }
       NotificationCenter.default.post(name: Notification.Name.init("REMOVE_BLUR"), object: nil, userInfo: nil)
        sender.tag = 0
    }
    
    
    @IBAction func delateButtonAction(_ sender: UIButton) {
        
        let topicModel  = topicsArray[Int.init(bitPattern: (picker1?.selectedItem)!)]
        moreButton.tag = 1
        moreButtonActio(moreButton)
        let deleateAlertView = Bundle.main.loadNibNamed("DeleteTopicAlertVIew", owner: DeleteTopicAlertVIew(), options: nil)?.first as! DeleteTopicAlertVIew
        deleateAlertView.frame = CGRect.init(x: 62, y: 100, width: 280, height: 450)
        if topicModel.name != nil {
           deleateAlertView.setAlertTest(text:topicModel.name!)
        }
        self.rootViewController?.view.addSubview(deleateAlertView)
    }
    

    
    func numberOfItems(in pickerView: AKPickerView!) -> UInt {
        return UInt(topicsArray.count)
    }
    
    func pickerView(_ pickerView: AKPickerView!, imageForItem item: Int) -> UIImage! {
        

        return UIImage.init(named: "topick")?.imageWithSize(CGSize.init(width: 42, height: 42))
    }
    
    func pickerView(_ pickerView: AKPickerView!, didSelectItem item: Int) {
        
        PathModel.shared.selectedTopic = topicsArray[item].topickID
        if let val = UserDefaults.standard.value(forKey: "Move") as? String{
            UserDefaults.standard.set(nil, forKey: "Move")
            moveChapter(topicId:  PathModel.shared.selectedTopic!, chapterName: val)
            NotificationCenter.default.post(name: Notification.Name.init("REMOVE_BLUR"), object: nil, userInfo: nil)
            return
        }
       
        NotificationCenter.default.post(name: Notification.Name.init("DID_SELECT_TOPIC"), object: nil, userInfo: ["topic" : topicsArray[item].topickID!])
        
    }
    
    
    
    func pickerView(_ pickerView: AKPickerView!, titleForItem item: Int) -> String! {
       
        if !topicsArray.indices.contains(item) {
            return ""
        }
       
        return  topicsArray[item].name
    }
    
    
    func moveChapter(topicId: String, chapterName: String){
        Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Chapters").child(PathModel.shared.selectedChapter!).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject]{
                if let topic = dict["topicID"] as? String {
                    if topic == topicId {
                        Helper.showAlertWith(title: "", alertMessage: "Chapter already is in this topic")
                    } else {
                        
                        Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Chapters").queryOrdered(byChild: "topicID")
                            .queryStarting(atValue: topicId)
                            .queryEnding(atValue: topicId + "\u{00B0}").observeSingleEvent(of: .value, with: { (snapshot) in
                                if let val = snapshot.value as? [String : AnyObject] {
                                    for key in val.keys {
                                        if let dict = val[key] as? [String : AnyObject] {
                                            if let name = dict["name"] as? String {
                                                if name == chapterName {
                                                    Helper.showAlertWith(title: "Info", alertMessage: "Chapter with the same name already exists")
                                                    return
                                                }
                                                else {
                                                    
                                                    Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Chapters").child(PathModel.shared.selectedChapter!).updateChildValues(["topicID": topicId]) { (error, ref) in
                                                        if error != nil{
                                                            Helper.showAlertWith(title: "Error", alertMessage: "Move failed")
                                                            return
                                                        }
                                                        Helper.showAlertWith(title: "Success", alertMessage: "Move succeed")
                                                        NotificationCenter.default.post(name: Notification.Name.init("DID_SELECT_TOPIC"), object: nil, userInfo: ["topic" : topicId])
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                              
                                
                            })
                        
                        
                    }
                }
            }
        }
        
    }
    
    
}


extension UIImage {
    func imageWithSize (_ size: CGSize)->UIImage {
        var sceledImageRect = CGRect.zero
        let  aspectWidth:CGFloat = size.width/self.size.width
        let  aspectHeight:CGFloat = size.height/self.size.height
        let aspectRatio: CGFloat = min(aspectWidth, aspectHeight)
        
        sceledImageRect.size.width = self.size.width * aspectRatio
        sceledImageRect.size.height = self.size.height * aspectRatio
        sceledImageRect.origin.x = (size.width - sceledImageRect.size.width) / 2.0
        sceledImageRect.origin.y = (size.height - sceledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: sceledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
        
        
}
}


class TopickModel : NSObject {
    var topickID: String?
    var createdDate: Double?
     var name: String?
}
