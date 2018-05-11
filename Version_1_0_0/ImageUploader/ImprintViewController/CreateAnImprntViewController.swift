//
//  CreateAnImprntViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 09.04.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class CreateAnImprntViewController: UIViewController {
    
    @IBOutlet weak var mbaseView: UIView!
    @IBOutlet weak var dawnloadIcon: UIImageView!
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var cameraImageView: UIView!
    @IBOutlet weak var cameraImage: UIImageView!
    
    @IBOutlet weak var micraphonImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var foldetTextField: UITextField!
    
    @IBOutlet weak var notesView: UIView!
    
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var imageViewBaseView: UIView!
    @IBOutlet weak var videoViewBaseView: UIView!
    @IBOutlet weak var D3ModelBaseView: UIView!
    @IBOutlet weak var urlBaseView: UIView!
    
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    var audioRecordingArry = [AudioObject]()
    var photosArry = [UIImage]()
    var videosArray = [UIImage]()
    var modelsArray = [UIImage]()
    var actInd: UIActivityIndicatorView?
    
    
    @IBOutlet weak var audioViewHeightConstraint: NSLayoutConstraint!
   
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var videoViewHeughtConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var modelViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var urlViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var videoCollectionView: UICollectionView!
    
    @IBOutlet weak var modelCollectionView: UICollectionView!
    
    @IBOutlet weak var urlCollectionView: UICollectionView!
    
    @IBOutlet weak var uploadAudioImageView: UIImageView!
    var audioViewConstant : CGFloat?
    
    
    override func viewDidLoad() {
        cameraImageView.layer.cornerRadius = 10
        
        cameraIcon.clipsToBounds = true
        cameraImage.clipsToBounds = true
        dawnloadIcon.clipsToBounds = true
        dawnloadIcon.layer.cornerRadius = 10
        cameraIcon.layer.cornerRadius = 10
        cameraImage.layer.cornerRadius = 10
        dawnloadIcon.layer.maskedCorners = [.layerMaxXMaxYCorner]
        cameraIcon.layer.maskedCorners = [.layerMinXMaxYCorner]
        cameraImage.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        titleTextField.layer.borderColor = UIColor.gray.cgColor
        categoryTextField.layer.borderColor = UIColor.gray.cgColor
        foldetTextField.layer.borderColor = UIColor.gray.cgColor
        
        titleTextField.layer.borderWidth = 1
        categoryTextField.layer.borderWidth = 1
        foldetTextField.layer.borderWidth = 1
        
        titleTextField.layer.cornerRadius = 5
        categoryTextField.layer.cornerRadius = 5
        foldetTextField.layer.cornerRadius = 5
        
        categoryTextField.rightViewMode = .always
        categoryTextField.rightView = UIImageView(image: UIImage(named: "LeftArrow"))
        
        foldetTextField.rightViewMode = .always
        foldetTextField.rightView = UIImageView(image: UIImage(named: "LeftArrow"))
        
        
        notesView.layer.borderWidth = 1
        notesView.layer.borderColor = UIColor.gray.cgColor
        notesView.layer.cornerRadius = 10
        
        audioView.layer.borderWidth = 2
        imageViewBaseView.layer.borderWidth = 2
        videoViewBaseView.layer.borderWidth = 2
        D3ModelBaseView.layer.borderWidth = 2
        urlBaseView.layer.borderWidth = 2
        
        audioView.layer.borderColor = UIColor.black.cgColor
        imageViewBaseView.layer.borderColor = UIColor.black.cgColor
        videoViewBaseView.layer.borderColor = UIColor.black.cgColor
        D3ModelBaseView.layer.borderColor = UIColor.black.cgColor
        urlBaseView.layer.borderColor = UIColor.black.cgColor
        
        audioView.layer.cornerRadius = 20
        imageViewBaseView.layer.cornerRadius = 20
        videoViewBaseView.layer.cornerRadius = 20
        D3ModelBaseView.layer.cornerRadius = 20
        urlBaseView.layer.cornerRadius = 20
        imageCollectionView.isHidden = true
        
        videoCollectionView.isHidden = true
        
        modelCollectionView.isHidden = true
        urlCollectionView.isHidden = true
        audioViewConstant = audioView.frame.size.height
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        
        modelCollectionView.delegate = self
        modelCollectionView.dataSource = self
        let nibName = UINib(nibName: "PhotosCollectionViewCell", bundle:nil)
        imageCollectionView.register(nibName, forCellWithReuseIdentifier: "photosCell")
        modelCollectionView.register(nibName, forCellWithReuseIdentifier: "photosCell")
        
        let nibNameVideo = UINib(nibName: "VideoCollectionViewCell", bundle:nil)
        videoCollectionView.register(nibNameVideo, forCellWithReuseIdentifier: "cell")
        videoCollectionView.delegate = self
        videoCollectionView.dataSource = self
        
        noteTextView.delegate = self
        if let image = CurrentSession.currentSession.croppedImage {
            self.cameraImage.image = image
            self.cameraImage.contentMode = .scaleAspectFill
        }
         CurrentSession.currentSession.croppedImage = nil
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        print("sc = \(self.scrollViewHeightConstraint.constant)")
        self.audioViewHeightConstraint.constant = 0
        adjustScrollView()
    }
    @IBAction func micraphonButtonAction(_ sender: UIButton) {
       
        if UserModel.currentUser.uploadID != "" {
        if sender.tag == 0 {
            sender.tag = 0
            let st = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let vc = st.instantiateViewController(withIdentifier: "AudioRecorder")
            self.present(vc, animated: false, completion: nil)
        }else {
            sender.tag = 0
        }
        }else {
            Helper.showAlertWith(title: "Info", alertMessage: "Please select picture")
        }
    }
    @IBAction func captureImageButtonAction(_ sender: UIButton) {
       if UserModel.currentUser.uploadID != "" {
        let st = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let vc = st.instantiateViewController(withIdentifier: "TackPhotto")
        self.present(vc, animated: false, completion: nil)
       }else {
           Helper.showAlertWith(title: "Info", alertMessage: "Please select picture")
        }
    }
    @IBAction func captureVideoButtonAction(_ sender: UIButton) {
         if UserModel.currentUser.uploadID != "" {
        let videoVC  = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "videoVC") as? VideoRecording
        videoVC?.recordFinishedBlock = { videoURL, image in
            CurrentSession.currentSession.videosArray.append(videoURL!)
            CurrentSession.currentSession.videosImagesArray.append(image!)
        }
        
           self.present(videoVC!, animated: false, completion: nil)
         }else {
             Helper.showAlertWith(title: "Info", alertMessage: "Please select picture")
        }
       
    }
    @IBAction func searchButtonAction(_ sender: UIButton) {
        if UserModel.currentUser.uploadID != "" {
            let searchVC  = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "searchViewController") as? SearchViewController
            self.present(searchVC!, animated: false, completion: nil)
        }
        else {
            Helper.showAlertWith(title: "Info", alertMessage: "Please select picture")
            
        }
    }
    @IBAction func urlButtonAction(_ sender: UIButton) {
        if UserModel.currentUser.uploadID != "" {
            
           
        }
        else {
            Helper.showAlertWith(title: "Info", alertMessage: "Please select picture")
        }
        
    }
    
    @IBAction func uploadAudioButtonAction(_ sender: UIButton) {
    }
    
    
    func getAudioFiles(isExpanded: Bool){
       
        self.audioViewHeightConstraint.constant = 0
        self.audioRecordingArry = [AudioObject]()
        self.audioRecordingArry = CurrentSession.currentSession.audioArray
        self.reloadAudioBaseView(audioArray:self.audioRecordingArry, isExpanded: isExpanded)
    
   }
    
    
    
    func reloadAudioBaseView(audioArray: Array<AudioObject>, isExpanded: Bool){
         DispatchQueue.main.async {
            for vi in self.audioView.subviews {
                if vi.isKind(of: AudioPlayerView.self) {
                    vi.removeFromSuperview()
                }
            }
        if audioArray.count == 0 {
            
        }else{
        for obj in  1...audioArray.count {
            let audioViewNib = Bundle.main.loadNibNamed("AudioPlayerView", owner: AudioPlayerView(), options: nil)?.first as! AudioPlayerView
            audioViewNib.frame = CGRect.init(x: 0, y: CGFloat.init(obj) * self.audioView.frame.size.height , width: self.audioView.frame.size.width, height: self.audioView.frame.size.height)
            audioViewNib.audioObj = audioArray[obj - 1]
            
           audioViewNib.handleDeletButtonPressed = { playerView in
           self.deletAudioFromFirebase(audioObj: playerView.audioObj!,playerView: playerView)
            
           }
           
                self.audioView.addSubview(audioViewNib)
                self.audioViewHeightConstraint.constant = self.audioViewHeightConstraint.constant + self.audioView.frame.size.height
                print("audioViewNib.frame = \( self.audioView.frame.size.height) frame \(audioViewNib.frame) constant \(self.audioViewHeightConstraint.constant)")
                self.scrollViewHeightConstraint.constant = self.scrollViewHeightConstraint.constant + 75
            }
            
            }
           print("sc = \(self.scrollViewHeightConstraint.constant)")
        }
        
        getVideos()
         //self.adjustScrollView()
    }
    
    func adjustScrollView(){
        scrollViewHeightConstraint.constant = 0
       // imageViewHeightConstraint.constant = 0
        getImages()
        
    }
    
    
    func deletAudioFromFirebase(audioObj: AudioObject,playerView: AudioPlayerView ){
      
        let dbRef = Database.database().reference().child("Audio").child(UserModel.currentUser.uploadID).child(audioObj.key!)
        dbRef.removeValue { (error, ref) in
            if error != nil {
                print("opps \(error?.localizedDescription)")
                return
            }
           
            DispatchQueue.main.async {
                playerView.removeFromSuperview()
            }
            if let index = CurrentSession.currentSession.audioArray.index(of:audioObj) {
                CurrentSession.currentSession.audioArray.remove(at: index)
            }
            
            self.adjustScrollView()
        }
    }
    
    func deletImageFromFirebase(imageObj: UIImage,cell: PhotosCollectionViewCell ){

        if let index = CurrentSession.currentSession.imageArray.index(of:imageObj) {
            CurrentSession.currentSession.imageArray.remove(at: index)
        }
        
        self.adjustScrollView()
    }
    
    
    func getImages(){
       // self.imageViewHeightConstraint.constant = 0
        self.photosArry = [UIImage]()
        self.photosArry = CurrentSession.currentSession.imageArray
        self.reloadPhotosView(photosArray: self.photosArry)
    }
    
    func getVideos(){
        self.videosArray = [UIImage]()
        self.videosArray = CurrentSession.currentSession.videosImagesArray
        reloadVideosView(videosArry: self.videosArray)
    }
    
    func getModels(){
        self.modelsArray = [UIImage]()
        self.modelsArray = CurrentSession.currentSession.modelImagesArray
        reloadModelsView(modelsArray: modelsArray)
    }
    
    
    func reloadPhotosView(photosArray: Array<UIImage>){
        if photosArray.count > 0 {
            imageCollectionView.isHidden = false
            if imageViewHeightConstraint.constant == 0 {
                imageViewHeightConstraint.constant = 60
                scrollViewHeightConstraint.constant = scrollViewHeightConstraint.constant + 75
            }
            imageCollectionView.reloadData()
        }else {
            if imageViewHeightConstraint.constant == 60 {
             imageCollectionView.isHidden = true
             imageViewHeightConstraint.constant = 0
             scrollViewHeightConstraint.constant = scrollViewHeightConstraint.constant - 75
             self.view.layoutIfNeeded()
             self.view.layoutSubviews()
            }
        }
         getAudioFiles(isExpanded: true)
         print("sc = \(self.scrollViewHeightConstraint.constant)")
    }
    
    
    func reloadVideosView(videosArry: Array<UIImage>){
        if videosArry.count > 0 {
            videoCollectionView.isHidden = false
            if videoViewHeughtConstraint.constant == 0 {
                videoViewHeughtConstraint.constant = 60
                scrollViewHeightConstraint.constant = scrollViewHeightConstraint.constant + 75
            }
            videoCollectionView.reloadData()
        }else {
            if videoViewHeughtConstraint.constant == 60 {
                videoCollectionView.isHidden = true
                videoViewHeughtConstraint.constant = 0
                scrollViewHeightConstraint.constant = scrollViewHeightConstraint.constant - 75
                self.view.layoutIfNeeded()
                self.view.layoutSubviews()
            }
        }
        getModels()
    }
    
    func reloadModelsView(modelsArray: Array<UIImage>){
        if modelsArray.count > 0 {
            modelCollectionView.isHidden = false
            if modelViewHeightConstraint.constant == 0 {
                modelViewHeightConstraint.constant = 60
                scrollViewHeightConstraint.constant = scrollViewHeightConstraint.constant + 75
            }
            modelCollectionView.reloadData()
        }else {
            if modelViewHeightConstraint.constant == 60 {
                modelCollectionView.isHidden = true
                modelViewHeightConstraint.constant = 0
                scrollViewHeightConstraint.constant = scrollViewHeightConstraint.constant - 65
                self.view.layoutIfNeeded()
                self.view.layoutSubviews()
            }
        }
    }
    
    
    func uploadImageToFirebase(images: [UIImage]){
        
        if images.count == 0 {
          // getImages()
            uploadModelsToFirebase(model: CurrentSession.currentSession.modelUrlArray)
        } else {
            if let imageData = UIImagePNGRepresentation(images[0]){
                let storageRef = Storage.storage().reference().child("tackedImage/\(Date()).png")
                // Upload the file to the path "images/rivers.jpg"
                _ = storageRef.putData(imageData, metadata: nil) { metadata, error in
                    if let error = error {
                        // Uh-oh, an error occurred!
                        Helper.showAlertWith(title: "Error", alertMessage: (error.localizedDescription))
                        self.dismiss(animated: false, completion: nil)
                    } else {
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        let downloadURL = metadata!.downloadURL()
                        self.saveDawnloadUrlToFirebase(downloadURL: downloadURL! as NSURL,complatition: { [unowned self] in
                            CurrentSession.currentSession.imageArray.remove(at: 0)
                            self.uploadImageToFirebase(images: CurrentSession.currentSession.imageArray)
                        })
                    }
                }
            }else {
                Helper.showAlertWith(title: "Error", alertMessage: "Image uploading failed")
            }
    }
    }
    
    func uploadModelsToFirebase(model: [String]){
        
        if model.count == 0 {
            UserModel.currentUser.uploadID = ""
            getModels()
        } else {
                saveModelUrlToFirebase(downloadURL:model[0]) { [unowned self] in
                CurrentSession.currentSession.modelUrlArray.remove(at: 0)
                CurrentSession.currentSession.modelImagesArray.remove(at: 0)
                self.uploadModelsToFirebase(model: CurrentSession.currentSession.modelUrlArray)
            }
        }
        
    }
    
    
    func saveDawnloadUrlToFirebase(downloadURL: NSURL, complatition: ()->Void){
        
        let dbRef = Database.database().reference().child("Photos").child(UserModel.currentUser.uploadID).childByAutoId()
        dbRef.updateChildValues(["dawnloadURL": downloadURL.absoluteString, "userID": UserModel.currentUser.userID])
        complatition()
        
    }

    func saveModelUrlToFirebase(downloadURL: String, complatition: ()->Void){
        
        let dbRef = Database.database().reference().child("ModelURL").child(UserModel.currentUser.uploadID).childByAutoId()
        dbRef.updateChildValues(["dawnloadURL": downloadURL, "userID": UserModel.currentUser.userID])
        complatition()
        
    }

    
    
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        NotificationCenter.default.post(Notification.init(name: Notification.Name.init("SHOULDPRESENT"), object: nil, userInfo: nil))
        self.performSegue(withIdentifier: "showUserBCVC", sender: sender)
    }
    
    @IBAction func cameraButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "CameraViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    func saveNoteToFirebase(note: String){
        let dbRef = Database.database().reference().child("Notes").child(UserModel.currentUser.uploadID).childByAutoId()
        dbRef.updateChildValues(["note": note, "userID": UserModel.currentUser.userID])
    }
    
    @IBAction func publishButtonAction(_ sender: UIButton) {
        uploadImageToFirebase(images: CurrentSession.currentSession.imageArray)
        CurrentSession.currentSession.videosImagesArray.removeAll()
        CurrentSession.currentSession.audioArray.removeAll()
        
        noteTextView.text = ""
        
        if  noteTextView.text != "" {
            saveNoteToFirebase(note: noteTextView.text)
        }
        if (self.cameraImage.image != nil) {
        self.showActivityIndicatory(uiView: self.view)
        UploadHelper.sharidInstanc.uploadStringToServer(string: UserModel.currentUser.uploadID, image: self.cameraImage.image!, block: { (status) in
            self.actInd?.stopAnimating()
            
            DispatchQueue.main.async {
                self.cameraImage.image = nil
            }
            if status {
                
                Helper.showAlertWith(title: "Upload Success", alertMessage: "")
            } else {
                Helper.showAlertWith(title: "Upload Failed", alertMessage: "")
            }
            
        })
    }
        
    }
    
    
    func showActivityIndicatory(uiView: UIView) {
        actInd = UIActivityIndicatorView()
        actInd?.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
        actInd?.center = self.view.center
        actInd?.hidesWhenStopped = true
        actInd?.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        self.view.addSubview(actInd!)
        actInd?.startAnimating()
    }
    
    
}



