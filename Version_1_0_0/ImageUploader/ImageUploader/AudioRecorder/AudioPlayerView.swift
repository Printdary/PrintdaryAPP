//
//  AudioPlayerView.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 20.04.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import EZAudio
import AVFoundation
import AudioToolbox

class AudioPlayerView: UIView, EZAudioFileDelegate, AVAudioPlayerDelegate,EZAudioPlayerDelegate {
    
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var audioPlotView: EZAudioPlot!
    var audioObj: AudioObject?
    var handleDeletButtonPressed:((_ playerView: AudioObject)->())?
    var audioFile: EZAudioFile?
    var player: AVAudioPlayer?
    var ezPlayer: EZAudioPlayer?
    var index = 0
    
    
    override func awakeFromNib() {
        audioPlotView.backgroundColor = UIColor.clear
    }
    @IBAction func deletButtonAction(_ sender: UIButton) {
        
        self.removeFromSuperview()
        self.perform(#selector(postNotification), with: nil, afterDelay: 0.2)
       
    }
    
    @objc func postNotification(){
        NotificationCenter.default.post(name: Notification.Name.init("AUDIOVIEWDELETED"),
                                        object: nil,
                                        userInfo: ["audioObj" : audioObj as? AudioObject])
    }
    @IBAction func playButtonAction(_ sender: UIButton) {
        if sender.tag == 0 {
            if (self.ezPlayer?.currentTime != nil ){
                self.ezPlayer?.play()
                
                playImageView.image = UIImage.init(named: "Pause")
                sender.tag = 1
                print("pleyer play")
                return
            }
            self.ezPlayer?.volume = 100
             let url = self.audioObj?.audioURL
             self.downloadFileFromURL(url: url! as NSURL)
            playImageView.image = UIImage.init(named: "Pause")
             sender.tag = 1
             print("pleyer play first")
            return
        }
        else if sender.tag == 1 {
            sender.tag = 0
            print("pleyer pause")
            self.ezPlayer?.pause()
             playImageView.image = UIImage.init(named: "play")
        }
       
        
//        audioFile = EZAudioFile.init(url: url, delegate: self)
//        audioFile?.getWaveformData(withNumberOfPoints: 1024, completion: { (data  , lenght) in
//
//            let dt : UnsafeMutablePointer<UnsafeMutablePointer<Float>?> = data!
//            self.audioPlotView.updateBuffer( dt[0], withBufferSize: UInt32(lenght))
//
//        })
       
       
    }
    
    func play(url:NSURL) {
        print("playing \(url)")
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url as URL)
            player?.prepareToPlay()
            player?.volume = 1.0
            player?.play()
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
        
    }
    
    func downloadFileFromURL(url:NSURL){
        
        self.ezPlayer = EZAudioPlayer.init(delegate: self)
        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url as URL as URL, completionHandler: { [weak self](URL, response, error) -> Void in
            self?.audioFile = EZAudioFile.init(url: URL, delegate: self)
//            self?.audioFile?.getWaveformData(withNumberOfPoints: 1024, completion: { (data  , lenght) in
//                let dt : UnsafeMutablePointer<UnsafeMutablePointer<Float>?> = data!
//                self?.audioPlotView.updateBuffer( dt[0], withBufferSize: UInt32(lenght))
//
//            })
            
            let clientFormat = self?.audioFile?.clientFormat
            let numberOfFramesToRead = 512
            let channels = clientFormat?.mChannelsPerFrame
            let isInterleaved = EZAudioUtilities.isInterleaved(clientFormat!)
            let bufferList = EZAudioUtilities.audioBufferList(withNumberOfFrames: UInt32(numberOfFramesToRead), numberOfChannels: channels!, interleaved: isInterleaved)
           
            
            // Read the frames from the EZAudioFile into the AudioBufferList
            var framesRead : UInt32 = UInt32.init(0)
            var isEndOfFile : ObjCBool = false
            self?.audioFile?.readFrames(UInt32(numberOfFramesToRead), audioBufferList: bufferList, bufferSize: &framesRead, eof: &isEndOfFile)
            self?.ezPlayer?.delegate = self
            self?.ezPlayer?.playAudioFile(self?.audioFile!)
        })
        
        downloadTask.resume()
        
    }
    
    func audioFile(_ audioFile: EZAudioFile!, readAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        print("readAudio")
        self.audioPlotView.updateBuffer( buffer[0], withBufferSize: bufferSize)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying")
    }
    func audioPlayer(_ audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, in audioFile: EZAudioFile!) {
        self.audioPlotView.updateBuffer( buffer[0], withBufferSize: bufferSize)
    }
    
    func audioPlayer(_ audioPlayer: EZAudioPlayer!, reachedEndOf audioFile: EZAudioFile!) {
        DispatchQueue.main.async {
            self.playImageView.image = UIImage.init(named: "play")
            self.playButton.tag = 0
        }
        
    }
    
}


class AudioObject: NSObject {
    
    var key: String?
    var audioURL: URL?
}
class PhotoObject: NSObject {
    
    var key: String?
    var photoURL: String?
}


class VideoObject: NSObject {
    
    var key: String?
    var videoURL: URL?
}

class ImageObject: NSObject {
    
    var key: String?
    var imageURL: URL?
    var image : UIImage?
}

class UrlObject: NSObject {
    var key: String?
    var url: URL?
}

class ModelObject: NSObject {
    var modelUrl: String = ""
    var image: UIImage?
    var key: String?
}
