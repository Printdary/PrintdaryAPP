//
//  PhotosCollectionViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 30.04.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var xImageView: UIImageView!
    @IBOutlet weak var baseImageView: UIImageView!
    var handleDeletButtonPressed:((_ playerView: PhotosCollectionViewCell)->())?
    var photoObj: ImageObject?
    var modelName: String?
    var modelObject: ModelObject?
    
    
    override func awakeFromNib() {
        xImageView.layer.cornerRadius = 10
    }
    
    func setImage(imageobj: ImageObject){
        if imageobj.image != nil {
                DispatchQueue.main.async() {
                    self.baseImageView.image = imageobj.image
                }
        } else {
            DispatchQueue.global().async {
                do {
                    let imageData =  try Data.init(contentsOf:imageobj.imageURL!)
                    let image = UIImage.init(data: imageData)
                    DispatchQueue.main.async() {
                        self.baseImageView.image = image
                    }
                    
                }catch {
                    
                }
            }
        }
    }
    
    func setBaseImage(urlString: String){
        self.baseImageView.downloadedFrom(link: urlString)
    }
    @IBAction func delateButtonAction(_ sender: UIButton) {
        handleDeletButtonPressed?(self)
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    
   
}
