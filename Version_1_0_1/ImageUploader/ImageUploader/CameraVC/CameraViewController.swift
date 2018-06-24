//
//  CameraViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 15.03.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import TOCropViewController

class CameraViewController: UIViewController ,AVCapturePhotoCaptureDelegate, MSCropViewDelegate{
   
    
    
    
    @IBOutlet weak var recordButton: UIButton!
    let captureSession = AVCaptureSession()
    let cameraOutput = AVCapturePhotoOutput()
    var error: NSError?
    var handleDidTackenPhoto:((_ tackenPhoto: UIImage, _ imageData: Data?)->Void)?
    var cvc : CropViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.bounds = view.bounds
            previewLayer.position = CGPoint.init(x: view.bounds.midX, y: view.bounds.midY)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            let cameraPreview = UIView(frame: CGRect.init(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            cameraPreview.layer.addSublayer(previewLayer)
            view.addSubview(cameraPreview)
            let imageViewFingerPrint = UIImageView.init(frame: CGRect.init(x: self.view.center.x - 25, y: self.view.frame.size.height - 100, width: 80, height: 80))
            imageViewFingerPrint.image = UIImage.init(named: "touch-id-icon")
            imageViewFingerPrint.contentMode = .scaleAspectFit
            imageViewFingerPrint.layer.masksToBounds = true
            cameraPreview.addSubview(imageViewFingerPrint)
            let recordBtn = UIButton.init(frame: CGRect.init(x: self.view.center.x - 25, y: self.view.frame.size.height - 100, width: 80, height: 80))
            recordBtn.layer.cornerRadius = 40
            recordBtn.layer.borderWidth = 2
            recordBtn.layer.borderColor = UIColor.white.cgColor
            recordBtn.backgroundColor = UIColor.clear
            recordBtn.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
            cameraPreview.addSubview(recordBtn)
            
        }
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
            UserDefaults.standard.set(dataImage, forKey: "capturedImage")
            UserDefaults.standard.synchronize()
            Helper.generateAutoId()
            self.presentCropViewController(image: image!)
        }
        
    }
    
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func presentCropViewController(image: UIImage) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        cvc = storyboard.instantiateViewController(withIdentifier: "cropVC") as? CropViewController
        cvc?.msCropDelegate = self
        self.present(cvc!, animated: true, completion: nil)
        
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        
        self.handleDidTackenPhoto?(image, nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func imageDidCropped() {
        cvc?.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion:  nil)
        //self.perform(#selector(performSegueWith(identifire:)), with: nil, afterDelay: 0.3)
    }
    
    @objc func performSegueWith(identifire: String) {
        self.performSegue(withIdentifier: "showVC", sender: nil)
    }

}
