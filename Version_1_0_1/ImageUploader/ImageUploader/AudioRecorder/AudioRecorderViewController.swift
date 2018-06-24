//
//  AudioRecorderViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 19.04.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreMIDI
import Firebase
import EZAudio
import DisPlayers_Audio_Visualizers

class AudioRecorderViewController: UIViewController,UITextFieldDelegate, AVAudioRecorderDelegate,EZMicrophoneDelegate {
    
    
    var audioRecorder: AVAudioRecorder?
    var recordingSession: AVAudioSession?
    var audioPlayer: AVAudioPlayer?
    var audioFileName : URL?
    var meterTimer : Timer?
    var micraphon : EZMicrophone?
   
    @IBOutlet weak var equalizerViewBaseView: EZAudioPlot!
    var equalizer: DPHistogramEqualizerView?
    @IBOutlet weak var baseImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var baseImageViewContainerView: UIView!
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var notesTextView: UITextView!
    
    
    @IBOutlet weak var timerLabel: UILabel!
    override func viewDidLoad() {
        
        
        equalizerViewBaseView.backgroundColor = UIColor.clear
        equalizerViewBaseView.color = UIColor.black
        equalizerViewBaseView.plotType = .buffer
        
        notesView.layer.borderWidth = 2
        notesView.layer.borderColor = UIColor.black.cgColor
        notesView.layer.cornerRadius = 10
        audioView.layer.borderWidth = 2
        audioView.layer.cornerRadius = 10
        audioView.layer.borderColor = UIColor.black.cgColor
        baseImageViewContainerView.layer.borderWidth = 2
        baseImageViewContainerView.layer.borderColor = UIColor.black.cgColor
        baseImageViewContainerView.layer.cornerRadius = 10
        baseImageView.clipsToBounds = true
        baseImageView.layer.borderWidth = 2
        baseImageView.layer.borderColor = UIColor.black.cgColor
        baseImageView.layer.cornerRadius = 10
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession?.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession?.setActive(true)
            recordingSession?.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("allow")
                       // self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
        
        if let imageData = UserDefaults.standard.value(forKey: "capturedImage") {
            let image = UIImage.init(data: imageData as! Data)
            self.baseImageView.image = image
            self.baseImageView.contentMode = .scaleAspectFill
        }
        if let text = UserDefaults.standard.value(forKey: "note") {
            notesTextView.text = text as! String
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupRecorder()
        audioRecorder?.record()
        self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                               target:self,
                                               selector:#selector(self.updateAudioMeter),
                                               userInfo:nil,
                                               repeats:true)
        micraphon = EZMicrophone.init(microphoneDelegate: self)
        let inputs = EZAudioDevice.inputDevices()
        micraphon?.device = inputs![0] as! EZAudioDevice
        drawBufferPlot()
        micraphon?.startFetchingAudio()
        
       
    }
    
    func setupRecorder() {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirection = path[0]
        audioFileName = documentDirection.appendingPathComponent("audioFile\(Date()).m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        var error : NSError?
        do {
            audioRecorder = try AVAudioRecorder(url: self.audioFileName!, settings: settings)
            
        } catch {
            audioRecorder = nil
        }
        
        if let err = error {
            print("error recording \(err.localizedDescription)")
             Helper.showAlertWith(title: "Error", alertMessage: (error?.localizedDescription)!)
        }else {
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
        }
       
    }
    @IBAction func stopRecordingButtonAction(_ sender: UIButton) {
         audioRecorder?.stop()
         self.meterTimer?.invalidate()
    }
    
    @objc func updateAudioMeter() {
        if (audioRecorder?.isRecording)! {
            let dFormat = "%02d"
            let min:Int = Int(audioRecorder!.currentTime / 60)
            let sec:Int = Int(audioRecorder!.currentTime.truncatingRemainder(dividingBy: 60))
            let s = "\(String(format: dFormat, min)):\(String(format: dFormat, sec))"
            timerLabel.text = s
            audioRecorder?.updateMeters()
            let apc0 = audioRecorder?.averagePower(forChannel: 0)
            let peak0 = audioRecorder?.peakPower(forChannel: 0)
            print("++++++++=\(apc0,peak0 )")
            
        }
    }
    
  func drawBufferPlot(){
    equalizerViewBaseView?.plotType = .buffer
    equalizerViewBaseView?.shouldMirror = false
    equalizerViewBaseView?.shouldFill = false
  }

    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
             Helper.showAlertWith(title: "Error", alertMessage: "Audio recording filed")
        }
        print("audioRecorderDidFinishRecording \(flag)")
        let audioObj = AudioObject()
        audioObj.key = ""
        audioObj.audioURL = self.audioFileName
        CurrentSession.currentSession.audioArray.append(audioObj)
        self.dismiss(animated: false, completion: nil)
        
    }
    
   
    
    func microphone(_ microphone: EZMicrophone!, hasAudioStreamBasicDescription audioStreamBasicDescription: AudioStreamBasicDescription) {
        print("hasAudioStreamBasicDescription")
    }
    
    func microphone(_ microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        DispatchQueue.main.async {
            self.equalizerViewBaseView?.updateBuffer(buffer[0], withBufferSize: bufferSize)
        }
    }
    @IBAction func pauseButtonAction(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            sender.setImage(UIImage.init(named: "play"), for: .normal)
            audioRecorder?.pause()
        } else {
            
            sender.setImage(UIImage.init(named: "Pause"), for: .normal)
            audioRecorder?.record()
            sender.tag = 0
        }
    }
}

