//
//  TackePhotoViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 30.04.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Firebase

class TackePhotoViewController : UIViewController,AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    let captureSession = AVCaptureSession()
    let cameraOutput = AVCapturePhotoOutput()
    var error: NSError?
    var handleDidTackenPhoto:((_ tackenPhoto: UIImage, _ imageData: Data?)->Void)?
    var baseImageView: UIImageView?
    var refreshButton : UIButton = UIButton.init(type: .system)
    var nextButton : UIButton = UIButton.init(type: .system)
    var cameraPreview : UIView = UIView()
    var previewLayer:AVCaptureVideoPreviewLayer?
    var imageViewFingerPrint : UIImageView?
    var recordBtn : UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppUtility.lockOrientation(.all)
        recordButton.layer.cornerRadius = 25
        self.navigationController?.isNavigationBarHidden = false
       
        
        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaType.video) && $0.position == AVCaptureDevice.Position.back }
        if let captureDevice = devices.first  {
            
            captureSession.addInput(try! AVCaptureDeviceInput.init(device: captureDevice))
            captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
            captureSession.startRunning()
            if captureSession.canAddOutput(cameraOutput) {
                captureSession.addOutput(cameraOutput)
            }
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.bounds = view.bounds
            previewLayer?.position = CGPoint.init(x: view.bounds.midX, y: view.bounds.midY)
            previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            cameraPreview = UIView(frame: CGRect.init(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            cameraPreview.layer.addSublayer(previewLayer!)
            view.addSubview(cameraPreview)
            imageViewFingerPrint = UIImageView.init(frame: CGRect.init(x: self.view.center.x - 25, y: self.view.frame.size.height - 100, width: 80, height: 80))
            imageViewFingerPrint?.image = UIImage.init(named: "touch-id-icon")
            imageViewFingerPrint?.contentMode = .scaleAspectFit
            imageViewFingerPrint?.layer.masksToBounds = true
            cameraPreview.addSubview(imageViewFingerPrint!)
            recordBtn = UIButton.init(frame: CGRect.init(x: self.view.center.x - 25, y: self.view.frame.size.height - 100, width: 80, height: 80))
            recordBtn?.layer.cornerRadius = 40
            recordBtn?.layer.borderWidth = 2
            recordBtn?.layer.borderColor = UIColor.white.cgColor
            recordBtn?.backgroundColor = UIColor.clear
            recordBtn?.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
            cameraPreview.addSubview(recordBtn!)
            
        }
    }
    
    
    override func viewWillLayoutSubviews() {
         self.cameraPreview.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        self.previewLayer?.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        baseImageView?.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        
        imageViewFingerPrint?.frame =  CGRect.init(x: self.view.center.x - 25, y: self.view.frame.size.height - 100, width: 80, height: 80)
        recordBtn?.frame = CGRect.init(x: self.view.center.x - 25, y: self.view.frame.size.height - 100, width: 80, height: 80)
        refreshButton.frame = CGRect.init(x: self.view.frame.size.width - 50, y: 10, width: 50, height: 50)
         nextButton.frame = CGRect.init(x: self.view.frame.size.width - 50, y: self.view.frame.size.height - 50, width: 50, height: 50)
        self.previewLayer?.connection?.videoOrientation = currentVideoOrientation()
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
    
    @objc func capturePhoto() {
        
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 10,
                             kCVPixelBufferHeightKey as String: 10]
        settings.previewPhotoFormat = previewFormat
        self.cameraOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            let image =  UIImage(data: dataImage)
            self.baseImageView = UIImageView.init(frame: self.view.frame)
             self.baseImageView?.backgroundColor = UIColor.black
            self.baseImageView?.contentMode = .scaleAspectFit
            self.baseImageView?.image = image
            DispatchQueue.main.async {
                self.cameraPreview.addSubview(self.baseImageView!)
            }
            
           
            refreshButton.frame = CGRect.init(x: self.view.frame.size.width - 50, y: 10, width: 50, height: 50)
            refreshButton.setImage(UIImage.init(named: "refresh"), for: .normal)
            refreshButton.isUserInteractionEnabled = true
            refreshButton.tintColor = UIColor.white
            refreshButton.addTarget(self, action: #selector(refreshButtonAction), for: .touchUpInside)
            DispatchQueue.main.async {
                self.cameraPreview.addSubview(self.refreshButton)
            }
            
            
            
   
            nextButton.frame = CGRect.init(x: self.view.frame.size.width - 50, y: self.view.frame.size.height - 50, width: 50, height: 50)
            nextButton.setImage(UIImage.init(named: "arrow2"), for: .normal)
            nextButton.tintColor = UIColor.white
            nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
              DispatchQueue.main.async {
                self.cameraPreview.addSubview(self.nextButton)
            }
            
        }
        
    }
    
    
    @objc func refreshButtonAction(){
      refreshButton.removeFromSuperview()
      nextButton.removeFromSuperview()
      self.baseImageView?.removeFromSuperview()
    }
    
    @objc func nextButtonAction(sender: UIButton){
        
        if let img = self.baseImageView?.image {
            let imageObj = ImageObject()
            imageObj.image = img
           CurrentSession.currentSession.imageArray.append(imageObj)
        }
        self.dismiss(animated: false, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
  
    
  
    
}
