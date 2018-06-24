//
//  VideoRecordingViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 06.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit


class  VideoRecordingViewController: UIViewController {
    var camerViewController: VideoRecording?
    
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        camerViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "videoVC") as? VideoRecording
         self.present(camerViewController!, animated: false, completion: nil)
    }
}
