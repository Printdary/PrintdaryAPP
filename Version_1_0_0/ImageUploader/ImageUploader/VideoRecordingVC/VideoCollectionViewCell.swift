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
    @IBOutlet weak var delateImageView: UIImageView!
    var handleDeletButtonPressed:((_ playerView: VideoCollectionViewCell)->())?
    var videoObj: UIImage?
    var videoObject: VideoObject?
    
    override func awakeFromNib() {
        delateImageView.layer.cornerRadius = 9
    }
    
   
    
    func setVideoURL(url: URL){
        self.videoObject?.videoURL = url
        if let thumbnailImage = getThumbnailImage(forUrl: url) {
            DispatchQueue.main.async() {
                self.thumbnailImageView.image = thumbnailImage
            }
        }

        
    }
    
    
    
    @IBAction func deletButtonAction(_ sender: UIButton){
        handleDeletButtonPressed?(self)
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
}
