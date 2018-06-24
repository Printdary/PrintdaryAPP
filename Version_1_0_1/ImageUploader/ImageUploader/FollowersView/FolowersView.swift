//
//  FolowersView.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 03.06.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Firebase

class FolowersView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var folowersTableView: UITableView!
    var followersListArray = [FolowerModel]()
    var followersRequestListArray = [RequestedModel]()
    
    
    override func awakeFromNib() {
        folowersTableView.delegate = self
        folowersTableView.dataSource = self
        folowersTableView.register(UINib.init(nibName: "FolowersTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "FolowersTableViewCell")
        
        
        folowersTableView.register(UINib.init(nibName: "FollowingRequestTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "FollowingRequestTableViewCell")
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(getFollowingRequests), name: Notification.Name.init("RELOAD_FOLOWING_REQUESTS"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(getFollowersList), name: Notification.Name.init("RELOAD_FOLOWERS_LIST"), object: nil)
        
        getFollowersList()
        getFollowingRequests()
    }
    
   @objc func getFollowingRequests(){
    DispatchQueue.global(qos: .background).async {
    
    
    self.followersRequestListArray.removeAll(); Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("FolowingRequest").observeSingleEvent(of: .value) { (snapshot) in
            var array = [String]()
            if let dict = snapshot.value as? [String : AnyObject] {
                for key in dict.keys {
                    array.append(key)
                }
                self.getRequestSendedUserInformatin(userids: array)
            }
            else {
                DispatchQueue.main.async {
                    self.folowersTableView.reloadData()
                }
            }
            
          }
    }
    }
    
    
    func getRequestSendedUserInformatin(userids: [String]) {
        DispatchQueue.global(qos: .background).async {
            
        
        for id in userids {
            Database.database().reference().child("User").child(id).observeSingleEvent(of: .value) { (snapshot) in
                if let dict = snapshot.value as? [String : AnyObject] {
                    let name = dict["Name"] as? String
                    let imageUrl = dict["imageURL"] as? String
                    let reqModel = RequestedModel()
                    reqModel.name = name!
                    reqModel.imageUrl = imageUrl!
                    reqModel.userId = snapshot.key
                    self.followersRequestListArray.append(reqModel)
                }
                DispatchQueue.main.async {
                    self.folowersTableView.reloadData()
                }
            }
            
        }
        
        }
    }
    
    
  @objc  func getFollowersList(){
    DispatchQueue.global(qos: .background).async {
        
        self.followersListArray.removeAll()
        Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Followers").observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                var array = [String]()
                for key in dict.keys {
                    array.append(key)
                }
                self.getFollowerUserInformation(users: array)
            }else {
                DispatchQueue.main.async {
                    self.followersListArray.removeAll()
                    self.folowersTableView.reloadData()
                }
            }
        }
    }
}

    
    
    func getFollowerUserInformation(users:[String]){
        DispatchQueue.global(qos: .background).async {
            for id in users {
                Database.database().reference().child("User").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dict = snapshot.value as? [String : AnyObject] {
                        let followerModel = FolowerModel()
                        followerModel.followerImage = dict["imageURL"] as! String
                        followerModel.followerName = dict["Name"] as! String
                        followerModel.followerId = snapshot.key
                        self.followersListArray.append(followerModel)
                        DispatchQueue.main.async {
                            self.folowersTableView.reloadData()
                        }
                    }
                })
            }
        }
        
    }
   
    @IBAction func backButtonAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name.init("RELOAD_FOLLOWERS"), object: nil, userInfo: nil)
        self.removeFromSuperview()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return followersListArray.count + followersRequestListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < self.followersRequestListArray.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingRequestTableViewCell", for: indexPath) as! FollowingRequestTableViewCell
            cell.setRequestModel(model: followersRequestListArray[indexPath.row])
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolowersTableViewCell", for: indexPath) as! FolowersTableViewCell
        cell.setFollowerModel(model: followersListArray[indexPath.row - self.followersRequestListArray.count])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


class FolowerModel: NSObject {
    
    var followerName: String?
    var followerId: String?
    var followerImage: String?
}

class RequestedModel: NSObject {
    var name = ""
    var imageUrl = ""
    var userId = ""
}
