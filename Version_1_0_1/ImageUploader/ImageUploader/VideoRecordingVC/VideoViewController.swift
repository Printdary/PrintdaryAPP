//
//  VideoViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 19.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Foundation


class VideoViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
   
    

    
    
    lazy var cameraQueue : DispatchQueue = {
        var queue : DispatchQueue = DispatchQueue.init(label: "Camera")
        return queue
    }()
    
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var cameraButton: UIButton?
    var outputURL: URL!
    var videoURL: URL?
    var useVideoButton: UIButton?
    var didRecordVideo:((_ videoURL: URL?)-> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AppUtility.lockOrientation(.all)
        
        if setupSession() {
            setupPreview()
            startSession()
        }
        
        cameraButton = UIButton.init(frame: CGRect.init(x:self.view.frame.size.width / 2 - 40 , y: self.view.frame.size.height - 90, width: 80, height: 80))
        cameraButton?.layer.borderWidth = 2
        cameraButton?.layer.borderColor = UIColor.red.cgColor
        cameraButton?.layer.cornerRadius = 40
        cameraButton?.addTarget(self, action: #selector(camerButtonAction(sender:)), for: .touchUpInside)
        useVideoButton = UIButton.init(frame: CGRect.init(x:self.view.frame.size.width  - 110 , y: self.view.frame.size.height - 70, width: 100, height: 40))
        useVideoButton?.addTarget(self, action: #selector(useVideoAction(sender:)), for: .touchUpInside)
        useVideoButton?.layer.borderWidth = 2
        useVideoButton?.layer.borderColor = UIColor.white.cgColor
        useVideoButton?.setTitle("Use Video", for: .normal)
        self.view.addSubview(useVideoButton!)
        self.view.addSubview(cameraButton!)
        useVideoButton?.isHidden = true
        // Do any additional setup after loading the view.
    }

    
    
    override func viewWillLayoutSubviews() {
        self.previewLayer.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        cameraButton?.frame = CGRect.init(x:self.view.frame.size.width / 2 - 40 , y: self.view.frame.size.height - 90, width: 80, height: 80)
        useVideoButton?.frame =  CGRect.init(x:self.view.frame.size.width  - 110 , y: self.view.frame.size.height - 70, width: 100, height: 40)
        self.previewLayer.connection?.videoOrientation = self.currentVideoOrientation()
    }
    
    @objc func camerButtonAction(sender: UIButton){
        if sender.tag == 0 {
            useVideoButton?.isHidden = true
            sender.backgroundColor = UIColor.red
            sender.tag = 1
            
        }else {
            sender.backgroundColor = UIColor.clear
            sender.tag = 0
        }
        startCapture()
        
    }
    
    @objc func useVideoAction(sender: UIButton) {
        self.didRecordVideo?(self.videoURL)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(previewLayer)
    }

    func setupSession() -> Bool {
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // Setup Camera
        let camera = AVCaptureDevice.default(for: .video)
        
        do {
            let input = try AVCaptureDeviceInput(device: camera!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        // Setup Microphone
        let microphone = AVCaptureDevice.default(for: .audio)
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone!)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        
        
        // Movie output
        
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        return true
    }
    
    func setupCaptureMode(_ mode: Int) {
        // Video Mode
        
    }
    
    //MARK:- Camera Session
    func startSession() {
        
        
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    func startCapture() {
        
        startRecording()
        
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mov")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    
    override  func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            self.view.setNeedsLayout()
        }
        
    }
    
    func startRecording() {
        
        if movieOutput.isRecording == false {
            
            let connection = movieOutput.connection(with: .video)
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeInput.device
            if (device.isSmoothAutoFocusSupported) {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
                
            }
            
            //EDIT2: And I forgot this
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            
        }
        else {
            stopRecording()
        }
        
    }
    
    func stopRecording() {
        
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            
            videoURL = outputFileURL
            self.useVideoButton?.isHidden = false
        }
        outputURL = nil
    }
    }
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        return
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
       
}
