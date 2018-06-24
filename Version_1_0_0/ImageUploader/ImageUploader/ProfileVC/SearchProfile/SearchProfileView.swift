//
//  SearchProfileView.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 27.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Firebase

class SearchProfileView: UIView,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{

    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    var resultsArray = [SearchResult]()
    
    
    
    override func awakeFromNib() {
        searchTextField.rightViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image = UIImage(named: "searchIcon")
        imageView.image = image
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTextField.rightView = imageView
        searchTextField.delegate = self
        
        
        searchTableView.register(UINib.init(nibName: "SearchTableTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
    }
    
    
    
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchTableTableViewCell
        cell.nameLabel.text = resultsArray[indexPath.row].userName
        cell.userID = resultsArray[indexPath.row].userId
        cell.checkIfUserIsAlredyFollowed()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        
        seachUser(named: result)
        return true
    }
    
    func seachUser(named : String){
        self.resultsArray.removeAll()
        if named == "" {
            self.searchTableView.reloadData()
            return
        }
        self.resultsArray.removeAll()
        let usersRef = Database.database().reference().child("User")
        usersRef.queryOrdered(byChild: "Name")
            .queryStarting(atValue: named)
            .queryEnding(atValue: named + "\u{00B0}")
            .observeSingleEvent(of: .value, with: { (snapshot) in
                if let snap = snapshot.value as? [String : AnyObject] {
                    for key in snap.keys {
                        if let obcect = snap[key]as? [String : AnyObject]{
                            if key != Auth.auth().currentUser?.uid {
                            var searchObj = SearchResult()
                            searchObj.userName = obcect["Name"] as! String
                            searchObj.userId = key as! String
                            self.resultsArray.append(searchObj)
                            }
                        }
                    }
                    self.searchTableView.reloadData()
                   
                } else {
                    self.searchTableView.reloadData()
                }
            })
        
        
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

class SearchResult : NSObject {
    var userName: String?
    var userId: String?
}
