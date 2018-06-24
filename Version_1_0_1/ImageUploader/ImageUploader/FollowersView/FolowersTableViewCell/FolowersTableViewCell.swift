//
//  FolowersTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 03.06.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Firebase

class FolowersTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var followerModel: FolowerModel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = true
        self.selectionStyle = .none
        // Initialization code
    }
    
    func setFollowerModel(model: FolowerModel) {
        DispatchQueue.global(qos: .background).async {
            
        
        if model.followerImage != nil {
            let url = URL.init(string: model.followerImage!)
            do {
                let imageData = try Data.init(contentsOf: url!)
                let image = UIImage.init(data: imageData)
                DispatchQueue.main.async {
                    self.profileImageView.image = image
                    self.followerModel = model
                }
                
            }catch let error {
                print(error.localizedDescription)
            }
        }
            if model.followerName != "" {
                DispatchQueue.main.async {
                    self.nameLabel.text = model.followerName
                    self.followerModel = model
                }
            }
            
    }
}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func unfollowButtonAction(_ sender: UIButton) {
        
        Database.database().reference().child("UnfolowingRequests").childByAutoId().updateChildValues(["fromUser" : (followerModel?.followerId)!, "toUser" : (Auth.auth().currentUser?.uid)!])
//        Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Followers").child((followerModel?.followerId)!).removeValue()
        
        self.perform(#selector(reloadFolowingsView), with: nil, afterDelay: 1.4)
    }
    
    @objc func reloadFolowingsView(){
        NotificationCenter.default.post(name: Notification.Name.init("RELOAD_FOLOWERS_LIST"), object: nil)
    }
}
