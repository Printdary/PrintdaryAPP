//
//  FollowingRequestTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 03.06.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Firebase

class FollowingRequestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var redView: UIView!
    var requestModel: RequestedModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.borderWidth  = 1
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.masksToBounds = true
        redView.layer.cornerRadius = 5
    }
    
    
    func setRequestModel(model: RequestedModel) {
        DispatchQueue.global(qos: .background).async {
         
        if model.imageUrl != nil && model.imageUrl != "" {
            let url = URL.init(string: model.imageUrl )
            do {
                let imageData = try Data.init(contentsOf: url!)
                let image = UIImage.init(data: imageData)
                DispatchQueue.main.async {
                     self.requestModel = model
                    self.profileImageView.image = image
                }
                
            }catch let error {
                print(error.localizedDescription)
            }
        }
            
            if model.name != nil && model.name != "" {
                DispatchQueue.main.async {
                     self.requestModel = model
                    self.nameLabel.text = model.name
                }
            }
            
           
    }
}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func cancelButtonAction(_ sender: UIButton) {
    Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("FolowingRequest").child((requestModel?.userId)!).removeValue()
        NotificationCenter.default.post(name: Notification.Name.init("RELOAD_FOLOWING_REQUESTS"), object: nil)
        
    }
    
    @IBAction func acceptButtonAction(_ sender: UIButton) {
        Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Followers").child((requestModel?.userId)!).updateChildValues(["followerID": (requestModel?.userId)!])
            self.cancelButtonAction(sender)
            NotificationCenter.default.post(name: Notification.Name.init("RELOAD_FOLOWERS_LIST"), object: nil)
        
        Database.database().reference().child("AcceptedRequests").childByAutoId().updateChildValues(["followingId" : (Auth.auth().currentUser?.uid)!, "userID" : (requestModel?.userId)!])
        
        
    }
    
}
