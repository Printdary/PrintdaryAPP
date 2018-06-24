//
//  UserBCameraViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 05.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreMotion
import AVFoundation

class UserBCameraViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {
   
    
   lazy var cameraQueue : DispatchQueue = {
        var queue : DispatchQueue = DispatchQueue.init(label: "Camera")
        return queue
    }()
    var userButton : UIButton?
    var shouldPresent = true
    let captureSession = AVCaptureSession()
    let cameraButton = UIView()
    let movieOutput = AVCaptureVideoDataOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var pinImageView: UIImageView?
    var swipeGesture : UISwipeGestureRecognizer?
    var activeInput: AVCaptureDeviceInput!
    var detectedUnitView : DetectedUnitView?
    
    
    override func viewDidLoad() {
        
       AppUtility.lockOrientation(.portrait)
        NotificationCenter.default.addObserver(self, selector: #selector(restartSession), name: Notification.Name.init("RESTART_SESSION"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidSelectModel), name: Notification.Name.init("DID_SELECT_MODEL"), object: nil)
        AppUtility.lockOrientation(.portrait)
        swipeGesture = UISwipeGestureRecognizer.init(target: self, action: #selector(didSwipe))
        self.view.addGestureRecognizer(swipeGesture!)
        UploadHelper.sharidInstanc.uploadTask = nil
        UploadHelper.sharidInstanc.isUploading = false

        UploadHelper.sharidInstanc.imageFound = { [unowned self] image, tag, isFound in
            UserDefaults.standard.set(tag, forKey: "Tag")
            if tag.characters.count < 48 {
                return
            }
            
            UploadHelper.sharidInstanc.imageFound = nil
            self.imageDetected()
            DispatchQueue.main.async { [unowned self] in
                UploadHelper.sharidInstanc.uploadTask = nil
                self.movieOutput.setSampleBufferDelegate(nil, queue: nil)
            }

        }
        
       
        
            if  self.setupSession() {
                self.setupPreview()
               
            }
        


    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            NotificationCenter.default.post(name: Notification.Name.init("Did_rotate"), object: nil, userInfo: ["size": size])
        
    }

    
    @objc func handleDidSelectModel(){
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main) 
        let vc = storyboard.instantiateViewController(withIdentifier: "ServerSideVC") as! ServerSideViewController
        self.navigationController?.show(vc, sender: nil)
        
    }
    @objc func restartSession(){
        swipeGesture?.isEnabled =  true
         movieOutput.setSampleBufferDelegate(self, queue: cameraQueue)
        // self.perform(#selector(imageDetected), with: nil, afterDelay: 3)
    }
    
    override func viewWillAppear(_ animated: Bool) {
         swipeGesture?.isEnabled =  true
        pinImageView?.removeFromSuperview()
        userButton?.removeFromSuperview()
        
        
        if let id = UserDefaults.standard.value(forKey: "unitID"){
            addUnitView()
            if !captureSession.isRunning {
                
                videoQueue().async {
                    self.captureSession.startRunning()
                }
            }
        }else{
            #if SERVERANAVAILABLE
            if !captureSession.isRunning {
                
                videoQueue().async {
                    self.captureSession.startRunning()
                }
            }
            self.perform(#selector(imageDetected), with: nil, afterDelay: 3)
            #else
             self.startSession()
            #endif
          
           
        }
      
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopUploadingImages()
    }
    
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        DispatchQueue.main.async {
            self.view.layer.addSublayer(self.previewLayer)
        }
       
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
        let microphone = AVCaptureDevice.default(for: .video)
        
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
        
        movieOutput.setSampleBufferDelegate(self, queue: cameraQueue)
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        return true
    }
    
    func setupCaptureMode(_ mode: Int) {
        // Video Mode
        
    }
    
    //MARK:- Camera Session
   @objc func startSession() {
        
        
        if !captureSession.isRunning {
            
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
        if movieOutput.sampleBufferDelegate == nil {
            movieOutput.setSampleBufferDelegate(self, queue: cameraQueue)
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
    
    
   
    func stopRecording() {
        
        
    }
    
    
    
    func stopUploadingImages(){
        self.stopSession()
        UploadHelper.sharidInstanc.imageFound = nil
        UploadHelper.sharidInstanc.detectionCount = 0;
        DispatchQueue.main.async {  [unowned self] in
            UploadHelper.sharidInstanc.uploadTask = nil
            self.movieOutput.setSampleBufferDelegate(nil, queue: nil)
        }
    }
    
    
    @objc func changPresentationStatus (){
        self.shouldPresent = true
    }
    
   @objc func imageDetected(){
    pinImageView = UIImageView.init(frame: CGRect.init(x: 40, y: 50, width: self.view.frame.size.width/3, height: self.view.frame.size.height / 5))
       userButton = UIButton.init(type: .system)
    userButton?.frame = CGRect.init(x: 67, y: 50, width: (pinImageView?.frame.size.height)! / 2, height: (pinImageView?.frame.size.height)! / 2)
    pinImageView?.image = UIImage.init(named: "Marker")
    userButton?.setImage(UIImage.init(named: "administrator-male"), for: .normal)
    userButton?.addTarget(self, action: #selector(userButtonClicked), for: .touchUpInside)
    self.view.addSubview(pinImageView!)
    self.view.addSubview(userButton!)
    
    }
    
    @objc func userButtonClicked(){
        print("userButtonClicked")
       self.movieOutput.setSampleBufferDelegate(nil, queue: cameraQueue)
        pinImageView?.removeFromSuperview()
        userButton?.removeFromSuperview()
        addUnitView()
    }
    
    func addUnitView(){
        detectedUnitView = Bundle.main.loadNibNamed("DetectedUnitView", owner: DetectedUnitView(), options: nil)?.first as! DetectedUnitView
        detectedUnitView?.configureUnit()
        detectedUnitView?.blurView.alpha = 0
        self.view.addSubview(detectedUnitView!)
        swipeGesture?.isEnabled =  false
    }
    
    @objc func didSwipe(){
        
        detectedUnitView?.removeFromSuperview()
        self.movieOutput.setSampleBufferDelegate(nil, queue: nil)
        self.performSegue(withIdentifier: "createUnitVC", sender: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
       // self.perform(#selector(imageDetected), with: nil, afterDelay: 5)
    }
    
    
   var counter = 0
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let context = CIContext.init(options: nil)
         let image = LLSimpleCamera.image(from: sampleBuffer, cont: context)
        // let image = sampleBuffer.image()
        counter += 1
        if counter == 50 {
         UploadHelper.sharidInstanc.uploadImageToServer(image: image!, queue: DispatchQueue.global())
            counter = 0
        }
         print("AVCaptureFileOutput")
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
   
    
}
extension CMSampleBuffer {
    func image(orientation: UIImageOrientation = .up, scale: CGFloat = 1.0) -> UIImage? {
        if let buffer = CMSampleBufferGetImageBuffer(self) {
            let ciImage = CIImage(cvPixelBuffer: buffer)
            
            return UIImage(ciImage: ciImage, scale: scale, orientation: orientation)
        }
        
        return nil
    }
}
