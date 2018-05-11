//
//  VideoCollectionViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 06.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    var handleDeletButtonPressed:((_ playerView: VideoCollectionViewCell)->())?
    var videoObj: UIImage?
    var videoURL: URL?
    
    override func awakeFromNib() {
        
    }
    
    
    func setImage(image: UIImage){
        DispatchQueue.main.async() {
            self.thumbnailImageView.image = image
        }
    }
    
    @IBAction func deletButtonAction(_ sender: UIButton){
        handleDeletButtonPressed?(self)
    }
}
