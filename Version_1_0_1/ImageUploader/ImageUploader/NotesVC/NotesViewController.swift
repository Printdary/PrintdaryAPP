//
//  NotesViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 05.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import AVFoundation
import GUIPlayerView



class NotesViewController: UIViewController {
    
    var keyFromServer = "kZYLgbwvWcUZI7cRa4XTLqFyJzS2/-LDqlUiFVyPGtCz3OSrl/-LDqlUiGRuySCEzKNY0U/-LDqlWytqQSNfhbvLx3_"
    
    
    @IBOutlet weak var urlImageView: UIImageView!
    @IBOutlet weak var modelImageView: UIImageView!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var audioImageView: UIImageView!
    @IBOutlet weak var imageImageView: UIImageView!
    
    @IBOutlet weak var imprintGoalLabel: UILabel!
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
    let imageV = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height / 2.6))
        return imageV
    }()
    
 lazy var playerV : UIView = {
    let playerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height / 2.6))
    
    return playerView
}()
    
    lazy var indikator : UIActivityIndicatorView = {
        let actind = UIActivityIndicatorView.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 80))
        actind.activityIndicatorViewStyle = .whiteLarge
        actind.center = self.view.center
        DispatchQueue.main.async {
            self.view.addSubview(actind)
            
        }
        return actind
        
    }()
    
    
    lazy var audioView: AudioPlayerView = {
        let audioViewNib = Bundle.main.loadNibNamed("AudioPlayerView", owner: AudioPlayerView(), options: nil)?.first as! AudioPlayerView
        audioViewNib.frame = CGRect.init(x: 0, y: self.view.frame.size.height - 40 , width: self.view.frame.size.width, height: 40)
        audioViewNib.backgroundColor = UIColor.init(red: 85, green: 203, blue: 255)
        return audioViewNib
    }()
    
    lazy var webView: WebView = {
        let webViewNib = Bundle.main.loadNibNamed("WebView", owner: WebView(), options: nil)?.first as! WebView
        webViewNib.frame = self.view.frame
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
   // static  var model_name: String?
    
    
    
    override func viewDidLoad() {
        
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
        circleImageView.layer.cornerRadius = circleImageView.frame.size.width / 2
        circleImageView.layer.borderWidth = 2
        circleImageView.layer.borderColor = UIColor.red.cgColor
        circleImageView.layer.masksToBounds = true
        circleImageView.isHidden = true
        circleImageView.backgroundColor = UIColor.white
        
        self.modelSegmentImageView.isHidden = true
        self.imageSegmentImageView.isHidden = true
        self.audioSegmentImageView.isHidden = true
        self.videoSegmentImageView.isHidden = true
        self.urlSegmentImageView.isHidden = true
        
       // getModel(modelID: "-LCsCHpmzM0oMSIME-mf")
        
    }
    //kZYLgbwvWcUZI7cRa4XTLqFyJzS2-LDqlUiFVyPGtCz3OSrl-LDqlUiGRuySCEzKNY0U-LDrlPofd7mWp6ynMTtU
    override func viewWillAppear(_ animated: Bool) {
        if let tag =  UserDefaults.standard.value(forKey: "Tag") as? String {
        keyFromServer = tag
        UserDefaults.standard.set(nil, forKey: "Tag")
        }else {
            if let id = UserDefaults.standard.value(forKey: "unitID"){
               UserDefaults.standard.set(nil, forKey: "unitID")
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
        
        self.checkUnitMediafiles()
        addViewForUnit(unitId: String(unitID))
        
        
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
    
    
    func addViewForUnit(unitId: String){
        Database.database().reference().child("Views").child(unitId).child((Auth.auth().currentUser?.uid)!).updateChildValues(["viewedUserId" : (Auth.auth().currentUser?.uid)!])
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
 
    @IBAction func videoButtonAction(_ sender: UIButton) {
        self.modelSegmentImageView.isHidden = true
        self.imageSegmentImageView.isHidden = true
        self.audioSegmentImageView.isHidden = true
        self.videoSegmentImageView.isHidden = true
        self.urlSegmentImageView.isHidden = true
        
        imageButton.tag = 0
        modelButton.tag = 0
        urlButton.tag = 0
        audioButton.tag = 0
        videoPlayer?.stop()
        imageView.removeFromSuperview()
        playerV.removeFromSuperview()
        audioView.removeFromSuperview()
        self.circleImageView.image = nil
        
        if sender.tag == 0 {
            sender.tag = 1
            videoSegmentImageView.isHidden = false
            circleImageView.isHidden = false
            emailView.isHidden = true
            dayView.isHidden = true
            viewsView.isHidden = true
            self.view.backgroundColor = UIColor.init(red: 0, green: 166, blue: 255, alpha: 0.51)
            self.view.backgroundColor = UIColor.hexStringToUIColor(hex: "#00A6FF")
            imprintImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height / 2.6))
            self.view.addSubview(imprintImage!)
            self.getValuesFromFirebase(type: "VideoFiles")
            return
        }
        sender.tag = 0
        circleImageView.isHidden = true
        emailView.isHidden = false
        dayView.isHidden = false
        viewsView.isHidden = false
        self.view.backgroundColor = UIColor.white
        imprintImage?.removeFromSuperview()
    }
    
    
    @IBAction func modelButtonAction(_ sender: UIButton) {
        self.modelSegmentImageView.isHidden = true
        self.imageSegmentImageView.isHidden = true
        self.audioSegmentImageView.isHidden = true
        self.videoSegmentImageView.isHidden = true
        self.urlSegmentImageView.isHidden = true
        videoPlayer?.stop()
        imageView.removeFromSuperview()
        playerV.removeFromSuperview()
        audioView.removeFromSuperview()
        imageButton.tag = 0
        videoButton.tag = 0
        urlButton.tag = 0
        audioButton.tag = 0
        self.circleImageView.image = nil
        if sender.tag == 0 {
            sender.tag = 1
            self.modelSegmentImageView.isHidden = false
            circleImageView.isHidden = false
            self.getValuesFromFirebase(type: "Models")
            return
        }
         self.modelSegmentImageView.isHidden = true
         circleImageView.isHidden = true
         sender.tag = 0
    }
    
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        if self.menuCentralButton.tag == 1 {
        self.menuCentralButton.setTitle("X", for: .normal)
        self.menuCentralButton.tag = 0
            self.imageView.removeFromSuperview()
            self.videoPlayer?.stop()
            self.videoPlayer?.removeFromSuperview()
         return
        }
        self.audioView.ezPlayer?.pause()
        self.videoPlayer?.stop()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func urlButtonPressed(_ sender: UIButton) {
        imageButton.tag = 0
        videoButton.tag = 0
        modelButton.tag = 0
        audioButton.tag = 0
        self.circleImageView.image = nil
        self.imageSegmentImageView.isHidden = true
        videoPlayer?.stop()
        imageView.removeFromSuperview()
        playerV.removeFromSuperview()
        audioView.removeFromSuperview()
        
        
        self.modelSegmentImageView.isHidden = true
        self.imageSegmentImageView.isHidden = true
        self.audioSegmentImageView.isHidden = true
        self.videoSegmentImageView.isHidden = true
        self.urlSegmentImageView.isHidden = true
        
        if sender.tag == 0 {
            sender.tag = 1
            urlSegmentImageView.isHidden = false
            circleImageView.isHidden = false
            emailView.isHidden = true
            dayView.isHidden = true
            viewsView.isHidden = true
            self.view.backgroundColor = UIColor.init(red: 0, green: 166, blue: 255, alpha: 0.51)
            self.view.backgroundColor = UIColor.hexStringToUIColor(hex: "#00A6FF")
            imprintImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height / 2.6))
            self.view.addSubview(imprintImage!)
            self.circleImageView.tag = 2
            self.getValuesFromFirebase(type: "URLs")
            return
        }
        sender.tag = 0
        circleImageView.isHidden = true
        emailView.isHidden = false
        dayView.isHidden = false
        viewsView.isHidden = false
        self.view.backgroundColor = UIColor.white
        imprintImage?.removeFromSuperview()
        
        
    }
    
    
    
    @IBAction func audioButtonPressed(_ sender: UIButton) {
        imageButton.tag = 0
        videoButton.tag = 0
        urlButton.tag = 0
        modelButton.tag = 0
        self.circleImageView.image = nil
        videoPlayer?.stop()
        imageView.removeFromSuperview()
        playerV.removeFromSuperview()
        audioView.removeFromSuperview()
        self.modelSegmentImageView.isHidden = true
        self.imageSegmentImageView.isHidden = true
        self.audioSegmentImageView.isHidden = true
        self.videoSegmentImageView.isHidden = true
        self.urlSegmentImageView.isHidden = true
        
        if sender.tag == 0 {
            sender.tag = 1
            audioSegmentImageView.isHidden = false
            circleImageView.isHidden = false
            emailView.isHidden = true
            dayView.isHidden = true
            viewsView.isHidden = true
            self.view.backgroundColor = UIColor.init(red: 0, green: 166, blue: 255, alpha: 0.51)
            self.view.backgroundColor = UIColor.hexStringToUIColor(hex: "#00A6FF")
            imprintImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height / 2.6))
            self.view.addSubview(imprintImage!)
            self.circleImageView.tag = 2
            self.getValuesFromFirebase(type: "AudioFiles")
            return
        }
       
        sender.tag = 0
        circleImageView.isHidden = true
        emailView.isHidden = false
        dayView.isHidden = false
        viewsView.isHidden = false
        self.view.backgroundColor = UIColor.white
        imprintImage?.removeFromSuperview()
    
    }
    
    @IBAction func imageButtonPressed(_ sender: UIButton) {
       
        videoButton.tag = 0
        urlButton.tag = 0
        audioButton.tag = 0
        modelButton.tag = 0
        videoPlayer?.stop()
        imageView.removeFromSuperview()
        playerV.removeFromSuperview()
        audioView.removeFromSuperview()
        self.circleImageView.image = nil
        
        self.modelSegmentImageView.isHidden = true
        self.imageSegmentImageView.isHidden = true
        self.audioSegmentImageView.isHidden = true
        self.videoSegmentImageView.isHidden = true
        self.urlSegmentImageView.isHidden = true
        
        if sender.tag == 0 {
            sender.tag = 1
            self.imageSegmentImageView.isHidden = false
            circleImageView.isHidden = false
            emailView.isHidden = true
            dayView.isHidden = true
            viewsView.isHidden = true
            self.view.backgroundColor = UIColor.init(red: 0, green: 166, blue: 255, alpha: 0.51)
            self.view.backgroundColor = UIColor.hexStringToUIColor(hex: "#00A6FF")
            imprintImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height / 2.6))
            self.view.addSubview(imprintImage!)
            self.circleImageView.tag = 2
            self.getValuesFromFirebase(type: "Photos")
            return
        }
       
        sender.tag = 0
        circleImageView.isHidden = true
        emailView.isHidden = false
        dayView.isHidden = false
        viewsView.isHidden = false
        self.view.backgroundColor = UIColor.white
        imprintImage?.removeFromSuperview()
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
        self.menuCentralButton.setTitle("X", for: .normal)
        self.menuCentralButton.tag = 0
        indikator.startAnimating()
        let userID = keyFromServer[...27]
        let unitID = keyFromServer[28 ... 47]
        _ = Database.database().reference().child("User").child(String(userID)).child("Units").child(String(unitID)).child(type).observe(.value) { (snapshot) in
            if let dict = snapshot.value as? NSDictionary{
                for (key, _ ) in dict {
                    let newDict = dict[key] as? [String: Any]
                    let url = newDict!["dawnloadURL"]
                    if type == "Photos" {
                        self.dawnloadImagesFromServer(imageUrl: url! as! String)
                    }
                    if type == "VideoFiles" {
                        self.videoURL = url as! String
                        self.dawnloadVideoFromServer(imageUrl: url! as! String)
                    }
                    if type == "AudioFiles" {
                        self.videoURL = url as! String
                        self.dawnloadAudioFromServer()
                    }
                    if type == "URLs" {
                        self.videoURL = url as! String
                        self.dawnloadUrlFromServer()
                    }
                    if type == "Models" {
                        self.videoURL = url as! String
                        self.dawnloadModelFromServer(imageUrl: url! as! String)
                    }
                    break
                }
                
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
                  if let dict = snapshot.value as? [String : AnyObject] {
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
    
    
    
    func dawnloadModelFromServer(imageUrl: String){
       
                    DispatchQueue.main.async {
                        self.circleImageView.image = UIImage.init(named: "\(imageUrl).jpg")
                        self.circleImageView.tag = 5
                        self.indikator.stopAnimating()
        }
        
    }
    
    
    func dawnloadAudioFromServer(){
        DispatchQueue.main.async {
            self.circleImageView.image = UIImage.init(named: "Musiconenote2")
            self.circleImageView.tag = 3
            self.indikator.stopAnimating()
        }
    }
    func dawnloadUrlFromServer(){
        if let url = URL.init(string: "\(self.videoURL!)/favicon.ico") {
            DispatchQueue.global(qos: .background).async {
                do {
                    let data = try Data.init(contentsOf: url)
                    let image = UIImage.init(data: data)
                    DispatchQueue.main.async {
                        self.circleImageView.image = image
                        self.circleImageView.clipsToBounds = true
                        self.circleImageView.tag = 4
                        self.indikator.stopAnimating()
                    }
                    
                }catch let error {
                    DispatchQueue.main.async {
                        self.circleImageView.clipsToBounds = true
                        self.circleImageView.image = UIImage.init(named: "eIcon")
                        self.circleImageView.tag = 4
                        self.indikator.stopAnimating()
                    }
                    print(error.localizedDescription)
                }
            }
        }
       
    }
    
    func dawnloadVideoFromServer(imageUrl: String){
        
        if let url = URL.init(string: imageUrl) as? URL {
            if let image  = self.getThumbnailImage(forUrl: url) as? UIImage {
            DispatchQueue.main.async {
                self.circleImageView.image = image
                self.circleImageView.tag = 2
                self.indikator.stopAnimating()
            }
        }
        }
    }
    
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    func dawnloadImagesFromServer(imageUrl: String){
        let actind = UIActivityIndicatorView.init(frame: CGRect.init(x: 0, y: 0, width: 20, height: 20))
        actind.activityIndicatorViewStyle = .gray
        actind.center = circleImageView.center
        DispatchQueue.main.async {
            self.circleImageView.addSubview(actind)
             actind.startAnimating()
        }
        if let url = URL.init(string: imageUrl) as? URL {
            do {
            let data = try Data.init(contentsOf: url)
                if let image = UIImage.init(data: data) as? UIImage {
                    DispatchQueue.main.async {
                        self.circleImageView.image = image
                        self.circleImageView.contentMode = .scaleAspectFill
                        self.circleImageView.tag = 1
                        self.indikator.stopAnimating()
                    }
                    
                }
            }catch _ {
                print("error")
            }
        }
        
        
    }
    
    
    @IBAction func selectObjectButtonAction(_ sender: UIButton) {
        if self.circleImageView.tag == 1 {
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = UIColor.white
            let img = self.circleImageView.image?.rotate(radians: CGFloat(M_PI_2))
            DispatchQueue.main.async {
                self.imageView.image = img
            }
            self.menuCentralButton.setTitle("O", for: .normal)
            self.menuCentralButton.tag = 1
            self.view.addSubview(imageView)
            return
        }
        
        if self.circleImageView.tag == 2 {
            if let url = URL.init(string: self.videoURL!) as? URL {
            videoPlayer = GUIPlayerView.init(frame: playerV.frame)
            videoPlayer?.videoURL = url
            videoPlayer?.prepareAndPlayAutomatically(true)
            let playButton = UIButton.init(frame: (videoPlayer?.frame)!)
                playButton.addTarget(self, action: #selector(playPauseButtonAction(sender:)), for: .touchUpInside)
            videoPlayer?.addSubview(playButton)
            playerV.addSubview(videoPlayer!)
            self.view.addSubview(playerV)
            }
            self.menuCentralButton.setTitle("O", for: .normal)
            self.menuCentralButton.tag = 1
            return
        }
        
        if self.circleImageView.tag == 3 {
            if let url = URL.init(string: self.videoURL!) as? URL {
                let audoObj = AudioObject()
                audoObj.audioURL = url
                audoObj.key = ""
                audioView.audioObj = audoObj
                self.view.addSubview(audioView)
            }
            return
        }
        if self.circleImageView.tag == 4 {
            if let url = URL.init(string: self.videoURL!) as? URL {
                webView.webUrl = url
                webView.loadUrl()
                self.view.addSubview(webView)
            }
            return
        }
        if self.circleImageView.tag == 5 {
           //  NotesViewController.model_name = self.videoURL!
             self.perform(#selector(moveNextVc))
            return
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
        self.performSegue(withIdentifier: "showModel", sender: nil)
    }
    
    
}











