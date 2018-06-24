//
//  ProfileInfoTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 23.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Firebase

class ProfileInfoTableViewCell: UITableViewCell{
    
    @IBOutlet weak var profileIconImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileInfoLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
     @IBOutlet weak var notificationIcon: UIView!
    var rootViewController: ProfileViewController?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        profileIconImageView.layer.cornerRadius = 30
        profileIconImageView.layer.borderWidth = 1
        profileIconImageView.layer.borderColor = UIColor.white.cgColor
        profileIconImageView.layer.masksToBounds = true
        // Initialization code
        getFollowersList()
        getFollowingList()
        getProfileInfo()
        getFollowingRequests()
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name.init("RELOAD_FOLLOWERS"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(getProfileInfo), name: Notification.Name.init("Reload_user_info"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(getFollowingRequests), name: Notification.Name.init("Reload_following_request"), object: nil)
        
 
    }
    
    func unwatchFrameChanges(){
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func getProfileInfo(){
        DispatchQueue.global(qos: .background).async {
            Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
                if let dict = snapshot.value as? [String : AnyObject]{
                    if let userName = dict["Name"] as? String {
                        DispatchQueue.main.async {
                            self.profileNameLabel.text = userName
                        }
                    }
                    
                    if let userProfession = dict["favoriteSubject"] as? String {
                        DispatchQueue.main.async {
                            self.profileInfoLabel.text = userProfession
                        }
                    }
                    
                    if let userImage = dict["imageURL"] as? String {
                        do {
                            let imageData = try  Data.init(contentsOf: URL.init(string: userImage)!)
                            if let image = UIImage.init(data: imageData) {
                                DispatchQueue.main.async {
                                    self.profileIconImageView.image = image
                                }
                            }
                        }catch let error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func followersButtonAction(_ sender: UIButton) {
       let fView = Bundle.main.loadNibNamed("FolowersView", owner: FolowersView(), options: nil)?.first as! FolowersView
        fView.frame = (rootViewController?.view.frame)!
        rootViewController?.view.addSubview(fView)
    }
    @IBAction func followingButtonAction(_ sender: UIButton) {
        let fView = Bundle.main.loadNibNamed("FollowingView", owner: FolowersView(), options: nil)?.first as! FollowingView
        fView.frame = (rootViewController?.view.frame)!
        rootViewController?.view.addSubview(fView)
    }
    
    
    
   @objc func update(){
        self.getFollowersList()
        self.getFollowingList()
        self.getFollowingRequests()
    
    }
    
    @objc  func getFollowersList(){
        DispatchQueue.global(qos: .background).async {
            Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Followers").observeSingleEvent(of: .value) { (snapshot) in
                if let dict = snapshot.value as? [String : AnyObject] {
                    var array = [String]()
                    for key in dict.keys {
                        array.append(key)
                    }
                    DispatchQueue.main.async {
                        self.followersCountLabel.text = String.init(array.count)
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        self.followersCountLabel.text = String.init(0)
                    }
                }
            }
        }
    }
    
    
    
    
    
    @objc func getFollowingList() {
        DispatchQueue.global(qos: .background).async {
            Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Followings").observeSingleEvent(of: .value) { (snapshot) in
                if let dict = snapshot.value as? [String : AnyObject] {
                    var array = [String]()
                    for key in dict.keys {
                        array.append(key)
                    }
                    DispatchQueue.main.async {
                        self.followingCountLabel.text = String.init(array.count)
                    }
                }else {
                    DispatchQueue.main.async {
                        self.followingCountLabel.text = String.init(0)
                    }
                }
            }
        }
    }
    
    
    @objc func getFollowingRequests(){
        DispatchQueue.global(qos: .background).async {
           Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("FolowingRequest").observeSingleEvent(of: .value) { (snapshot) in
                var array = [String]()
                if let dict = snapshot.value as? [String : AnyObject] {
                    for key in dict.keys {
                        array.append(key)
                    }
                    
                    if array.count > 0{
                        DispatchQueue.main.async {
                            self.notificationIcon.isHidden = false
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.notificationIcon.isHidden = true
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                         self.notificationIcon.isHidden = true
                    }
                }
                
            }
        }
    }
    
    
    
    
}
