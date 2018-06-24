//
//  ViewsTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 03.06.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit

class ViewsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    var viewObj : ViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.borderWidth  = 1
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.masksToBounds = true
    }

    
    func setViewModel(model: ViewModel){
        DispatchQueue.global(qos: .background).async {
            
            if model.viewImage != nil && model.viewImage != "" {
                let url = URL.init(string: model.viewImage! )
                do {
                    let imageData = try Data.init(contentsOf: url!)
                    let image = UIImage.init(data: imageData)
                    DispatchQueue.main.async {
                        self.viewObj = model
                        self.profileImageView.image = image
                    }
                    
                }catch let error {
                    print(error.localizedDescription)
                }
            }
            
            if model.viewName != nil && model.viewName != "" {
                DispatchQueue.main.async {
                    self.viewObj = model
                    self.nameLabel.text = model.viewName
                }
            }
            
            
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
