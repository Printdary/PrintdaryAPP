//
//  DetectedUnitView.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 14.06.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import AVFoundation
import GUIPlayerView



class DetectedUnitView: UIView, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    var keyFromServer = "C3WLFnN9wYgMeV91hpZIeU0A4Xi1-LFSNpon7BMd84fJ1ntu"
    static  var model_name: String?
    
    @IBOutlet weak var mediaItemsCollectionView: UICollectionView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var urlImageView: UIImageView!
    @IBOutlet weak var modelImageView: UIImageView!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var audioImageView: UIImageView!
    @IBOutlet weak var imageImageView: UIImageView!
    
    @IBOutlet weak var imprintGoalLabel: UILabel!
    @IBOutlet weak var imprintViewsCountLabel: UILabel!
    @IBOutlet weak var imprintCreatedDateLabel: UILabel!
    @IBOutlet weak var imprintTitleLabel: UILabel!
    @IBOutlet weak var menuCentralButton: UIButton!
    @IBOutlet weak var centralButtonRoundView: UIView!
    @IBOutlet weak var viewsView: UIView!
    @IBOutlet weak var manuView: UIView!
    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var introductionView : UIView!
    @IBOutlet weak var circleImageView: UIImageView!
    
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var modelButton: UIButton!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    
    var videoPlayer : GUIPlayerView?
    lazy var imageView : UIImageView = {
        
        let imageV = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height / 2.6))
        imageV.contentMode = .scaleAspectFit
       
        return imageV
    }()
    
    lazy var playerV : UIView = {
        let playerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height / 2.6))
        return playerView
    }()
    
    lazy var indikator : UIActivityIndicatorView = {
        let actind = UIActivityIndicatorView.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 80))
        actind.activityIndicatorViewStyle = .whiteLarge
        actind.center = self.center
        DispatchQueue.main.async {
            self.addSubview(actind)
            
        }
        return actind
        
    }()
    
    
    lazy var audioView: AudioPlayerView = {
        let audioViewNib = Bundle.main.loadNibNamed("AudioPlayerView", owner: AudioPlayerView(), options: nil)?.first as! AudioPlayerView
        audioViewNib.frame = CGRect.init(x: 0, y: self.frame.size.height - 40 , width: self.frame.size.width, height: 40)
        audioViewNib.backgroundColor = UIColor.init(red: 85, green: 203, blue: 255)
        return audioViewNib
    }()
    
    lazy var webView: WebView = {
        let webViewNib = Bundle.main.loadNibNamed("WebView", owner: WebView(), options: nil)?.first as! WebView
        webViewNib.frame = self.frame
        return webViewNib
    }()
    
    var videoURL: String?
    
    @IBOutlet weak var audioSegmentImageView: UIImageView!
    @IBOutlet weak var urlSegmentImageView: UIImageView!
    @IBOutlet weak var videoSegmentImageView: UIImageView!
    @IBOutlet weak var imageSegmentImageView: UIImageView!
    @IBOutlet weak var modelSegmentImageView: UIImageView!
    var imprintImage: UIImageView?
    var modelName: String?
    var selectedImage: UIImage?
    
    
    var mediaItemsArray = [MediaItem]()
    
    
    override func awakeFromNib() {
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.layer.masksToBounds = true
        
        introductionView.layer.borderWidth = 2
        introductionView.layer.borderColor = UIColor.init(red: 85, green: 203, blue: 255).cgColor
        introductionView.layer.cornerRadius = 10
        notesView.layer.cornerRadius = 10
        notesView.layer.borderWidth = 2
        notesView.layer.borderColor = UIColor.init(red: 85, green: 203, blue: 255).cgColor
        
        emailView.layer.cornerRadius = 10
        emailView.layer.borderWidth = 2
        emailView.layer.borderColor = UIColor.init(red: 85, green: 203, blue: 255).cgColor
        dayView.layer.cornerRadius = 10
        dayView.layer.borderWidth = 2
        dayView.layer.borderColor = UIColor.init(red: 85, green: 203, blue: 255).cgColor
        viewsView.layer.cornerRadius = 10
        viewsView.layer.borderWidth = 2
        viewsView.layer.borderColor = UIColor.init(red: 85, green: 203, blue: 255).cgColor
        manuView.layer.cornerRadius = manuView.frame.size.width / 2
        manuView.layer.borderWidth = 4
        manuView.layer.borderColor = UIColor.init(red: 86, green: 106, blue: 119).cgColor
        manuView.clipsToBounds = true
        centralButtonRoundView.layer.cornerRadius = centralButtonRoundView.frame.size.width / 2
        centralButtonRoundView.layer.borderWidth = 2
        centralButtonRoundView.layer.borderColor = UIColor.init(red: 86, green: 106, blue: 119).cgColor
        menuCentralButton.layer.cornerRadius = menuCentralButton.frame.size.width / 2
     
        mediaItemsCollectionView.isHidden = true
        self.modelSegmentImageView.isHidden = true
        self.imageSegmentImageView.isHidden = true
        self.audioSegmentImageView.isHidden = true
        self.videoSegmentImageView.isHidden = true
        self.urlSegmentImageView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRotateView(info:)), name: Notification.Name.init("Did_rotate"), object: nil)
        
        
        mediaItemsCollectionView.register(UINib.init(nibName: "MediaItemsCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "cell")
        mediaItemsCollectionView.delegate = self
        mediaItemsCollectionView.dataSource = self
        let layout = mediaItemsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: 40, height: 40)
        
    }
    
    @objc func didRotateView(info: Notification){
        let userInfo = info.userInfo
        DispatchQueue.main.async {
            let size = userInfo!["size"] as! CGSize
            if size.height < size.width {
                self.imageView.frame =  CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
                if (self.selectedImage != nil) {
                self.imageView.image = self.selectedImage
                self.imageView.setNeedsDisplay()
                }
                
                self.videoPlayer?.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
                self.videoPlayer?.prepareAndPlayAutomatically(true)
                
                
                
            }else{
                
                self.imageView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height / 2.6)
                if (self.selectedImage != nil) {
                self.imageView.image = self.selectedImage
                self.imageView.setNeedsDisplay()
                }
                self.videoPlayer?.stop()
                self.videoPlayer?.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height / 2.6)
                self.videoPlayer?.prepareAndPlayAutomatically(true)
            }
        }
       
       
    }
    

    //kZYLgbwvWcUZI7cRa4XTLqFyJzS2-LDqlUiFVyPGtCz3OSrl-LDqlUiGRuySCEzKNY0U-LDrlPofd7mWp6ynMTtU
     func configureUnit() {
        if let tag =  UserDefaults.standard.value(forKey: "Tag") as? String {
            keyFromServer = tag
            UserDefaults.standard.set(nil, forKey: "Tag")
        }else {
            if let id = UserDefaults.standard.value(forKey: "unitID"){
                
                let str = "\((Auth.auth().currentUser?.uid)!)\(id)"
                keyFromServer = str
            }
        }
        if keyFromServer.characters.count <  48{
            return
        }
        let userID = keyFromServer[...27]
        let unitID = keyFromServer[28 ... 47]
        getImprintOwnerImage(userId: String(userID), topicId: nil, chapterId: nil, unitId: String(unitID))
        getImprintGoalAndTitle(userId: String(userID), topicId: nil, chapterId: nil, unitId: String(unitID), type: "Title", complatition: { (val) in
            DispatchQueue.main.async {
                self.imprintTitleLabel.text = val
            }
        })
        
        self.diselectButtons()
        
        getImprintGoalAndTitle(userId: String(userID), topicId:nil, chapterId: nil, unitId: String(unitID), type: "Note", complatition: { (val) in
            DispatchQueue.main.async {
                self.imprintGoalLabel.text = val
            }
        })
        
        getImprintGoalAndTitle(userId: String(userID), topicId:nil, chapterId: nil, unitId: String(unitID), type: "CreatedDate", complatition: { (val) in
            DispatchQueue.main.async {
                self.imprintCreatedDateLabel.text = val
            }
            
        })
        getImprintGoalAndTitle(userId: String(userID), topicId:nil, chapterId: nil, unitId: String(unitID), type: "Views", complatition: { (val) in
                DispatchQueue.main.async {
                    self.imprintViewsCountLabel.text = val
                }
            
        })

        self.checkUnitMediafiles()
        addViewForUnit(unitId: String(unitID), userID: String(userID))
        
        
    }
    
    func diselectButtons(){
        imageImageView.alpha = 0.5
        videoImageView.alpha = 0.5
        urlImageView.alpha = 0.5
        modelImageView.alpha = 0.5
        audioImageView.alpha = 0.5
        
        imageButton.isEnabled = false
        videoButton.isEnabled = false
        urlButton.isEnabled = false
        modelButton.isEnabled = false
        audioButton.isEnabled = false
    }
    
    
    func addViewForUnit(unitId: String, userID: String){
        Database.database().reference().child("User").child(userID).child("Units").child(unitId).child("Views").child((Auth.auth().currentUser?.uid)!).updateChildValues(["viewedUserId" : (Auth.auth().currentUser?.uid)!])
    }
    
    
    func menuButtonClicked(sender: UIButton){
        self.modelSegmentImageView.isHidden = true
        self.imageSegmentImageView.isHidden = true
        self.audioSegmentImageView.isHidden = true
        self.videoSegmentImageView.isHidden = true
        self.urlSegmentImageView.isHidden   = true
        imageButton.tag = 0
        modelButton.tag = 0
        urlButton.tag = 0
        audioButton.tag = 0
        videoButton.tag = 0
        sender.tag = 1
         videoPlayer?.stop()
        imageView.removeFromSuperview()
        playerV.removeFromSuperview()
        audioView.removeFromSuperview()
        mediaItemsCollectionView.isHidden = true
        self.blurView.alpha = 1
        userImageView.isHidden = true
        DispatchQueue.main.async {
            self.menuCentralButton.setTitle("", for: .normal)
            self.menuCentralButton.setImage(UIImage.init(named: "homeIcon"), for: .normal)
            self.menuCentralButton.tag = 3
        }
       
        
    }
    
    
    @IBAction func videoButtonAction(_ sender: UIButton) {
        
        if sender.tag == 0 {
            menuButtonClicked(sender: sender)
            videoSegmentImageView.isHidden = false
            emailView.isHidden = true
            dayView.isHidden = true
            viewsView.isHidden = true
            imprintImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height / 2.6))
            self.addSubview(imprintImage!)
            self.getValuesFromFirebase(type: "VideoFiles")
            return
        }
    }
    
    
    @IBAction func modelButtonAction(_ sender: UIButton) {
         AppUtility.lockOrientation(.portrait)
        if sender.tag == 0 {
            menuButtonClicked(sender: sender)
            self.modelSegmentImageView.isHidden = false
            self.getValuesFromFirebase(type: "Models")
            return
        }
    
    }
    
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
         AppUtility.lockOrientation(.portrait)
        if self.menuCentralButton.tag == 1 {
           // self.menuCentralButton.setTitle("X", for: .normal)
            self.menuCentralButton.tag = 3
            self.imageView.removeFromSuperview()
            self.videoPlayer?.stop()
            self.videoPlayer?.removeFromSuperview()
            return
        }
        if self.menuCentralButton.tag == 3 {
            DispatchQueue.main.async {
               self.menuCentralButton.setImage(nil, for: .normal)
                self.menuCentralButton.setTitle("X", for: .normal)
                self.menuCentralButton.tag = 0
                self.playerV.removeFromSuperview()
                self.audioView.removeFromSuperview()
                self.blurView.alpha = 0
                self.dayView.isHidden = false
                self.viewsView.isHidden = false
                self.modelSegmentImageView.isHidden = true
                self.imageSegmentImageView.isHidden = true
                self.audioSegmentImageView.isHidden = true
                self.videoSegmentImageView.isHidden = true
                self.urlSegmentImageView.isHidden   = true
                self.imageButton.tag = 0
                self.modelButton.tag = 0
                self.urlButton.tag = 0
                self.audioButton.tag = 0
                self.videoButton.tag = 0
                self.videoPlayer?.stop()
                self.mediaItemsCollectionView.isHidden = true
                
            }
          
        
            
           return
        }
        self.audioView.ezPlayer?.pause()
        self.videoPlayer?.stop()
       
        UserDefaults.standard.set(nil, forKey: "unitID")
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init("Did_rotate"), object: nil)
        NotificationCenter.default.post(name: Notification.Name.init("RESTART_SESSION"), object: nil, userInfo: nil)
         self.removeFromSuperview()
    }
    
    
    
    @IBAction func urlButtonPressed(_ sender: UIButton) {
         AppUtility.lockOrientation(.portrait)
        if sender.tag == 0 {
            menuButtonClicked(sender: sender)
            urlSegmentImageView.isHidden = false
            emailView.isHidden = true
            dayView.isHidden = true
            viewsView.isHidden = true
            imprintImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height / 2.6))
            self.addSubview(imprintImage!)
            self.getValuesFromFirebase(type: "URLs")
            return
        }

    }
    
    
    
    @IBAction func audioButtonPressed(_ sender: UIButton) {
        AppUtility.lockOrientation(.portrait)
        if sender.tag == 0 {
            menuButtonClicked(sender: sender)
            audioSegmentImageView.isHidden = false
            emailView.isHidden = true
            dayView.isHidden = true
            viewsView.isHidden = true
            imprintImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height / 2.6))
            self.addSubview(imprintImage!)
            self.getValuesFromFirebase(type: "AudioFiles")
            return
        }
        

    }
    
    @IBAction func imageButtonPressed(_ sender: UIButton) {
          AppUtility.lockOrientation(.portrait)
        if sender.tag == 0 {
            menuButtonClicked(sender: sender)
            self.imageSegmentImageView.isHidden = false
            emailView.isHidden = true
            dayView.isHidden = true
            viewsView.isHidden = true
            imprintImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height / 2.6))
            self.addSubview(imprintImage!)
            self.getValuesFromFirebase(type: "Photos")
            return
        }

    }
    
    func checkUnitMediafiles(){
        indikator.startAnimating()
        let userID = keyFromServer[...27]
        let unitID = keyFromServer[28 ... 47]
        Database.database().reference().child("User").child(String(userID)).child("Units").child(String(unitID)).observe(.value) { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject]{
                for (key, _ ) in dict {
                    if key == "Photos" {
                        self.imageImageView.alpha = 1
                        self.imageButton.isEnabled = true
                    }
                    if key == "VideoFiles" {
                        self.videoImageView.alpha = 1
                        self.videoButton.isEnabled = true
                    }
                    if key == "AudioFiles" {
                        self.audioImageView.alpha = 1
                        self.audioButton.isEnabled = true
                    }
                    if key == "URLs" {
                        self.urlImageView.alpha = 1
                        self.urlButton.isEnabled = true
                    }
                    if key == "Models" {
                        self.modelImageView.alpha = 1
                        self.modelButton.isEnabled = true
                    }
                    
                }
                self.indikator.stopAnimating()
            }
            
        }
    }
    
    
    func getValuesFromFirebase(type: String){
        mediaItemsArray.removeAll()
        self.menuCentralButton.setTitle("X", for: .normal)
        self.menuCentralButton.tag = 0
        let userID = keyFromServer[...27]
        let unitID = keyFromServer[28 ... 47]
        _ = Database.database().reference().child("User").child(String(userID)).child("Units").child(String(unitID)).child(type).observe(.value) { (snapshot) in
            if let dict = snapshot.value as? NSDictionary{
                for (key, _ ) in dict {
                    let mediaItem = MediaItem()
                    let newDict = dict[key] as? [String: Any]
                    let url = newDict!["dawnloadURL"]
                    if type == "Photos" {
                        mediaItem.mediaUrl = url as! String
                        mediaItem.type = type
                        self.mediaItemsArray.append(mediaItem)
                    }
                    if type == "VideoFiles" {
                        mediaItem.mediaUrl = url as! String
                        mediaItem.type = type
                        self.mediaItemsArray.append(mediaItem)
                    }
                    if type == "AudioFiles" {
                        mediaItem.mediaUrl = url as! String
                        mediaItem.type = type
                        self.mediaItemsArray.append(mediaItem)
                    }
                    if type == "URLs" {
                        mediaItem.mediaUrl = url as! String
                        mediaItem.type = type
                        self.mediaItemsArray.append(mediaItem)
                    }
                    if type == "Models" {
                        mediaItem.mediaUrl = url as! String
                        mediaItem.type = type
                        self.mediaItemsArray.append(mediaItem)
                    }
                    
                }
                self.mediaItemsCollectionView.reloadData()
            }
            
        }
    }
    
    
    func getImprintOwnerImage(userId: String, topicId: String?, chapterId: String?, unitId: String) {
        
        DispatchQueue.global(qos: .background).async {
            
            Database.database().reference().child("User").child(String(userId)).observeSingleEvent(of: .value) { (snapshot) in
                if let dict = snapshot.value as? [String : AnyObject] {
                    let urlString = dict["imageURL"] as? String
                    let imageUrl = URL.init(string: urlString!)
                    do {
                        let imageData = try Data.init(contentsOf: imageUrl!)
                        let image = UIImage.init(data: imageData)
                        DispatchQueue.main.async {
                            self.userImageView.image = image
                        }
                        
                    }catch let error {
                        print(error.localizedDescription)
                    }
                    
                }
            }
        }
        
    }
    
    func getImprintGoalAndTitle(userId: String, topicId: String?, chapterId: String?, unitId: String, type: String, complatition:@escaping (_ value: String)-> Void) {
        DispatchQueue.global(qos: .background).async {
            Database.database().reference().child("User").child(String(userId)).child("Units").child(String(unitId)).child(type).observe(.value) { (snapshot) in
                if type == "CreatedDate" {
                    if let val = snapshot.value as? String {
                         complatition(val )
                    }
                    return
                }
                if let dict = snapshot.value as? [String : AnyObject] {
                    if type == "Views" {
                        complatition(String.init(dict.keys.count) )
                        return
                    }
                   
                    for key in dict.keys {
                        if let dictValue = dict[key] as? [String : AnyObject] {
                            let title = dictValue[type]
                            complatition(title as! String)
                        }
                    }
                    
                }
            }
        }
    }
    
    
    

    
    
 
 

    

    
    
   
    
    @objc func playPauseButtonAction(sender: UIButton){
        if sender.tag == 0 {
            videoPlayer?.pause()
            sender.tag = 1
            return
        }
        videoPlayer?.play()
        sender.tag = 0
    }
    
    
    func getModel(modelID: String){
        Database.database().reference().child("ModelURL").child(modelID).observe(.value) { (snapshot) in
            print(snapshot.value ?? "")
            if let dict = snapshot.value as? NSDictionary{
                for (key, _ ) in dict {
                    let newDict = dict[key] as? [String: String]
                    let name = newDict!["dawnloadURL"]
                    self.modelName = name!
                    UserDefaults.standard.set(name, forKey: "modelName")
                    let name1 = name?.replacingOccurrences(of: " ", with: "_")
                    let urlStr = "http://ec2-18-188-59-112.us-east-2.compute.amazonaws.com/models/\(name1!)/\(name1!).jpg"
                    let url = URL.init(string: urlStr)
                    DispatchQueue.global().async {
                        do {
                            
                            if (url != nil) {
                                let data = try Data.init(contentsOf: url!)
                                let img = UIImage.init(data: data)
                                DispatchQueue.main.async {
                                    self.circleImageView.image = img
                                }
                            }
                            
                            
                        }catch let _{
                            print("load error")
                        }
                        
                    }
                    break
                }
                
            }
        }
    }
    
    
    
    
    
    @objc func moveNextVc(){
        self.removeFromSuperview()
        NotificationCenter.default.post(name: Notification.Name.init("DID_SELECT_MODEL"), object: nil, userInfo: nil)
   
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let mediaItem = mediaItemsArray[indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath) as! MediaItemsCollectionViewCell
        
        if mediaItem.type == "Photos" {
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = UIColor.white
            DispatchQueue.main.async {
                self.imageView.image = cell.itemImageView.image?.rotate(radians: CGFloat(M_PI_2))
                self.selectedImage = self.imageView.image
            }
            self.menuCentralButton.tag = 1
            self.addSubview(imageView)
            AppUtility.lockOrientation(.all)
            return
        }
        if mediaItem.type == "VideoFiles" {
            if let url = URL.init(string: mediaItem.mediaUrl!) as? URL {
                videoPlayer = GUIPlayerView.init(frame: playerV.frame)
                videoPlayer?.videoURL = url
                videoPlayer?.prepareAndPlayAutomatically(true)
                let playButton = UIButton.init(frame: (videoPlayer?.frame)!)
                playButton.addTarget(self, action: #selector(playPauseButtonAction(sender:)), for: .touchUpInside)
                videoPlayer?.addSubview(playButton)
                playerV.addSubview(videoPlayer!)
                self.addSubview(playerV)
            }
            self.menuCentralButton.tag = 1
            AppUtility.lockOrientation(.all)
            return
        }
        if mediaItem.type == "AudioFiles" {
            if let url = URL.init(string: mediaItem.mediaUrl!) as? URL {
                let audoObj = AudioObject()
                audoObj.audioURL = url
                audoObj.key = ""
                audioView.audioObj = audoObj
                self.addSubview(audioView)
            }
            return
        }
        if mediaItem.type == "URLs" {
            if let url = URL.init(string: mediaItem.mediaUrl!) as? URL {
                webView.webUrl = url
                webView.loadUrl()
                self.addSubview(webView)
            }
            return
        }
        if mediaItem.type == "Models" {
            DetectedUnitView.model_name = mediaItem.mediaUrl!
            self.perform(#selector(moveNextVc))
           return
        }
        
 
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaItemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MediaItemsCollectionViewCell
        cell.mediaItem = mediaItemsArray[indexPath.row]
        cell.configur()
        cell.rootView = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = 40 * mediaItemsArray.count
        let totalSpacingWidth = 30 * (mediaItemsArray.count - 1)
        
        let leftInset = ((self.frame.width * 0.8) - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
    }
   
    
}

extension UIColor {
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}




extension StringProtocol where IndexDistance == Int {
    func index(at offset: Int, from start: Index? = nil) -> Index? {
        return index(start ?? startIndex, offsetBy: offset, limitedBy: endIndex)
    }
    func character(at offset: Int) -> Character? {
        precondition(offset >= 0, "offset can't be negative")
        guard let index = index(at: offset) else { return nil }
        return self[index]
    }
    subscript(_ range: CountableRange<Int>) -> SubSequence {
        precondition(range.lowerBound >= 0, "lowerBound can't be negative")
        let start = index(at: range.lowerBound) ?? endIndex
        let end = index(at: range.count, from: start) ?? endIndex
        return self[start..<end]
    }
    subscript(_ range: CountableClosedRange<Int>) -> SubSequence {
        precondition(range.lowerBound >= 0, "lowerBound can't be negative")
        let start = index(at: range.lowerBound) ?? endIndex
        let end = index(at: range.count, from: start) ?? endIndex
        return self[start..<end]
    }
    subscript(_ range: PartialRangeUpTo<Int>) -> SubSequence {
        return prefix(range.upperBound)
    }
    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence {
        return prefix(range.upperBound+1)
    }
    subscript(_ range: PartialRangeFrom<Int>) -> SubSequence {
        return suffix(Swift.max(0,count-range.lowerBound))
    }
}
extension Substring {
    var string: String { return String(self) }
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.x, y: -origin.y, width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}

class  MediaItem : NSObject {
    var mediaUrl: String?
    var type: String?
}

