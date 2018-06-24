//
//  InprintTableViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 16.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Firebase

class InprintTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var baseTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        baseTableView.delegate = self
        baseTableView.dataSource = self
        
        baseTableView.register(UINib.init(nibName: "NotesInfoTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "cellIdentifier1")
        baseTableView.register(UINib.init(nibName: "AudioTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "cellIdentifier2")
        baseTableView.register(UINib.init(nibName: "ImageTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "cellIdentifier3")
         baseTableView.register(UINib.init(nibName: "VideoTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "cellIdentifier4")
         baseTableView.register(UINib.init(nibName: "ModelTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "cellIdentifier5")
        
        baseTableView.register(UINib.init(nibName: "UrlTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "cellIdentifier6")
         baseTableView.register(UINib.init(nibName: "PublishTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "cellIdentifier7")
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBaseTableView), name: Notification.Name.init("RELOADTABLEVIEW"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func deleteButtonAction(_ sender: UIButton) {
        Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").child(UserModel.currentUser.uploadID).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").child(UserModel.currentUser.uploadID).removeValue(completionBlock: { (error, ref) in
                    if error != nil{
                        Helper.showAlertWith(title: "Error", alertMessage: "Delete feiled")
                        return
                    }
                  
                     self.backButtonAction(sender)
                })
                
            }else {
                
            }
        }
    }
    
  @objc  func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")
    if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        self.bottomConstraint.constant = keyboardHeight
    }
    }
    
   @objc   func keyboardWillHide(notification: NSNotification){
        print("keyboardWillHide")
        self.bottomConstraint.constant = 0
    }
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait)
        baseTableView.reloadData()
    }
    
    
   
    @objc func reloadBaseTableView(){
         baseTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Table view data source

 

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
           let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier1", for: indexPath) as! NotesInfoTableViewCell
            cell.selectionStyle = .none
            cell.setupCell()
            cell._rootViewController = self
            cell.setImprintImage(image: CurrentSession.currentSession.croppedImage)
            return cell
        }
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier2", for: indexPath) as! AudioTableViewCell
            cell.selectionStyle = .none
            cell._rootViewController = self
            cell.setAudioViews(audios: CurrentSession.currentSession.audioArray)
            return cell
        }
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier3", for: indexPath) as! ImageTableViewCell
            cell.selectionStyle = .none
            cell._rootViewController = self
            cell.reloadCollectionView()
            return cell
        }
        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier4", for: indexPath) as! VideoTableViewCell
            cell.selectionStyle = .none
            cell._rootViewController = self
            cell.reloadCollectionView()
            return cell
        }
        if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier5", for: indexPath) as! ModelTableViewCell
            cell.selectionStyle = .none
            cell._rootViewController = self
            cell.reloadCollectionView()
            return cell
        }
        if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier6", for: indexPath) as! UrlTableViewCell
            cell.selectionStyle = .none
            cell._rootViewController = self
            cell.setUrlViews(urls: CurrentSession.currentSession.urlArray)
            cell.index = indexPath
            return cell
        }
        if indexPath.row == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier7", for: indexPath) as! PublishTableViewCell
            cell.selectionStyle = .none
            cell._rootViewController = self
            return cell
        }
        // Configure the cell...
        let cell = UITableViewCell.init()
        cell.backgroundColor = UIColor.gray
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 230
        }
        if indexPath.row == 1 {
            if UserDefaults.standard.value(forKey: "NewRecording") != nil{
                return 140
            }
            if CurrentSession.currentSession.audioArray.count == 0 {
                return 60
            }
            if CurrentSession.currentSession.audioArray.count == 1 {
                return 100
            }
            return 60 + CGFloat(CurrentSession.currentSession.audioArray.count * 40)
        }
         if indexPath.row == 2 {
            if CurrentSession.currentSession.imageArray.count == 0 {
                return 60
            }
            return 110
        }
        if indexPath.row == 3 {
            if CurrentSession.currentSession.videosArray.count == 0 {
                return 60
            }
            return 110
        }
        if indexPath.row == 4 {
            if CurrentSession.currentSession.modelsArray.count == 0 {
                return 60
            }
            return 110
        }
        if indexPath.row == 5 {
            
            if CurrentSession.currentSession.urlArray.count == 0 {
                return 60
            }
            if CurrentSession.currentSession.urlArray.count == 1 {
                return 100
            }
            return 60 + CGFloat(CurrentSession.currentSession.urlArray.count * 40)
        }
        
        if indexPath.row == 6 {
            return 120
        }
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }

   
    
    
   
    
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        NotificationCenter.default.post(Notification.init(name: Notification.Name.init("RELOAD_UINITS"), object: nil, userInfo: nil))
       CurrentSession.currentSession.title = ""
       CurrentSession.currentSession.note = ""
       CurrentSession.currentSession.category = ""
       CurrentSession.currentSession.audioArray.removeAll()
       CurrentSession.currentSession.videosArray.removeAll()
       CurrentSession.currentSession.imageArray.removeAll()
       CurrentSession.currentSession.modelsArray.removeAll()
       CurrentSession.currentSession.urlArray.removeAll()
       CurrentSession.currentSession.croppedImage = nil
//        self.performSegue(withIdentifier: "showUserBCVC", sender: sender)
        self.dismiss(animated: true, completion: nil)
    }
    
    

}




