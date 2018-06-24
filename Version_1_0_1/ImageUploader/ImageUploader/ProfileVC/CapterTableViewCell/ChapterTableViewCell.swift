//
//  ChapterTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 23.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import AKPickerView
import  Firebase
import DropDown

class ChapterTableViewCell: UITableViewCell, AKPickerViewDelegate, AKPickerViewDataSource {

    @IBOutlet weak var picker: AKPickerView!
    @IBOutlet weak var menuHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var createdDateLabel: UILabel!
    
    var chaptersArray = [ChapterModel]()
    var rootViewController: ProfileViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .none
        menuHeightConstraint.constant = 0
        self.picker?.delegate = self
        self.picker?.dataSource = self
        self.picker?.pickerViewStyle = .style3D
        self.picker?.interitemSpacing = 80
        self.picker?.fisheyeFactor = 0.001
        
        
        
        
        
        
    }
    
    
    func addNotificationObservers(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleSelectTopic(info:)), name: Notification.Name.init("DID_SELECT_TOPIC"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(handleSelectTopic(info:)), name: Notification.Name.init("RELOAD_CHAPTERS"), object: nil)
    }
    
    
    func unwatchFrameChanges(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init("DID_SELECT_TOPIC"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init("RELOAD_CHAPTERS"), object: nil)
    }
    
   

    
    
    @objc func handleSelectTopic(info: Notification){
       DispatchQueue.global(qos: .background).async {
            
        
        if let info = info.userInfo as? [String: Any]{
            if let obj = info["topic"] as? String {
                let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Chapters").queryOrdered(byChild: "topicID").queryStarting(atValue: obj).queryEnding(atValue: obj + "\u{00B0}")
                    ref.observeSingleEvent(of:.value) { (snapshot) in
                        print(snapshot)
                        if let object = snapshot.value as? [String : AnyObject] {
                            print(object.keys)
                            self.chaptersArray.removeAll()
                            for key in object.keys {
                                if let value = object[key] as? [String : AnyObject] {
                                    print(value)
                                    let chapterModel = ChapterModel()
                                    chapterModel.chapterID    = value["chapterID"] as? String
                                    chapterModel.createdDate = value["createdDate"] as? Double
                                    chapterModel.name = value["name"] as? String
                                    self.chaptersArray.append(chapterModel)
                                    
                                }
                                
                            }
                            PathModel.shared.existingChapters = self.chaptersArray
                            self.chaptersArray.sort(by: {$0.createdDate! < $1.createdDate!})
                            PathModel.shared.selectedChapter = self.chaptersArray[0].chapterID
                            self.perform(#selector(self.reloadPicker), with: nil, afterDelay: 0.5)
                         //   Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
                                if self.chaptersArray.count > 0 {
                                    self.picker.selectItem(0, animated: false)
                                }
                                let val =  Int.init(bitPattern: self.picker.selectedItem)
                              
                           // }
                        }else {
                             let interval = Date.timeIntervalSinceReferenceDate
                            let ref1 = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Chapters").childByAutoId()
                            ref1.updateChildValues(["createdDate" : interval, "chapterID" : ref1.key, "name": "Chapter 1"
                                ,"topicID": PathModel.shared.selectedTopic!]) { (error,ref ) in
                                 NotificationCenter.default.post(name: Notification.Name.init("RELOAD_CHAPTERS"), object: nil, userInfo: ["topic" : PathModel.shared.selectedTopic!])
                            }
                            
                          
                           
                            NotificationCenter.default.post(name: Notification.Name.init("DID_SELECT_CHAPTER"), object: nil, userInfo: ["chapter" : "NON"])
                            
                        }
                    
                }
            }
    }
        }
}
    
    @objc func reloadPicker(){
        DispatchQueue.main.async {
            self.picker.reloadData()
        }
        
    }
        
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func moreButtonActio(_ sender: UIButton) {
        if chaptersArray.count != 0 {
        if sender.tag == 0 {
            sender.tag = 1
            let val =  Int.init(bitPattern: self.picker.selectedItem)
            self.configurCreatedDate(chapter: self.chaptersArray[val])
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
}
    
    func configurCreatedDate(chapter: ChapterModel){
        let date = Date.init(timeIntervalSinceReferenceDate: TimeInterval.init(chapter.createdDate!))
        let forrmater = DateFormatter()
        forrmater.dateStyle = .medium
        let strDate = forrmater.string(from: date)
        self.createdDateLabel.text = strDate
    }
    
    func numberOfItems(in pickerView: AKPickerView!) -> UInt {
        return UInt(chaptersArray.count)
    }
    
    func pickerView(_ pickerView: AKPickerView!, imageForItem item: Int) -> UIImage! {
        print(pickerView.selectedItem)
        
        return UIImage.init(named: "SelectedChapter")?.imageWithSize(CGSize.init(width: 35, height: 35))
    }
    
    func pickerView(_ pickerView: AKPickerView!, didSelectItem item: Int) {
        PathModel.shared.selectedChapter = chaptersArray[item].chapterID
        NotificationCenter.default.post(name: Notification.Name.init("DID_SELECT_CHAPTER"), object: nil, userInfo: ["chapter" : chaptersArray[item].chapterID!])
        
    }
    func pickerView(_ pickerView: AKPickerView!, titleForItem item: Int) -> String! {
        if !chaptersArray.indices.contains(item){
            return ""
        }
        return chaptersArray[item].name
    }
    
    
    @IBAction func renameChapterButtonAction(_ sender: UIButton) {
         moreButtonActio(moreButton)
        let renameAlertView = Bundle.main.loadNibNamed("ChangeChapterNameAlert", owner: ChangeChapterNameAlert(), options: nil)?.first as! ChangeChapterNameAlert
        renameAlertView.frame = CGRect.init(x: 62, y: 100, width: 280, height: 250)
        renameAlertView.titleLabel.text = "Change chapter name"
        renameAlertView.tag = 0
        self.rootViewController?.view.addSubview(renameAlertView)
    }
    
    @IBAction func delateChupterButtonAction(_ sender: UIButton) {
        
         let chapterModel  = chaptersArray[Int.init(bitPattern: picker.selectedItem)]
         moreButton.tag = 1
         moreButtonActio(moreButton)
         let deleateAlertView = Bundle.main.loadNibNamed("DeleteChapterAlertView", owner: DeleteChapterAlertView(), options: nil)?.first as! DeleteChapterAlertView
        deleateAlertView.frame = CGRect.init(x: 62, y: 100, width: 280, height: 450)
        deleateAlertView.setAlertTest(text:chapterModel.name!)
        self.rootViewController?.view.addSubview(deleateAlertView)

    }
    
    @IBAction func moveButtonAction(_ sender: UIButton) {
        let chapterModel  = chaptersArray[Int.init(bitPattern: picker.selectedItem)]
        let name = chapterModel.name
         UserDefaults.standard.set(name, forKey: "Move")
         self.moreButtonActio(moreButton)
         NotificationCenter.default.post(name: Notification.Name.init("BLUR_TOPICS"), object: nil, userInfo: nil)
    }
    
    
}
    
    


class ChapterModel : NSObject {
    var chapterID: String?
    var createdDate: Double?
    var name: String?
}
