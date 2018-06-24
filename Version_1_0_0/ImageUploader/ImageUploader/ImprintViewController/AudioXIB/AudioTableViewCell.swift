//
//  AudioTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 16.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices

class AudioTableViewCell: UITableViewCell,MPMediaPickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var baseView: UIView!
    var _rootViewController: InprintTableViewController?
    var imagePickerController = UIImagePickerController()
    var audioRecorderView: AudioRecordView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        baseView.layer.cornerRadius = 10
        baseView.layer.borderWidth = 1
        baseView.layer.borderColor = UIColor.init(red: 25, green: 184, blue: 255).cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(audioViewDelated(info:)), name: Notification.Name.init("AUDIOVIEWDELETED"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioRecordFinished(info:)), name: Notification.Name.init("AUDIO_RECORD_FINISHED"), object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func handleAudioRecordFinished(info: Notification){
        audioRecorderView?.removeFromSuperview()
        self.reloadTableView()
    }
    
    @objc func audioViewDelated(info: Notification){
        if let info = info.userInfo as? [String: Any]{
            if let obj = info["audioObj"] as? AudioObject {
                if let index =  CurrentSession.currentSession.audioArray.index(of: obj) {
                    CurrentSession.currentSession.audioArray.remove(at: index)
                   // self._rootViewController?.baseTableView.reloadData()
                    self._rootViewController?.baseTableView.beginUpdates()
                    self._rootViewController?.baseTableView.endUpdates()
                }
            }
        }
        //self._rootViewController?.baseTableView.reloadData()
        self._rootViewController?.baseTableView.beginUpdates()
        self._rootViewController?.baseTableView.endUpdates()
    }
    
    
    func setAudioViews(audios: [AudioObject]) {
        for obj in self.baseView.subviews {
            if obj.isKind(of: AudioPlayerView.self) {
                obj.removeFromSuperview()
            }
        }
        if UserDefaults.standard.value(forKey: "NewRecording") != nil{
            UserDefaults.standard.set(nil, forKey: "NewRecording")
            
           audioRecorderView = Bundle.main.loadNibNamed("AudioRecordView", owner: ChangeChapterNameAlert(), options: nil)?.first as? AudioRecordView
            audioRecorderView?.frame = CGRect.init(x: 0, y: 0 , width: self.baseView.frame.size.width, height: 120)
            audioRecorderView?.layer.cornerRadius = 10
            self.baseView.addSubview(audioRecorderView!)
            audioRecorderView?.startRecording()
            return
            
        }
        
       if audios.count == 0 {
          return 
        }
        for obj in  1...audios.count { //CGFloat.init(obj) * 60
            let audioViewNib = Bundle.main.loadNibNamed("AudioPlayerView", owner: AudioPlayerView(), options: nil)?.first as! AudioPlayerView
            audioViewNib.frame = CGRect.init(x: 0, y: CGFloat.init(obj) * 40 , width: self.baseView.frame.size.width, height: 40)
            audioViewNib.audioObj = audios[obj - 1]
            self.baseView.addSubview(audioViewNib)
            audioViewNib.index = obj
            
       }
        
    }
    
    @objc func reloadTableView(){
         self._rootViewController?.baseTableView.reloadData()
    }
    
    @IBAction func addAudioAction(_ sender: UIButton) {
       
                 if sender.tag == 1 {
                    UserDefaults.standard.set("newRecording", forKey: "NewRecording")
                    self._rootViewController?.baseTableView.beginUpdates()
                    self._rootViewController?.baseTableView.endUpdates()
                    self.setAudioViews(audios: [AudioObject]())
                  
                }

    }
    
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        _rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        _rootViewController?.dismiss(animated: true, completion: nil)
        print("you picked: \(mediaItemCollection)")//This is the picked media item.
        //  If you allow picking multiple media, then mediaItemCollection.items will return array of picked media items(MPMediaItem)
    }

    
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let videoURL = info[UIImagePickerControllerMediaURL]as? NSURL
        print(videoURL!)
        
         _rootViewController?.dismiss(animated: true, completion: nil)
    }
}
