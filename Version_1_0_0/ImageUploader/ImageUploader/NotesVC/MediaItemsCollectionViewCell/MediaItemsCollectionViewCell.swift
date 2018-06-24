//
//  MediaItemsCollectionViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 21.06.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit

class MediaItemsCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var itemImageView: UIImageView!
    var mediaItem: MediaItem?
    var rootView: DetectedUnitView?
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 30
        itemImageView.clipsToBounds = true
    }
    
    
    func configur(){
        if mediaItem?.type == "Photos" {
            self.dawnloadImagesFromServer(imageUrl: (mediaItem?.mediaUrl!)!)
        }
        if mediaItem?.type == "VideoFiles" {
            self.dawnloadVideoFromServer(imageUrl: (mediaItem?.mediaUrl!)!)
        }
        if mediaItem?.type == "AudioFiles" {
             self.dawnloadAudioFromServer()
        }
        if mediaItem?.type == "URLs" {
            self.dawnloadUrlFromServer(itemUrl: (mediaItem?.mediaUrl!)!)
        }
        if mediaItem?.type == "Models" {
            self.dawnloadModelFromServer(imageUrl: (mediaItem?.mediaUrl!)!)
        }
    }
    
    
    func dawnloadImagesFromServer(imageUrl: String){
        
        DispatchQueue.global(qos: .background).async {
            if let url = URL.init(string: imageUrl) as? URL {
                do {
                    let data = try Data.init(contentsOf: url)
                    if let image = UIImage.init(data: data) as? UIImage {
                        DispatchQueue.main.async {
                            self.rootView?.mediaItemsCollectionView.isHidden = false
                            self.itemImageView.image = image
                            self.itemImageView.contentMode = .scaleAspectFill
                        }
                        
                    }
                }catch _ {
                    print("error")
                }
            }
        }

    }
    
    
    
    func dawnloadVideoFromServer(imageUrl: String){
        
        DispatchQueue.global(qos: .background).async {
            if let url = URL.init(string: imageUrl) as? URL {
                if let image  = self.getThumbnailImage(forUrl: url) as? UIImage {
                    DispatchQueue.main.async {
                        self.rootView?.mediaItemsCollectionView.isHidden = false
                        self.itemImageView.image = image
                    }
                }
            }
        }
        
    
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
    
    
    func dawnloadAudioFromServer(){
        DispatchQueue.main.async {
            self.rootView?.mediaItemsCollectionView.isHidden = false
            self.itemImageView.image = UIImage.init(named: "Musiconenote2")
        }
    }
    
    
    func dawnloadUrlFromServer(itemUrl: String){
        
        DispatchQueue.global(qos: .background).async {
        if let url = URL.init(string: "\(itemUrl)/favicon.ico") {
            DispatchQueue.global(qos: .background).async {
                do {
                    let data = try Data.init(contentsOf: url)
                    let image = UIImage.init(data: data)
                    DispatchQueue.main.async {
                        self.rootView?.mediaItemsCollectionView.isHidden = false
                        self.itemImageView.image = image
                        self.itemImageView.clipsToBounds = true
                    }
                    
                }catch let error {
                    DispatchQueue.main.async {
                        self.rootView?.mediaItemsCollectionView.isHidden = false
                        self.itemImageView.clipsToBounds = true
                        self.itemImageView.image = UIImage.init(named: "eIcon")
                    }
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    }
    
    func dawnloadModelFromServer(imageUrl: String){
        DispatchQueue.main.async {
            self.rootView?.mediaItemsCollectionView.isHidden = false
            self.itemImageView.image = UIImage.init(named: "\(imageUrl).jpg")
        }
        
    }
    
}
