//
//  ProfileViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 23.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Firebase
import DropDown

class ProfileViewController: UIViewController,UITableViewDelegate, UITableViewDataSource ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var baseTableView: UITableView!
    @IBOutlet weak var imprintsTableView: UITableView!
    @IBOutlet weak var profilImageView: UIImageView!
    @IBOutlet weak var addImageView: UIImageView!
    @IBOutlet weak var searchImageView: UIImageView!
    var searchView: SearchProfileView?
    var menuView: MenuView?
    var unitsArray = [UnitModel]()
    let dropDown = DropDown()
    var swipeGesture : UISwipeGestureRecognizer?
    var imagePickerController = UIImagePickerController()

    @IBOutlet weak var tapBarView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseTableView.delegate = self
        baseTableView.dataSource = self
        
        imprintsTableView.delegate = self
        imprintsTableView.dataSource = self
        baseTableView.isScrollEnabled = false
        swipeGesture = UISwipeGestureRecognizer.init(target: self, action:#selector(backAction(_:)))
        swipeGesture?.direction = .left
        self.view.addGestureRecognizer(swipeGesture!)
        
        baseTableView.register(UINib.init(nibName: "ProfileInfoTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "identifire1")
        baseTableView.register(UINib.init(nibName: "GoalTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "identifire2")
        
        baseTableView.register(UINib.init(nibName: "TopicTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "Topic_Cell")
        
        baseTableView.register(UINib.init(nibName: "ChapterTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "chapter_Cell")
        
         imprintsTableView.register(UINib.init(nibName: "ImprintTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "identifire1")
        
        // Do any additional setup after loading the view.
        
       
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        AppUtility.lockOrientation(.portrait)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSelectChapter(info:)), name: Notification.Name.init("DID_SELECT_CHAPTER"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleSelectTopic(info:)), name: Notification.Name.init("DID_SELECT_TOPIC"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleSelectNewTopic(info:)), name: Notification.Name.init("NEW_TOPIC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSelectNewChapter(info:)), name: Notification.Name.init("NEW_Chapter"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSelectNewUnit(info:)), name: Notification.Name.init("NEW_UNIT"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlerReloadUnits), name: Notification.Name.init("RELOAD_UINITS"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(addBlurArea(info:)), name: Notification.Name.init("ADD_BLUR"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeBlur(info:)), name: Notification.Name.init("REMOVE_BLUR"), object: nil)
        
          NotificationCenter.default.addObserver(self, selector: #selector(addBlurForUnit(info:)), name: Notification.Name.init("ADD_BLUR_FOR_UNIT"), object: nil)
    
        
        baseTableView.reloadData()
     
    }
    
    
    @objc func removeBlur(info: Notification){
        let window = UIApplication.shared.keyWindow!
        window.subviews.last?.removeFromSuperview()
        window.subviews.last?.removeFromSuperview()
    }
    
    
  @objc func addBlurForUnit(info: Notification) {
    if let userInfo = info.userInfo as? [String: AnyObject]{
        let cellArea = userInfo["area"] as! CGRect
        let effect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurViewTop = UIVisualEffectView(effect: effect)
        let blurViewBottom = UIVisualEffectView(effect: effect)
        blurViewTop.frame = CGRect(x: 0, y: 0, width: cellArea.size.width, height: cellArea.origin.y )
        blurViewBottom.frame = CGRect(x: 0, y: cellArea.origin.y + cellArea.size.height , width: cellArea.size.width, height: self.view.frame.size.height)
        blurViewTop.alpha = 0.8
        blurViewBottom.alpha = 0.8
        
        let window = UIApplication.shared.keyWindow!
        window.addSubview(blurViewTop);
        window.addSubview(blurViewBottom);
    }
    
    }
    
   @objc func addBlurArea(info: Notification) {
    
    if let userInfo = info.userInfo as? [String: AnyObject]{
        let cellArea = userInfo["area"] as! CGRect
    
    
        let effect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurViewTop = UIVisualEffectView(effect: effect)
        let blurViewBottom = UIVisualEffectView(effect: effect)
        blurViewTop.frame = CGRect(x: 0, y: 0, width: cellArea.size.width, height: cellArea.origin.y + 50)
        blurViewBottom.frame = CGRect(x: 0, y: cellArea.origin.y + 50 + cellArea.size.height, width: cellArea.size.width, height: self.view.frame.size.height)
        blurViewTop.alpha = 0.8
        blurViewBottom.alpha = 0.8
        
        let window = UIApplication.shared.keyWindow!
        window.addSubview(blurViewTop);
        window.addSubview(blurViewBottom);
    }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init("NEW_Chapter"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init("NEW_TOPIC"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init("NEW_UNIT"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init("RELOAD_UINITS"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init("DID_SELECT_CHAPTER"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init("DID_SELECT_TOPIC"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init("ADD_BLUR"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init("REMOVE_BLUR"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init("ADD_BLUR_FOR_UNIT"), object: nil)
        for row in 0...3 {
            let indexPath = NSIndexPath(row: row, section: 0)
            if let cell = baseTableView.cellForRow(at: indexPath as IndexPath) as? TopicTableViewCell {
                cell.unwatchFrameChanges()
            }
            if let cell = baseTableView.cellForRow(at: indexPath as IndexPath) as? ChapterTableViewCell {
                cell.unwatchFrameChanges()
            }
            if let cell = baseTableView.cellForRow(at: indexPath as IndexPath) as? ProfileInfoTableViewCell {
                cell.unwatchFrameChanges()
            }
        }
        
       

        
    }
    
   
    @IBAction func optionsButtonAction(_ sender: UIButton) {
        dropDown.anchorView = sender // UIView or UIBarButtonItem
        dropDown.dataSource = ["Edit Profession", "Edit Goals","Edit profile pic","Sign Out"]
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.dropDown.hide()
            if index == 0 {
                self.editProfessionAlert()
            }
            if index == 1 {
                self.editGoalsAlert()
            }
            if index == 2 {
                self.imagePickerController.delegate = self
                self.imagePickerController.sourceType = .photoLibrary
                self.imagePickerController.allowsEditing = false
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
            if index == 3 {
               try! Auth.auth().signOut()
               let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
               let vc = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
                let delegat = UIApplication.shared.delegate as? AppDelegate
                delegat?.window?.rootViewController = vc
                self.dismiss(animated: false, completion: nil)
            }
        }
        
        // Will set a custom width instead of the anchor view width
        dropDown.width = sender.frame.size.width * 4
        dropDown.show()
    }
    
    func editProfessionAlert() {
        let alert = UIAlertController.init(title: "", message: "Enter your profession", preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "Done", style: .default , handler: { action in
            self.editProfession(profession: (alert.textFields![0].text != nil) ?  alert.textFields![0].text! : "")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func editGoalsAlert() {
        let alert = UIAlertController.init(title: "", message: "Enter your goals", preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "Done", style: .default , handler: { action in
            self.editGoals(profession: (alert.textFields![0].text != nil) ?  alert.textFields![0].text! : "")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func editProfession(profession: String){
        let indikator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        indikator.center = self.view.center
        self.view.addSubview(indikator)
        indikator.startAnimating()
        self.view.isUserInteractionEnabled = false
        Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).updateChildValues(["favoriteSubject" : profession]) { (error, ref) in
            indikator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if error != nil {
                Helper.showAlertWith(title: "Error", alertMessage: "An error was occurred while updating profession")
                return
            }
            Helper.showAlertWith(title: "Success", alertMessage: "Profession successfully updated")
            NotificationCenter.default.post(name: Notification.Name.init("Reload_user_info"), object: nil, userInfo: nil)
        }
    }
    
    func editGoals(profession: String){
        let indikator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        indikator.center = self.view.center
        self.view.addSubview(indikator)
        indikator.startAnimating()
        self.view.isUserInteractionEnabled = false
        Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).updateChildValues(["goals" : profession]) { (error, ref) in
            indikator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if error != nil {
                Helper.showAlertWith(title: "Error", alertMessage: "An error was occurred while updating goals")
                return
            }
            Helper.showAlertWith(title: "Success", alertMessage: "Goals successfully updated")
            NotificationCenter.default.post(name: Notification.Name.init("Reload_user_info"), object: nil, userInfo: nil)
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
        // self.performSegue(withIdentifier: "showUserBCVC", sender: sender)
    }
 
    
    
    @objc func handleSelectNewTopic(info: Notification){
        menuView?.removeFromSuperview()
        plusButton.tag = 0
        createNewTopic()
    }
    @objc func handleSelectNewChapter(info: Notification){
        if (PathModel.shared.selectedTopic != nil ) {
        menuView?.removeFromSuperview()
        plusButton.tag = 0
        createNewChapter()
        }
    }
    @objc func handleSelectNewUnit(info: Notification){
        menuView?.removeFromSuperview()
        plusButton.tag = 0
        if (PathModel.shared.selectedTopic != nil && PathModel.shared.selectedChapter != nil ) {
           // creatNewUnit()
            addNewUnit()
        } else {
            Helper.showAlertWith(title: "Chapter is required", alertMessage: "")
        }
    }
    
    
    func addNewUnit(){
        CurrentSession.currentSession.imageArray.removeAll()
        CurrentSession.currentSession.videosArray.removeAll()
        CurrentSession.currentSession.audioArray.removeAll()
        CurrentSession.currentSession.modelsArray.removeAll()
        CurrentSession.currentSession.urlArray.removeAll()
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "imprintVC") as! InprintTableViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    func creatNewUnit(){
        let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").childByAutoId()
        let interval = Date.timeIntervalSinceReferenceDate
        ref.updateChildValues(["createdDate" : interval, "unitID" : ref.key , "chapterID" : PathModel.shared.selectedChapter!]) { (error,ref ) in
            DispatchQueue.main.async {
                self.reloadUnits(selectedChapterID: PathModel.shared.selectedChapter!)
            }
        }
        
    
    }
    
   
    
    func createNewChapter(){
       print("createNewChapter")
     
        Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Chapters").queryOrdered(byChild: "topicID").queryStarting(atValue: PathModel.shared.selectedTopic!).queryEnding(atValue: PathModel.shared.selectedTopic! + "\u{00B0}").observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                
                let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Chapters").childByAutoId()
                let interval = Date.timeIntervalSinceReferenceDate
                ref.updateChildValues(["createdDate" : interval, "chapterID" : ref.key, "name" : "Chapter \(dict.keys.count + 1)","topicID": PathModel.shared.selectedTopic!]) { (error,ref ) in
                    DispatchQueue.main.async {
                        self.reloadChapters()
                    }
                }
            }else {
                let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Chapters").childByAutoId()
                let interval = Date.timeIntervalSinceReferenceDate
                ref.updateChildValues(["createdDate" : interval, "chapterID" : ref.key, "name" : "Chapter 1","topicID": PathModel.shared.selectedTopic!]) { (error,ref ) in
                    DispatchQueue.main.async {
                        self.reloadChapters()
                    }
                }
            }
        }
 
       
    }
    
    
    func createNewTopic(){
        Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Topics").observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Topics").childByAutoId()
                let interval = Date.timeIntervalSinceReferenceDate
                ref.updateChildValues(["createdDate" : interval, "topicID" : ref.key, "name" : "Topic \(dict.keys.count + 1)"])
                self.reloadTopics()
                PathModel.shared.selectedTopic = ref.key
                self.createNewChapter()
            }
        }
        
        
      
    }
    
    @objc func handlerReloadUnits(){
        if PathModel.shared.selectedChapter != nil {
         self.reloadUnits(selectedChapterID: PathModel.shared.selectedChapter!)
        }
    }
    
  
    func reloadUnits(selectedChapterID: String){
        self.unitsArray.removeAll()
        DispatchQueue.global(qos: .utility).async {
            let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").queryOrdered(byChild: "chapterID").queryStarting(atValue: PathModel.shared.selectedChapter!)
                .queryEnding(atValue: PathModel.shared.selectedChapter! + "\u{00B0}")
            ref.observeSingleEvent(of:.value) { (snapshot) in
            if let object = snapshot.value as? [String : AnyObject] {
                self.unitsArray.removeAll()
                for key in object.keys {
                    let unitModel = UnitModel()
                    unitModel.unitID = key
                    
                    if let value = object[key] as? [String : AnyObject] {
                        print(value)
                        unitModel.unitState = value["stateID"] as! String
                       for key1 in value.keys {
                            print(key)
                         if let value1 = value[key1] as? [String : AnyObject] {
                            print(value1)
                            for key2 in value1.keys {
                               
                                if let value2 = value1[key2] as? [String : AnyObject] {
                                    
                                     unitModel.createdDate = (value2["createdDate"] as? Double)
                                    if key1 == "AudioFiles" {
                                        let audioModel = AudioObject()
                                        audioModel.audioURL = URL.init(string: value2["dawnloadURL"] as! String)
                                        audioModel.key = key2
                                        unitModel.unitAudio.append(audioModel)
                                    }
                                    if key1 == "Photos" {
                                        if let imageurl = URL.init(string:value2["dawnloadURL"] as! String) {
                                            let imageObj = ImageObject()
                                            imageObj.key = key2
                                            imageObj.imageURL = imageurl
                                            unitModel.unitImage.append(imageObj)
                                        }

                                    }
                                    if key1 == "URLs" {
                                        let urlObject = UrlObject()
                                        urlObject.url = URL.init(string: value2["dawnloadURL"] as! String)
                                        urlObject.key = key2
                                        unitModel.unitUrl.append(urlObject)
                                    }
                                    if key1 == "VideoFiles" {
                                        let videoObj = VideoObject()
                                        videoObj.videoURL = URL.init(string: value2["dawnloadURL"] as! String)
                                        videoObj.key = key2
                                        unitModel.unitVideo.append(videoObj)
                                    }
                                    
                                    if key1 == "Models" {
                                        let modelObj = ModelObject()
                                        modelObj.modelUrl =  value2["dawnloadURL"] as! String
                                        modelObj.key = key2
                                        let imageName = value2["dawnloadURL"] as! String
                                        modelObj.image = UIImage.init(named: "\(imageName).jpg")
                                        unitModel.unitModel.append(modelObj)
                                    }
                                    
                                    if key1 == "Title" {
                                        let title  = value2["Title"] as! String
                                        unitModel.title = title
                                    }
                                    if key1 == "Note" {
                                        let note  = value2["Note"] as! String
                                        unitModel.note = note
                                    }
                                    if key1 == "Category" {
                                        let category  = value2["Category"] as! String
                                        unitModel.category = category
                                    }
                                    if key1 == "ImprintImage" {
                                        let imprintImage  = value2["dawnloadURL"] as! String
                                        unitModel.imprintImage = URL.init(string: imprintImage)
                                    }
                                }
                            }
                         }
                        
                        }
                    }
                   self.unitsArray.append(unitModel)
                }
                    self.unitsArray.sort(by: {$0.createdDate! > $1.createdDate!})
                    DispatchQueue.main.async {
                        self.imprintsTableView.reloadData()
                    }
         }
                
            else {
                 self.unitsArray.removeAll()
                 DispatchQueue.main.async {
                   self.imprintsTableView.reloadData()
                }
            }
            
        }
        
    }
}
    
    
    func reloadTopics(){
        NotificationCenter.default.post(name: Notification.Name.init("RELOAD_TOPICS"), object: nil, userInfo: nil)
    }
    
    func reloadChapters(){
        NotificationCenter.default.post(name: Notification.Name.init("RELOAD_CHAPTERS"), object: nil, userInfo: ["topic" : PathModel.shared.selectedTopic!])
    }
    
    @objc func handleSelectTopic(info: Notification){
        
        if let info = info.userInfo as? [String: Any]{
            if let obj = info["topic"] as? String {
                PathModel.shared.selectedTopic = obj
                if (PathModel.shared.selectedTopic != nil && PathModel.shared.selectedChapter != nil ) {
                    reloadUnits(selectedChapterID: PathModel.shared.selectedChapter!)
                }
            }
        }
    }
    
    @objc func handleSelectChapter(info: Notification){
        
        if let info = info.userInfo as? [String: Any]{
            if let obj = info["chapter"] as? String {
                if obj == "NON" {
                    PathModel.shared.selectedChapter = nil
                } else {
                PathModel.shared.selectedChapter = obj
                }
                if (PathModel.shared.selectedTopic != nil && PathModel.shared.selectedChapter != nil ) {
                    reloadUnits(selectedChapterID: PathModel.shared.selectedChapter!)
                }
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func profileButtonAction(_ sender: UIButton) {
        searchView?.removeFromSuperview()
        searchButton.tag = 0
        searchImageView.backgroundColor = UIColor.init(red: 119/255.0, green: 227/255.0, blue: 255/255.0, alpha: 1)

    }
    
    @IBAction func plusButtonACtion(_ sender: UIButton) {
        searchView?.removeFromSuperview()
        searchButton.tag = 0
        searchImageView.backgroundColor = UIColor.init(red: 119/255.0, green: 227/255.0, blue: 255/255.0, alpha: 1)

        if sender.tag == 0 {
        addImageView.image = UIImage.init(named: "delet")
        menuView = Bundle.main.loadNibNamed("MenuView", owner:MenuView.self, options: nil)?.first as? MenuView
        menuView?.frame = CGRect.init(x: tapBarView.center.x - 150, y: tapBarView.frame.origin.y - 160, width: 300, height: 160)
        self.view.addSubview(menuView!)
            sender.tag = 1
        }else {
            menuView?.removeFromSuperview()
            addImageView.image = UIImage.init(named: "Add")
            sender.tag = 0
        }
    }
    
    
    @IBAction func searchButtonAction(_ sender: UIButton) {
        if sender.tag == 0 {
         searchImageView.backgroundColor = UIColor.init(red: 0/255.0, green: 59/255.0, blue: 88/255.0, alpha: 1)
searchView = Bundle.main.loadNibNamed("SearchProfileView", owner: SearchProfileView(), options: nil)?.first as! SearchProfileView
            
            searchView?.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 50)
        
            self.view.addSubview(searchView!)
            sender.tag = 1
            return
        }
         sender.tag = 0
        searchImageView.backgroundColor = UIColor.init(red: 119/255.0, green: 227/255.0, blue: 255/255.0, alpha: 1)

         searchView?.removeFromSuperview()
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == imprintsTableView {
            return unitsArray.count
        }
        return 4
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == imprintsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "identifire1", for: indexPath) as? ImprintTableViewCell
            cell?.setUnitModel(unitModel: unitsArray[indexPath.row])
            cell?.rootViewController = self
            cell?.index = indexPath
            return cell!
            
        }
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "identifire1", for: indexPath) as? ProfileInfoTableViewCell
              cell?.rootViewController = self
              cell?.getFollowersList()
            return cell!
        }
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "identifire2", for: indexPath) as? GoalTableViewCell
            return cell!
        }
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Topic_Cell", for: indexPath) as? TopicTableViewCell
            cell?.rootViewController = self
            cell?.addNotificationObservers()
            reloadTopics()
            return cell!
        }
        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chapter_Cell", for: indexPath) as? ChapterTableViewCell
            cell?.addNotificationObservers()
            cell?.rootViewController = self
            return cell!
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == imprintsTableView {
            return 100
        }
        if indexPath.row == 0 {
            return self.baseTableView.frame.size.height * 6 / 18
        }
        if indexPath.row == 1 {
            return self.baseTableView.frame.size.height *  5 / 18
        }
        if indexPath.row == 2 {
            return self.baseTableView.frame.size.height * 3.5 / 18
        }
        if indexPath.row == 3 {
            return self.baseTableView.frame.size.height  * 3.5 / 18
        }
         return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == imprintsTableView {
            let cell = tableView.cellForRow(at: indexPath) as! ImprintTableViewCell
            if cell.isSelectedCell {
                cell.setSellectedStyle()
            }
            UserDefaults.standard.set(cell.unitModel?.unitID, forKey: "unitID")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if tableView == baseTableView {
//            let imprintCell = cell as! ImprintTableViewCell
//            NotificationCenter.default.removeObserver(imprintCell, name: Notification.Name.init("DID_SELECT_TOPIC"), object: nil)
//             NotificationCenter.default.removeObserver(imprintCell, name: Notification.Name.init("DID_SELECT_CHAPTER"), object: nil)
//             NotificationCenter.default.removeObserver(imprintCell, name: Notification.Name.init("RELOAD_CHAPTERS"), object: nil)
//        }
//    }
//
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.uploadImageToServer(image: pickedImage)
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    func uploadImageToServer(image: UIImage){
        let activity = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        activity.center = self.view.center
        self.view.addSubview(activity)
        activity.startAnimating()
        self.view.isUserInteractionEnabled = false
        let storageRef = Storage.storage().reference().child((Auth.auth().currentUser?.uid)!).child("image/user.png")
         if let uploadData = UIImagePNGRepresentation(image) {
            storageRef.putData(uploadData, metadata: nil) { (ref, err) in
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    activity.stopAnimating()
                }
                if err != nil {
                     DispatchQueue.main.async {
                    Helper.showAlertWith(title: "Errror", alertMessage: "Upload failed")
                    }
                    return
                }
                 Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).updateChildValues(["imageURL" : ref?.downloadURL()?.absoluteString as Any])
                 DispatchQueue.main.async {
                  Helper.showAlertWith(title: "Success", alertMessage: "Upload success")
                  NotificationCenter.default.post(name: Notification.Name.init("Reload_user_info"), object: nil, userInfo: nil)
                    
                }
            }
         }
    }
}



class UnitModel: NSObject {
    
    var unitID: String?
    var createdDate: Double?
    var unitModel = [ModelObject]()
    var unitVideo = [VideoObject]()
    var unitAudio = [AudioObject]()
    var unitImage = [ImageObject]()
    var unitUrl   = [UrlObject]()
    var unitState = "0"
    var imprintImage: URL?
    var title = ""
    var category = ""
    var note = ""
    
}
