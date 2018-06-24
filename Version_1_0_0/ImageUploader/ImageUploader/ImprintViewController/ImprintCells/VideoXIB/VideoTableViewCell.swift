//
//  VideoTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 16.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices

class VideoTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var _rootViewController: InprintTableViewController?
    var imagePickerController = UIImagePickerController()
    
    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var videoCollectionView: UICollectionView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        baseView.layer.cornerRadius = 10
        baseView.layer.borderWidth = 1
        baseView.layer.borderColor = UIColor.init(red: 25, green: 184, blue: 255).cgColor
       
        
        let nibNameVideo = UINib(nibName: "VideoCollectionViewCell", bundle:nil)
        videoCollectionView.register(nibNameVideo, forCellWithReuseIdentifier: "cell")
        videoCollectionView.dataSource = self
        videoCollectionView.delegate = self
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func  reloadCollectionView(){
        videoCollectionView.reloadData()
    }
    
    
    @IBAction func addVideoAction(_ sender: UIButton) {
        
            if sender.tag == 1 {
                let videoVCNew = VideoViewController()
                videoVCNew.didRecordVideo = { [unowned self] videoURL  in
                    videoVCNew.dismiss(animated: true, completion: nil)
                    DispatchQueue.main.async {
                        print("CurrentSession.currentSession.videosArray.append(videoURL!)\(CurrentSession.currentSession.videosArray.count)")
                        let videoObj = VideoObject()
                        videoObj.videoURL = videoURL
                        CurrentSession.currentSession.videosArray.append(videoObj)
                        self._rootViewController?.baseTableView.reloadData()
                    }
                }
                _rootViewController?.present(videoVCNew, animated: false, completion: nil)
              
            }
            if sender.tag == 2 {
                
                imagePickerController.delegate = self
                imagePickerController.sourceType = .photoLibrary
                imagePickerController.allowsEditing = false
                imagePickerController.mediaTypes = [kUTTypeMovie as String]
                _rootViewController?.present(imagePickerController, animated: true, completion: nil)
            }
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return   CurrentSession.currentSession.videosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! VideoCollectionViewCell
        cell.setVideoURL(url: CurrentSession.currentSession.videosArray[indexPath.row].videoURL!)
        cell.videoObject = CurrentSession.currentSession.videosArray[indexPath.row]
        cell.handleDeletButtonPressed = { [unowned self] videoCell in
            if let index =  CurrentSession.currentSession.videosArray.index(of: videoCell.videoObject!) {
                CurrentSession.currentSession.videosArray.remove(at: index)
                self._rootViewController?.baseTableView.reloadData()
            }
        }
        return cell
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videoURL = info[UIImagePickerControllerMediaURL]as? NSURL {
            let videoObj = VideoObject()
            videoObj.videoURL = videoURL as URL
            CurrentSession.currentSession.videosArray.append(videoObj)
        }
        
        _rootViewController?.dismiss(animated: true, completion: nil)
        
        
    }
}
