//
//  FollowingTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 03.06.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Firebase


class FollowingTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    var followingObj: FollowingModel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.borderWidth  = 1
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.masksToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
   
    
    func setFollowingModel(model: FollowingModel) {
        DispatchQueue.global(qos: .background).async {
            
            if model.followingImage != nil && model.followingImage != "" {
                let url = URL.init(string: model.followingImage! )
                do {
                    let imageData = try Data.init(contentsOf: url!)
                    let image = UIImage.init(data: imageData)
                    DispatchQueue.main.async {
                        self.followingObj = model
                        self.profileImageView.image = image
                    }
                    
                }catch let error {
                    print(error.localizedDescription)
                }
            }
            
            if model.followingName != nil && model.followingName != "" {
                DispatchQueue.main.async {
                    self.followingObj = model
                    self.nameLabel.text = model.followingName
                }
            }
            
            
        }
    }
    
    @IBAction func unfollowButtonAction(_ sender: UIButton) {
        Database.database().reference().child("UnfolowingRequests").childByAutoId().updateChildValues(["fromUser" : (Auth.auth().currentUser?.uid)!, "toUser" : self.followingObj?.followingID!])
        
        self.perform(#selector(reloadFolowingsView), with: nil, afterDelay: 1.4)
    }
    
    @objc func reloadFolowingsView(){
         NotificationCenter.default.post(name: Notification.Name.init("RELOAD_UNFOLOW_REQUESTS"), object: nil)
    }
}
