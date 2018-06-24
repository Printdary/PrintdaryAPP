//
//  FollowingView.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 03.06.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Firebase

class FollowingView: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var followingTableView: UITableView!
    var followingListArray = [FollowingModel]()
    
    
    override func awakeFromNib() {
        NotificationCenter.default.addObserver(self, selector: #selector(getFollowingList), name: Notification.Name.init("RELOAD_UNFOLOW_REQUESTS"), object: nil)
        
        followingTableView.delegate = self
        followingTableView.dataSource = self
        followingTableView.register(UINib.init(nibName: "FollowingTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "FollowingTableViewCell")
        
        getFollowingList()
    }
    
    
    
    
    @objc func getFollowingList() {
        self.followingListArray.removeAll()
        DispatchQueue.global(qos: .background).async {
            
         Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Followings").observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                var array = [String]()
                
                for key in dict.keys {
                    array.append(key)
                }
                self.getFolowingUserInfo(users: array)
            }else {
                DispatchQueue.main.async {
                    self.followingListArray.removeAll()
                    self.followingTableView.reloadData()
                }
            }
        }
        }
    }
    
    func getFolowingUserInfo(users : [String]){
        DispatchQueue.global(qos: .background).async {
            for userid in users {
                Database.database().reference().child("User").child(userid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dict = snapshot.value as? [String : AnyObject] {
                        let name = dict["Name"] as! String
                        let userId = snapshot.key
                        let imageUrl = dict["imageURL"] as! String
                        let folowingModel = FollowingModel()
                        folowingModel.followingName = name
                        folowingModel.followingID = userId
                        folowingModel.followingImage = imageUrl
                        self.followingListArray.append(folowingModel)
                        DispatchQueue.main.async {
                            self.followingTableView.reloadData()
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
        
        return followingListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingTableViewCell", for: indexPath) as! FollowingTableViewCell
        cell.setFollowingModel(model: followingListArray[indexPath.row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


class FollowingModel: NSObject {
    var followingName: String?
    var followingID : String?
    var followingImage: String?
}
