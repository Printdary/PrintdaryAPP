//
//  SwitchViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 05.04.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


class SwitchViewController: UIViewController {
    
    
    
    var session: AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var fon: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        session = AVCaptureSession()
        let camera = getDevice(position: .back)
        do {
            input = try AVCaptureDeviceInput(device: camera!)
            if(session?.canAddInput(input!) == true){
                
                //Add the input to the session
                
                session?.addInput(input!)
            }
            output?.outputSettings = [AVVideoCodecKey : AVVideoCodecType.jpeg]
            previewLayer = AVCaptureVideoPreviewLayer(session: session!)
            
            //            if(session?.canAddOutput(output!) == true){
            //                session?.addOutput(output!)
            //            }
            previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            previewLayer?.frame = self.fon.frame
            self.view.layer.addSublayer(previewLayer!)
            session?.startRunning()
            // self.view.addSubview(fon)
            for subview in self.view.subviews {
                self.view.bringSubview(toFront: subview)
            }
            
        } catch let error as NSError {
            print(error)
            input = nil
        }
        
    }
    
    
    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devices() as NSArray;
        for de in devices {
            let deviceConverted = de as! AVCaptureDevice
            if(deviceConverted.position == position){
                return deviceConverted
            }
        }
        return nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
    @IBAction func signUpWithEmailButtonAction(_ sender: UIButton) {
    }
    
    
    @IBAction func signInButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func guestButtonAction(_ sender: UIButton) {
    }
}
