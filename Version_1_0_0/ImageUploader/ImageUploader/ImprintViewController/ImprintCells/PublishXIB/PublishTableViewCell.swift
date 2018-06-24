//
//  PublishTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 16.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Firebase

class PublishTableViewCell: UITableViewCell {

    
    var _rootViewController: InprintTableViewController?
    var actInd: UIActivityIndicatorView?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func showActivityIndicatory(uiView: UIView) {
        actInd = UIActivityIndicatorView()
        actInd?.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
        actInd?.center = (_rootViewController?.view.center)!
        actInd?.hidesWhenStopped = true
        actInd?.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        _rootViewController?.view.addSubview(actInd!)
        actInd?.startAnimating()
    }
    
    @IBAction func saveAsDraftButtonAction(_ sender: UIButton) {
        self.uploadUint()
        PublishTableViewCell.uploadUnitStatus(state: "0")
    }
    @IBAction func publishButtonAction(_ sender: UIButton) {
       self.uploadUint()
       PublishTableViewCell.uploadUnitStatus(state: "1")
    }
    
    
    
    func uploadUint(){
        if UserModel.currentUser.uploadID == "" {
            UserModel.currentUser.uploadID = Database.database().reference().childByAutoId().key
        }
        if CurrentSession.currentSession.title == "" {
            Helper.showAlertWith(title: "Info", alertMessage: "Title is required")
            return
        }
        self.showActivityIndicatory(uiView: self)
        var uploadedObjectsCount = 0
        let uploadCount = 5
        PublishTableViewCell.uploadImprintInfoToFirebase(type: "Title", infoText: CurrentSession.currentSession.title)
        CurrentSession.currentSession.title = ""
        PublishTableViewCell.uploadImprintInfoToFirebase(type: "Category", infoText: CurrentSession.currentSession.category)
        CurrentSession.currentSession.category = ""
        PublishTableViewCell.uploadImprintInfoToFirebase(type: "Note", infoText: CurrentSession.currentSession.note)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let strDate = formatter.string(from: Date())
        PublishTableViewCell.uploadImprintInfoToFirebase(type: "CreatedDate", infoText:strDate)
        CurrentSession.currentSession.note = ""
        
        PublishTableViewCell.uploadChapterIdToUnit(id: PathModel.shared.selectedChapter!)
        
        let imageModel = ImageObject()
        imageModel.image = CurrentSession.currentSession.croppedImage
        PublishTableViewCell.uploadImages(userId: UserModel.currentUser.userID, imagesArray: [imageModel]) { (dawnloadUrl) in
            PublishTableViewCell.saveDawnloadUrlToFirebase(type: "ImprintImage" ,downloadURL: dawnloadUrl, complatition: {
                print("Imprint images uploaded successfuly")
            })
        }
        
        
        
        PublishTableViewCell.isExistImageObject(type: "Photos", objects: CurrentSession.currentSession.imageArray, complatition: {
            
            
            PublishTableViewCell.uploadImages(userId: UserModel.currentUser.userID, imagesArray: CurrentSession.currentSession.imageArray) { (urlArray) in
                PublishTableViewCell.saveDawnloadUrlToFirebase(type: "Photos" ,downloadURL: urlArray, complatition: {
                    print("images uploaded successfuly")
                    uploadedObjectsCount += 1
                    CurrentSession.currentSession.imageArray.removeAll()
                    self.isAllObjectsUploaded(upoadedCount: uploadedObjectsCount, shouldUploadCount: uploadCount)
                    
                })
            }
        })
        
        
        PublishTableViewCell.isExistModelObject(type: "Models", objects: CurrentSession.currentSession.modelsArray) {
            PublishTableViewCell.saveModelUrlToFirebase(downloadURL: CurrentSession.currentSession.modelsArray) {
                
                print("models uploaded successfuly")
                uploadedObjectsCount += 1
                CurrentSession.currentSession.modelsArray.removeAll()
                self.isAllObjectsUploaded(upoadedCount: uploadedObjectsCount, shouldUploadCount: uploadCount)
                
            }
        }
        
        
        
        PublishTableViewCell.isExistAudioObject(type: "AudioFiles", objects: CurrentSession.currentSession.audioArray,
                                                complatition: {
                                                    
                                                    PublishTableViewCell.uploadAudioFilesToFirebase(userId: UserModel.currentUser.userID, audioFiles: CurrentSession.currentSession.audioArray) { (urlArray) in
                                                        PublishTableViewCell.saveDawnloadUrlToFirebase(type: "AudioFiles" ,downloadURL: urlArray, complatition: {
                                                            print("audios uploaded successfuly")
                                                            uploadedObjectsCount += 1
                                                            CurrentSession.currentSession.audioArray.removeAll()
                                                            self.isAllObjectsUploaded(upoadedCount: uploadedObjectsCount, shouldUploadCount: uploadCount)
                                                            
                                                        })
                                                    }
        })
        
        
        PublishTableViewCell.isExistVideoObject(type: "VideoFiles", objects: CurrentSession.currentSession.videosArray, complatition: {
            
            
            
            PublishTableViewCell.uploadVideoFilesToFirebase(userId: UserModel.currentUser.userID, videoFiles: CurrentSession.currentSession.videosArray) { (urlArray) in
                PublishTableViewCell.saveDawnloadUrlToFirebase(type: "VideoFiles" ,downloadURL: urlArray, complatition: {
                    print("videos uploaded successfuly")
                    uploadedObjectsCount += 1
                    CurrentSession.currentSession.videosArray.removeAll()
                    self.isAllObjectsUploaded(upoadedCount: uploadedObjectsCount, shouldUploadCount: uploadCount)
                    
                })
            }
        })
        
        
        
        PublishTableViewCell.isExistUrlObject(type: "URLs", objects: CurrentSession.currentSession.urlArray, complatition: {
            
            
            
            PublishTableViewCell.saveDawnloadUrlToFirebaseForUrls(type: "URLs" ,downloadURL: CurrentSession.currentSession.urlArray, complatition: {
                print("urls uploaded successfuly")
                uploadedObjectsCount += 1
                CurrentSession.currentSession.urlArray.removeAll()
                self.isAllObjectsUploaded(upoadedCount: uploadedObjectsCount, shouldUploadCount: uploadCount)
                
            })
        })
        
        
        
        
        
        
        
        
        if (CurrentSession.currentSession.croppedImage != nil) {
            //self.showActivityIndicatory(uiView: self)
            let udid = Auth.auth().currentUser?.uid
            let str = "\(udid!)\(UserModel.currentUser.uploadID)"
            UploadHelper.sharidInstanc.uploadStringToServer(string: str, image: CurrentSession.currentSession.croppedImage!, block: { (status) in
                self.actInd?.stopAnimating()
                DispatchQueue.main.async {
                    CurrentSession.currentSession.croppedImage = nil
                }
                if status {
                      NotificationCenter.default.post(name: Notification.Name.init("DID_SELECT_CHAPTER"), object: nil, userInfo: ["chapter" : PathModel.shared.selectedChapter!])
                    Helper.showAlertWith(title: "Imprint Upload Success", alertMessage: "")
                } else {
                    Helper.showAlertWith(title: "Imprint Upload Failed", alertMessage: "")
                }
                
            })
        }
        
        
        
    }
    
    
    func isAllObjectsUploaded(upoadedCount: Int, shouldUploadCount: Int){
        if upoadedCount == shouldUploadCount {
            DispatchQueue.main.async {
                CurrentSession.currentSession.imageArray.removeAll()
                CurrentSession.currentSession.videosArray.removeAll()
                CurrentSession.currentSession.audioArray.removeAll()
                CurrentSession.currentSession.modelsArray.removeAll()
                CurrentSession.currentSession.urlArray.removeAll()
                self.actInd?.stopAnimating()
                self._rootViewController?.dismiss(animated: true, completion: nil)
            }
        }
        
    }
  
    
    
