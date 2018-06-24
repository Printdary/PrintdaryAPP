//
//  SearchTableTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 27.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Firebase

class SearchTableTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var folowButton: UIButton!
    var userID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.init(red: 85/255.0, green: 203/255.0, blue: 255/255.0, alpha: 1).cgColor
        folowButton.layer.cornerRadius = 5
        folowButton.layer.borderWidth = 1
        folowButton.layer.borderColor = UIColor.init(red: 85/255.0, green: 203/255.0, blue: 255/255.0, alpha: 1).cgColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func checkIfUserIsAlredyFollowed(){
        DispatchQueue.global(qos: .background).async {
            let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Followings")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.hasChild(self.userID!) {
                    DispatchQueue.main.async {
                        self.folowButton.setTitle("Following", for: .normal)
                        self.folowButton.isUserInteractionEnabled = false
                    }
                    
                }else {
                    DispatchQueue.main.async {
                        self.folowButton.setTitle("Follow", for: .normal)
                        self.folowButton.isUserInteractionEnabled = true
                    }
                }
                
            }
        }
  
    }
    
    @IBAction func folowButtonAction(_ sender: UIButton) {
    //    if sender.tag == 0 {
      //  sender.tag = 1
     //   sender.setTitle("Follow", for: .normal)
        if userID != nil  && ((Auth.auth().currentUser?.uid) != nil) {
        let ref = Database.database().reference().child("folowingRequest").childByAutoId()
            ref.updateChildValues(["userID" : userID! , "fromUserID" : (Auth.auth().currentUser?.uid)!])
        }
      //  }else {
//            sender.tag = 0
//            sender.setTitle("Follow", for: .normal); Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Followings").child(self.userID!).removeValue()
      //  }
    }
}
