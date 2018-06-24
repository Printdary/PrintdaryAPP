//
//  AlertVIew.swift
//  zya
//
//  Created by Shoghik Khachatryan on 25.05.2018.
//  Copyright © 2018 Shoghik Khachatryan. All rights reserved.
//

import UIKit
import Firebase

class DeleteTopicAlertVIew: UIView {
    
    @IBOutlet weak var trashImageView: UIImageView!
    
    @IBOutlet weak var infoLabel: UITextView!
    
    @IBOutlet weak var acceptView: UIView!
    
    @IBOutlet weak var cencelView: UIView!
    
    @IBOutlet weak var acceptImageView: UIImageView!
    
    
    @IBAction func acceptButton(_ sender: UIButton) {
        
        let topicRef = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Topics").child(PathModel.shared.selectedTopic!)
         topicRef.removeValue()
        
        let chapterRef = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Chapters").queryOrdered(byChild: "topicID").queryStarting(atValue: PathModel.shared.selectedTopic!).queryEnding(atValue: PathModel.shared.selectedTopic! + "\u{00B0}")
        chapterRef.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject]{
                for (key, _) in dict  {
                    Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Chapters").child(key).removeValue()
                }
            }
        }
        
        let unitRef = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").queryOrdered(byChild: "chapterID").queryStarting(atValue: PathModel.shared.selectedChapter!).queryEnding(atValue: PathModel.shared.selectedChapter! + "\u{00B0}")
        unitRef.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject]{
                for (key, _) in dict  {
                    Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").child(key).removeValue()
                }
            }
        }

        
         NotificationCenter.default.post(name: Notification.Name.init("RELOAD_TOPICS"), object: nil, userInfo: nil)
        self.removeFromSuperview()
        
    }
  
    @IBAction func cencelButton(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    @IBOutlet weak var cencelImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       acceptView.layer.cornerRadius = acceptView.frame.size.height/2
       cencelView.layer.cornerRadius = cencelView.frame.size.height/2
       acceptView.layer.borderWidth = 1
       cencelView.layer.borderWidth = 1
       acceptView.layer.borderColor = UIColor.white.cgColor
       cencelView.layer.borderColor = UIColor.white.cgColor
        // Initialization code
    }
    
    
    func setAlertTest(text: String){
        infoLabel.text = "Are you sure about deleting \(text)? Everything within the topic will be deleted (chapters and Units)."
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
}
