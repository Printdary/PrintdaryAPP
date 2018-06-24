//
//  GoalTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 23.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import Firebase

class GoalTableViewCell: UITableViewCell {

    @IBOutlet weak var goalsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
        self.getGoas()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getGoas), name: Notification.Name.init("Reload_user_info"), object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func getGoas() {
        DispatchQueue.global(qos: .background).async {
            
         Database.database().reference().child("User").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                if let goals = dict["goals"] as? String {
                    DispatchQueue.main.async {
                        self.goalsLabel.text = goals
                    }
                }
            }
            }
            
        }
    }
    
    
}