    static func uploadChapterIdToUnit(id: String){
        let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").child(UserModel.currentUser.uploadID)
        ref.updateChildValues(["chapterID" : id])
    }
    static func uploadImprintInfoToFirebase(type: String?, infoText: String){
        let interval = Date.timeIntervalSinceReferenceDate
        if type == "CreatedDate" {
            let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").child(UserModel.currentUser.uploadID).child(type!)
            ref.setValue(infoText)
            return
        }
        let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").child(UserModel.currentUser.uploadID).child(type!).childByAutoId()
            ref.updateChildValues([type! : infoText, "createdDate" : interval])
        
    }
    
    
    static func uploadUnitStatus(state: String?){
        let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").child(UserModel.currentUser.uploadID)
        ref.updateChildValues(["stateID" : state])
        
    }
    
    static func saveDawnloadUrlToFirebase(type: String , downloadURL: [String], complatition: ()->Void){
        
        for url in downloadURL{
         let interval = Date.timeIntervalSinceReferenceDate
            let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").child(UserModel.currentUser.uploadID).child(type).childByAutoId()
            ref.updateChildValues(["dawnloadURL": url, "userID": UserModel.currentUser.userID, "createdDate" : interval])
        }
        complatition()
        
    }
    
    
    
    static func saveDawnloadUrlToFirebaseForUrls(type: String , downloadURL: [UrlObject], complatition: ()->Void){
        
        for urlObj in downloadURL{
            let interval = Date.timeIntervalSinceReferenceDate
            let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").child(UserModel.currentUser.uploadID).child(type).childByAutoId()
            var str =  ""
            str =  (urlObj.url?.absoluteString)!
            ref.updateChildValues(["dawnloadURL": str, "userID": UserModel.currentUser.userID, "createdDate" : interval])
            
        }
        complatition()
        
    }
    
    
    static func isExistAudioObject(type: String , objects: [AudioObject], complatition: @escaping ()->Void) {
        let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").child(UserModel.currentUser.uploadID).child("AudioFiles")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                for snap in (snapshot.children.allObjects as? [DataSnapshot])! {
                    print(snap.key)
                    var isExist  = false
                    for obj in CurrentSession.currentSession.audioArray {
                        if obj.key == snap.key {
                            isExist = true
                            if let index = CurrentSession.currentSession.audioArray.index(of:obj) {
                                CurrentSession.currentSession.audioArray.remove(at: index)
                            }
                        }
                    }
                    if !isExist {
                         ref.child(snap.key).removeValue()
                    }
                    
                }
                    complatition()
            }
            
        
    }
    
    
    static func isExistVideoObject(type: String , objects: [VideoObject], complatition: @escaping ()->Void) {
        let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").child(UserModel.currentUser.uploadID).child("VideoFiles")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            for snap in (snapshot.children.allObjects as? [DataSnapshot])! {
                print(snap.key)
                var isExist  = false
                for obj in CurrentSession.currentSession.videosArray {
                    if obj.key == snap.key {
                        isExist = true
                        if let index = CurrentSession.currentSession.videosArray.index(of:obj) {
                            CurrentSession.currentSession.videosArray.remove(at: index)
                        }
                    }
                }
                if !isExist {
                    ref.child(snap.key).removeValue()
                }
                
            }
            complatition()
        }
        
        
    }
    
    
    
    
    static func isExistImageObject(type: String , objects: [ImageObject], complatition: @escaping ()->Void) {
        let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").child(UserModel.currentUser.uploadID).child("Photos")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            for snap in (snapshot.children.allObjects as? [DataSnapshot])! {
                print(snap.key)
                var isExist  = false
                for obj in CurrentSession.currentSession.imageArray {
                    if obj.key == snap.key {
                        isExist = true
                        if let index = CurrentSession.currentSession.imageArray.index(of:obj) {
                            CurrentSession.currentSession.imageArray.remove(at: index)
                        }
                    }
                }
                if !isExist {
                    ref.child(snap.key).removeValue()
                }
                
            }
            complatition()
        }
        
        
    }
    
    
    static func isExistUrlObject(type: String , objects: [UrlObject], complatition: @escaping ()->Void) {
        let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").child(UserModel.currentUser.uploadID).child("URLs")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            for snap in (snapshot.children.allObjects as? [DataSnapshot])! {
                print(snap.key)
                var isExist  = false
                for obj in CurrentSession.currentSession.urlArray {
                    if obj.key == snap.key {
                        isExist = true
                        if let index = CurrentSession.currentSession.urlArray.index(of:obj) {
                            CurrentSession.currentSession.urlArray.remove(at: index)
                        }
                    }
                }
                if !isExist {
                    ref.child(snap.key).removeValue()
                }
                
            }
            complatition()
        }
        
        
    }
    
    static func isExistModelObject(type: String , objects: [ModelObject], complatition: @escaping ()->Void) {
        let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").child(UserModel.currentUser.uploadID).child("Models")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            for snap in (snapshot.children.allObjects as? [DataSnapshot])! {
                print(snap.key)
                var isExist  = false
                for obj in CurrentSession.currentSession.modelsArray {
                    if obj.key == snap.key {
                        isExist = true
                        if let index = CurrentSession.currentSession.modelsArray.index(of:obj) {
                            CurrentSession.currentSession.modelsArray.remove(at: index)
                        }
                    }
                }
                if !isExist {
                    ref.child(snap.key).removeValue()
                }
                
            }
            complatition()
        }
        
        
    }
    
    
    // Image Uploading
    
    
    static func uploadImages(userId: String, imagesArray : [ImageObject], completionHandler: @escaping ([String]) -> ()){
        var storage     =   Storage.storage()
        
        var uploadedImageUrlsArray = [String]()
        var uploadCount = 0
        let imagesCount = imagesArray.count
        
        for imageObj in imagesArray{
            
            let imageName = NSUUID().uuidString // Unique string to reference image
            
            //Create storage reference for image
            let storageRef = storage.reference().child("\(userId)").child("\(imageName).png")
            
            
            guard let myImage = imageObj.image as? UIImage else{
                return
            }
            guard let uplodaData = UIImagePNGRepresentation(myImage) else{
                return
            }
            
            // Upload image to firebase
            let uploadTask = storageRef.putData(uplodaData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error)
                    return
                }
                if let imageUrl = metadata?.downloadURL()?.absoluteString{
                    print(imageUrl)
                    uploadedImageUrlsArray.append(imageUrl)
                    
                    uploadCount += 1
                    print("Number of images successfully uploaded: \(uploadCount)")
                    if uploadCount == imagesCount{
                        NSLog("All Images are uploaded successfully, uploadedImageUrlsArray: \(uploadedImageUrlsArray)")
                        completionHandler(uploadedImageUrlsArray)
                    }
                }
                
            })
            
            
            observeUploadTaskFailureCases(uploadTask : uploadTask)
        }
        completionHandler(uploadedImageUrlsArray)
    }
    
    
    static func observeUploadTaskFailureCases(uploadTask : StorageUploadTask){
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as? NSError {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    NSLog("File doesn't exist")
                    break
                case .unauthorized:
                    NSLog("User doesn't have permission to access file")
                    break
                case .cancelled:
                    NSLog("User canceled the upload")
                    break
                    
                case .unknown:
                    NSLog("Unknown error occurred, inspect the server response")
                    break
                default:
                    NSLog("A separate error occurred, This is a good place to retry the upload.")
                    break
                }
            }
        }
    }
    
    
    