extension CreateAnImprntViewController : UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate {
   
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == imageCollectionView {
          return self.photosArry.count
        }
         if  collectionView == videoCollectionView {
             return self.videosArray.count
        }
        if  collectionView == modelCollectionView {
            return self.modelsArray.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == imageCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCell", for: indexPath) as! PhotosCollectionViewCell
            cell.photoObj = photosArry[indexPath.row]
            cell.setImage(image:photosArry[indexPath.row])
            cell.handleDeletButtonPressed = { cell in
                self.deletImageFromFirebase(imageObj: cell.photoObj!, cell: cell)
            }
            return cell
        }
        if  collectionView == videoCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! VideoCollectionViewCell
            cell.videoURL = CurrentSession.currentSession.videosArray[indexPath.row]
            cell.videoObj = CurrentSession.currentSession.videosImagesArray[indexPath.row]
            cell.setImage(image:videosArray[indexPath.row])
            cell.handleDeletButtonPressed = { cell in
                if let index = CurrentSession.currentSession.videosImagesArray.index(of:cell.videoObj!) {
                    CurrentSession.currentSession.videosImagesArray.remove(at: index)
                }
                
                self.adjustScrollView()
            }
            return cell
        }
        
        if  collectionView == modelCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCell", for: indexPath) as! PhotosCollectionViewCell
            cell.photoObj = modelsArray[indexPath.row]
            cell.setImage(image:modelsArray[indexPath.row])
            cell.handleDeletButtonPressed = { cell in
                if let index = CurrentSession.currentSession.modelImagesArray.index(of:cell.photoObj!) {
                    CurrentSession.currentSession.modelImagesArray.remove(at: index)
                    CurrentSession.currentSession.modelUrlArray.remove(at: index)
                }
                 self.adjustScrollView()
            }
            return cell
        }
        return UICollectionViewCell.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            UserDefaults.standard.set(textView.text, forKey: "note")
            UserDefaults.standard.synchronize()
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}





