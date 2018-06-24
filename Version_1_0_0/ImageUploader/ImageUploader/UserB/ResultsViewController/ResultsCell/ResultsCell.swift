//
//  ResultsCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 05.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import Foundation
import UIKit

class ResultsCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    override func awakeFromNib() {
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.borderColor = UIColor.init(red: 85, green: 203, blue: 255).cgColor
        
    }
}
