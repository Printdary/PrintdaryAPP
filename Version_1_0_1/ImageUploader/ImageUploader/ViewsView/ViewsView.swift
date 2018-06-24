//
//  ViewsView.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 03.06.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Firebase

class ViewsView: UIView,UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var viewTableView: UITableView!
    var viewsListArray = [ViewModel]()
    var unitId : String?
    
    
    override func awakeFromNib() {
        viewTableView.delegate = self
        viewTableView.dataSource = self
        viewTableView.register(UINib.init(nibName: "ViewsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ViewsTableViewCell")
        
        
        
    }
    
    
    
    func getViewsList(){
        DispatchQueue.global(qos: .background).async {
            Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").child(self.unitId!).child("Views").observeSingleEvent(of: .value) { (snapshot) in
                if let dict = snapshot.value as? [String : AnyObject] {
                    var array = [String]()
                    for key in dict.keys {
                        array.append(key)
                    }
                    self.getViewedUserInfo(users: array)
                }
            
        }
      }
    }
    
    
    
    
    func getViewedUserInfo(users: [String]){
        DispatchQueue.global(qos: .background).async {
            for id in users {
                Database.database().reference().child("User").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dict = snapshot.value as? [String : AnyObject] {
                        let viewModel = ViewModel()
                        viewModel.viewImage = dict["imageURL"] as! String
                        viewModel.viewName = dict["Name"] as! String
                        viewModel.viewID = snapshot.key
                        self.viewsListArray.append(viewModel)
                        DispatchQueue.main.async {
                            self.viewTableView.reloadData()
                        }
                    }
                })
            }
        }
    }
    
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewsListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewsTableViewCell", for: indexPath) as! ViewsTableViewCell
        cell.setViewModel(model: viewsListArray[indexPath.row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}
class ViewModel: NSObject {
    var viewName: String?
    var viewID : String?
    var viewImage: String?
}
