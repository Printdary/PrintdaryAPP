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
    
    
    @IBOutlet weak var audioPlotView: EZAudioPlot!
    var audioObj: AudioObject?
    var handleDeletButtonPressed:((_ playerView: AudioPlayerView)->())?
    var audioFile: EZAudioFile?
    var player: AVAudioPlayer?
    var ezPlayer: EZAudioPlayer?
    
    override func awakeFromNib() {
        audioPlotView.backgroundColor = UIColor.white
    }
    @IBAction func deletButtonAction(_ sender: UIButton) {
       
        handleDeletButtonPressed?(self)
    }
    @IBAction func playButtonAction(_ sender: UIButton) {
        let url = URL.init(string: (self.audioObj?.audioURL)!)
        
//        audioFile = EZAudioFile.init(url: url, delegate: self)
//        audioFile?.getWaveformData(withNumberOfPoints: 1024, completion: { (data  , lenght) in
//
//            let dt : UnsafeMutablePointer<UnsafeMutablePointer<Float>?> = data!
//            self.audioPlotView.updateBuffer( dt[0], withBufferSize: UInt32(lenght))
//
//        })
        self.downloadFileFromURL(url: url! as NSURL)
       
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
    
}


class AudioObject: NSObject {
    
    var key: String?
    var audioURL: String?
}
class PhotoObject: NSObject {
    
    var key: String?
    var photoURL: String?
}
