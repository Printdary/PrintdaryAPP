//
//  SearchTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 06.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var modelImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var modelName :String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