// Models Uploading
    
  static  func saveModelUrlToFirebase(downloadURL: [ModelObject], complatition: ()->Void){
    for model in downloadURL {
        let ref = Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).child("Units").child(UserModel.currentUser.uploadID).child("Models").childByAutoId()
         let interval = Date.timeIntervalSinceReferenceDate
         ref.updateChildValues(["dawnloadURL": model.modelUrl, "userID": UserModel.currentUser.userID, "createdDate" : interval])
    }
        complatition()
        
}
    
   
    
    
    //Audio Uploading
    
    static func uploadAudioFilesToFirebase(userId:String, audioFiles:[AudioObject],completionHandler: @escaping ([String]) -> ()){
        var storage     =   Storage.storage()
        var uploadedAudioUrlsArray = [String]()
        var uploadCount = 0
        let audioCount = audioFiles.count
        
        for file in audioFiles{
            
            let imageName = NSUUID().uuidString // Unique string to reference image
            
            //Create storage reference for image
            let storageRef = storage.reference().child("\(userId)").child("\(imageName).m4a")
            
            
            guard let audio = file as? AudioObject else{
                return
            }
            guard let uplodaUrl = audio.audioURL as? URL else{
                return
            }
            
            
            // Upload image to firebase
            let uploadTask = storageRef.putFile(from: uplodaUrl, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error)
                    return
                }
                if let audioUrl = metadata?.downloadURL()?.absoluteString{
                    print(audioUrl)
                    uploadedAudioUrlsArray.append(audioUrl)
                    
                    uploadCount += 1
                    print("Number of audio successfully uploaded: \(uploadCount)")
                    if uploadCount == audioCount{
                        NSLog("All Audio are uploaded successfully, uploadedImageUrlsArray: \(uploadedAudioUrlsArray)")
                        completionHandler(uploadedAudioUrlsArray)
                    }
                }
                
            })
            
            
            observeUploadTaskFailureCases(uploadTask : uploadTask)
        }
        completionHandler(uploadedAudioUrlsArray)
    }
    
    
    
    
    // Upload Videos
    
    static func uploadVideoFilesToFirebase(userId:String, videoFiles:[VideoObject],completionHandler: @escaping ([String]) -> ()){
        var storage     =   Storage.storage()
        var uploadedAudioUrlsArray = [String]()
        var uploadCount = 0
        let audioCount = videoFiles.count
        
        for file in videoFiles{
            
            let imageName = NSUUID().uuidString // Unique string to reference image
            
            //Create storage reference for image
            let storageRef = storage.reference().child("\(userId)").child("\(imageName).mov")
            
            
            guard let video = file.videoURL as? URL else{
                return
            }
            
            
            
            // Upload image to firebase
            let uploadTask = storageRef.putFile(from: video, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error)
                    return
                }
                if let videoUrl = metadata?.downloadURL()?.absoluteString{
                    print(videoUrl)
                    uploadedAudioUrlsArray.append(videoUrl)
                    
                    uploadCount += 1
                    print("Number of video successfully uploaded: \(uploadCount)")
                    if uploadCount == audioCount{
                        NSLog("All Videos are uploaded successfully, uploadedImageUrlsArray: \(uploadedAudioUrlsArray)")
                        completionHandler(uploadedAudioUrlsArray)
                    }
                }
                
            })
            
            
            observeUploadTaskFailureCases(uploadTask : uploadTask)
        }
         completionHandler(uploadedAudioUrlsArray)
    }
    
}
