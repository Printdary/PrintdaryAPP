//
//  DeleteChapterAlertView.swift
//  zya
//
//  Created by Shoghik Khachatryan on 28.05.2018.
//  Copyright © 2018 Shoghik Khachatryan. All rights reserved.
//

import UIKit
import Firebase

class DeleteChapterAlertView: UIView {

    @IBOutlet weak var trashImageView: UIImageView!
    @IBOutlet weak var infoLabel: UITextView!
    @IBOutlet weak var acceptView: UIView!
    @IBOutlet weak var cencelView: UIView!
    
   
    @IBAction func acceptButton(_ sender: UIButton) {
        let chapterRef = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Chapters").child(PathModel.shared.selectedChapter!)
        chapterRef.removeValue()
        
        let unitRef = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").queryOrdered(byChild: "chapterID").queryStarting(atValue: PathModel.shared.selectedChapter!).queryEnding(atValue: PathModel.shared.selectedChapter! + "\u{00B0}")
        unitRef.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject]{
                for (key, _) in dict  {
                    Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").child(key).removeValue()
                }
            }
        }
        
        NotificationCenter.default.post(name: Notification.Name.init("RELOAD_CHAPTERS"), object: nil, userInfo: ["topic" : PathModel.shared.selectedTopic!])
        self.removeFromSuperview()
    }
    
    @IBAction func cencelButton(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        acceptView.layer.cornerRadius = acceptView.frame.size.height/2
        cencelView.layer.cornerRadius = cencelView.frame.size.height/2
        acceptView.layer.borderWidth = 1
        cencelView.layer.borderWidth = 1
        acceptView.layer.borderColor = UIColor.white.cgColor
        cencelView.layer.borderColor = UIColor.white.cgColor
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    
    func setAlertTest(text: String){
        infoLabel.text = "Are you sure about deleting \(text)? Everything within the chapter will be deleted (Units)."
    }
}
