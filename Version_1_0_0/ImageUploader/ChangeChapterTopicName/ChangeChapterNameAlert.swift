//
//  ChangeTopicName.swift
//  zya
//
//  Created by Shoghik Khachatryan on 28.05.2018.
//  Copyright © 2018 Shoghik Khachatryan. All rights reserved.
//

import UIKit
import Firebase

class ChangeChapterNameAlert: UIView, UITextFieldDelegate {

   
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cencel: UIButton!
    
    @IBAction func doneButton(_ sender: UIButton) {
        if nameTextField.text != "" {
        updateName(name: nameTextField.text!)
        self.removeFromSuperview()
        }
    }
   
  
    @IBAction func cancelButton(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    
    
    func updateName(name: String){
        let indikator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        indikator.center = self.center
        self.addSubview(indikator)
        indikator.startAnimating()
        self.isUserInteractionEnabled = false
        
        if self.tag == 0 {
            Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Chapters").queryOrdered(byChild: "Name")
                .queryStarting(atValue: name)
                .queryEnding(atValue: name + "\u{00B0}").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if snapshot.hasChildren(){
                        Helper.showAlertWith(title: "Info", alertMessage: "Chapter is already in use")
                        
                    }else {
                        let chapterRef = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Chapters").child(PathModel.shared.selectedChapter!)
                        chapterRef.updateChildValues(["name" : name]) { (error, shnapshot) in
                            self.isUserInteractionEnabled = true
                            indikator.stopAnimating()
                            if (error == nil) {
                                Helper.showAlertWith(title: "Success", alertMessage: "Name successfully updated")
                                NotificationCenter.default.post(name: Notification.Name.init("RELOAD_CHAPTERS"), object: nil, userInfo: ["topic" : PathModel.shared.selectedTopic!])
                                return
                            }
                            Helper.showAlertWith(title: "Error", alertMessage: "Name update failed")
                        }
                    }
                    
            })
            
        
        }
        if self.tag == 1 {
            let chapterRef = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Topics").child(PathModel.shared.selectedTopic!)
            chapterRef.updateChildValues(["name" : name]) { (error, shnapshot) in
                self.isUserInteractionEnabled = true
                indikator.stopAnimating()
                if (error == nil) {
                    Helper.showAlertWith(title: "Success", alertMessage: "Name successfully updated")
                    NotificationCenter.default.post(name: Notification.Name.init("RELOAD_TOPICS"), object: nil, userInfo: ["topic" : PathModel.shared.selectedTopic!])
                    return
                }
                Helper.showAlertWith(title: "Error", alertMessage: "Name update failed")
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        nameTextField.delegate = self
        // Initialization code
        doneButton.layer.borderWidth = 1
        cencel.layer.borderWidth = 1
        doneButton.layer.borderColor = UIColor.black.cgColor
        cencel.layer.borderColor = UIColor.black.cgColor
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 25 // Bool
    }
    
}
