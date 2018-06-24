//
//  LEFSTableViewCell.swift
//  VideoCapture
//
//  Created by Armen Nikodhosyan on 08.11.17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import UIKit

class LEFSTableViewCell: UITableViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerFirstLabel: UILabel!
    @IBOutlet weak var answerSecondLabel: UILabel!
    @IBOutlet weak var answerThirdLabel: UILabel!
    @IBOutlet weak var ansewFourthLabel: UILabel!
    @IBOutlet weak var answerFifthLabel: UILabel!
    @IBOutlet weak var answerFirstImage: UIImageView!
    @IBOutlet weak var answerSecondImage: UIImageView!
    @IBOutlet weak var answerThirdImage: UIImageView!
    @IBOutlet weak var answerFourthImage: UIImageView!
    @IBOutlet weak var answerFifthImage: UIImageView!
    var index: Int?
    var answerPressed:((_ score: Int, _ cell : LEFSTableViewCell )->Void)?
    var cellScore = -1
    
    
    
    func setupCellWith(question:String,answerFirst: String, answerSecond: String, answerThird: String,
                       answerFourth: String, answerFifth: String, cellIndex: Int, answer : Int) {
        
        self.questionLabel.text     = question
        self.answerFirstLabel.text  = answerFirst
        self.answerSecondLabel.text = answerSecond
        self.answerThirdLabel.text  = answerThird
        self.ansewFourthLabel.text  = answerFourth
        self.answerFifthLabel.text  = answerFifth
        self.index = cellIndex
        switch answer {
        case 0:
            self.answerFirstImage.image = UIImage.init(named:"ptichka_verev")
            self.answerSecondImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerThirdImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerFourthImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerFifthImage.image = UIImage.init(named: "ptichka_verev_2")
            break
        case 1:
            self.answerFirstImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerSecondImage.image = UIImage.init(named:"ptichka_verev")
            self.answerThirdImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerFourthImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerFifthImage.image = UIImage.init(named: "ptichka_verev_2")
            break
        case 2:
            self.answerFirstImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerSecondImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerThirdImage.image = UIImage.init(named:"ptichka_verev")
            self.answerFourthImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerFifthImage.image = UIImage.init(named: "ptichka_verev_2")
            break
        case 3:
            self.answerFirstImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerSecondImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerThirdImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerFourthImage.image = UIImage.init(named:"ptichka_verev")
            self.answerFifthImage.image = UIImage.init(named: "ptichka_verev_2")
            break
        case 4:
            self.answerFirstImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerSecondImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerThirdImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerFourthImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerFifthImage.image = UIImage.init(named: "ptichka_verev")
            break
        
            
        default:
            self.answerFirstImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerSecondImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerThirdImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerFourthImage.image = UIImage.init(named:"ptichka_verev_2")
            self.answerFifthImage.image = UIImage.init(named: "ptichka_verev_2")
            break
        }
        
    }
    
    
    @IBAction func answerFirstAction(_ sender: UIButton) {
        if sender.tag == 0 {
            DispatchQueue.main.async {
                 self.answerFirstImage.image = UIImage.init(named: "ptichka_verev")
                 self.answerSecondImage.image = UIImage.init(named: "ptichka_verev_2")
                 self.answerThirdImage.image = UIImage.init(named: "ptichka_verev_2")
                 self.answerFourthImage.image = UIImage.init(named: "ptichka_verev_2")
                 self.answerFifthImage.image = UIImage.init(named: "ptichka_verev_2")
                 sender.tag = 1
                self.cellScore = 1
                self.answerPressed?(0, self)
            }
           
        } else {
            DispatchQueue.main.async {
                 self.answerFirstImage.image = UIImage.init(named: "ptichka_verev_2")
                 sender.tag = 0
                 self.answerPressed?(0, self)
                self.cellScore = -1
            }
        }
        
    }
    @IBAction func answerSecondAction(_ sender: UIButton) {
        if sender.tag == 0 {
            DispatchQueue.main.async {
                self.cellScore = 1
                self.answerSecondImage.image = UIImage.init(named: "ptichka_verev")
                self.answerFirstImage.image = UIImage.init(named: "ptichka_verev_2")
                self.answerThirdImage.image = UIImage.init(named: "ptichka_verev_2")
                self.answerFourthImage.image = UIImage.init(named: "ptichka_verev_2")
                self.answerFifthImage.image = UIImage.init(named: "ptichka_verev_2")
                sender.tag = 1
                
                self.answerPressed?(1, self)
            }
            
        } else {
             DispatchQueue.main.async {
                self.answerSecondImage.image = UIImage.init(named: "ptichka_verev_2")
                sender.tag = 0
                self.answerPressed?(0,self)
                self.cellScore = -1
            }
        }
    }
    @IBAction func answerThirdAction(_ sender: UIButton) {
        if sender.tag == 0 {
            DispatchQueue.main.async {
                self.cellScore = 1
                self.answerThirdImage.image = UIImage.init(named: "ptichka_verev")
                self.answerFirstImage.image = UIImage.init(named: "ptichka_verev_2")
                self.answerSecondImage.image = UIImage.init(named: "ptichka_verev_2")
                self.answerFourthImage.image = UIImage.init(named: "ptichka_verev_2")
                self.answerFifthImage.image = UIImage.init(named: "ptichka_verev_2")
                sender.tag = 1
                
                self.answerPressed?(2, self)
            }
            
        } else {
            
            DispatchQueue.main.async {
                self.answerThirdImage.image = UIImage.init(named: "ptichka_verev_2")
                sender.tag = 0
                self.answerPressed?(0, self)
                self.cellScore = -1
            }
        }
    }
    @IBAction func answerFourthAction(_ sender: UIButton) {
        if sender.tag == 0 {
            DispatchQueue.main.async {
                self.cellScore = 1
                self.answerFourthImage.image = UIImage.init(named: "ptichka_verev")
                self.answerFirstImage.image = UIImage.init(named: "ptichka_verev_2")
                self.answerSecondImage.image = UIImage.init(named: "ptichka_verev_2")
                self.answerThirdImage.image = UIImage.init(named: "ptichka_verev_2")
                self.answerFifthImage.image = UIImage.init(named: "ptichka_verev_2")
                sender.tag = 1
                
                self.answerPressed?(3, self)
            }
            
        } else {
             DispatchQueue.main.async {
               self.answerFourthImage.image = UIImage.init(named: "ptichka_verev_2")
               sender.tag = 0
                self.answerPressed?(0,self)
                self.cellScore = -1
            }
        }
    }
    @IBAction func answerFifthAction(_ sender: UIButton) {
        if sender.tag == 0 {
            DispatchQueue.main.async {
                self.cellScore = 1
                self.answerFifthImage.image = UIImage.init(named: "ptichka_verev")
                self.answerFirstImage.image = UIImage.init(named: "ptichka_verev_2")
                self.answerSecondImage.image = UIImage.init(named: "ptichka_verev_2")
                self.answerThirdImage.image = UIImage.init(named: "ptichka_verev_2")
                self.answerFourthImage.image = UIImage.init(named: "ptichka_verev_2")
                sender.tag = 1
                
                self.answerPressed?(4, self)
            }
            
        } else {
            DispatchQueue.main.async {
                self.answerFifthImage.image = UIImage.init(named: "ptichka_verev_2")
                sender.tag = 0
                self.answerPressed?(0, self)
                self.cellScore = -1
            }
        }
    }
}
