//
//  MeunView.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 25.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit

class MenuView: UIView {
    
    
    override func awakeFromNib() {
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        self.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBAction func newTopichButtonAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name.init("NEW_TOPIC"), object: nil, userInfo: nil)
    }
    @IBAction func newChapterButtonAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name.init("NEW_Chapter"), object: nil, userInfo: nil)
    }
    
    @IBAction func newUnitButtonAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name.init("NEW_UNIT"), object: nil, userInfo: nil)
    }
}
