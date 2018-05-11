//
//  LEFSDataCallculationViewController.swift
//  VideoCapture
//
//  Created by Armen Nikodhosyan on 08.11.17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import Foundation
import UIKit
var scoreArry = [0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01];
class LEFSDataCallculationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var scoreLabel: UILabel!
    var scoreCount = 0;
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var scoreTextfield: UITextField!
    let questionsArray = ["Any of your usual work, housework, or school activities",
                          "Your usual hobbies, re creational or sporting activities",
                          "Getting into or out of the bath.",
                          "Walking between rooms.",
                          "Putting on your shoes or socks.",
                          "Squatting.",
                          "Lifting an object, like a bag of groceries from the floor.",
                          "Performing light activities around your home",
                          "Performing heavy activities around your home",
                          "Getting into or out of a car.",
                          "Walking 2 blocks.",
                          "Walking a mile.",
                          "Going up or down 10 stairs (about 1 flight of stairs).",
                          "Standing for 1 hour.",
                          "Sitting for 1 hour.",
                          "Running on even ground.",
                          "Running on uneven ground.",
                          "Making sharp turns while running fast",
                          "Hopping.",
                          "Rolling over in bed."
        
    ];
    
    override func viewDidLoad() {
        
    }
    
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override func viewWillAppear(_ animated: Bool) {
        //self.tableView.reloadData()
        LEFSValue = 40.0
       // scoreLabel.text = ""
        scoreTextfield.text = ""
        self.navigationController?.navigationBar.isHidden = true
        scoreTextfield.delegate = self
        self.setupTextFields(textField: scoreTextfield)
    }
    
    
    
    //MARK: UITableViewDelegate, UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height/2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LEFSTableViewCell
        var answer = -1;
        if scoreArry[indexPath.row] != 0.01 {
            answer = Int(scoreArry[indexPath.row])
        }
        cell.setupCellWith(question: questionsArray[indexPath.row],
                           answerFirst: "Extreme Difficulty or Unable to Perform Activity",
                           answerSecond: "Quite a Bit of Difficulty",
                           answerThird: "Moderate  Difficulty",
                           answerFourth: "A Little Bit of Difficulty",
                           answerFifth: "No Difficulty",
                           cellIndex : indexPath.row,
                           answer : answer)
        
        cell.answerPressed = {[unowned self] (score, cell) in
            print(cell.cellScore,   self.scoreCount)
            scoreArry[cell.index!] = Double(score)
            let totalSum = scoreArry.map({$0}).reduce(0, +)
            DispatchQueue.main.async {
                let sum = Int(totalSum)
                self.scoreLabel.text =  "\(sum)"
                LEFSValue = Double(totalSum)
            }
        }
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func doneTextField() {
        if scoreTextfield.text != "" {
            LEFSValue = Double.init(scoreTextfield.text!)!
        } else {
        LEFSValue = 40.0
        }
        self.view.endEditing(true)
    }
    
    func setupTextFields(textField: UITextField) {
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTextField))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([spaceButton,doneButton], animated: false)
        // add toolbar to textField
        textField.inputAccessoryView = toolbar
    }
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let sessionController = storyboard.instantiateViewController(withIdentifier: "navVC")
        let appObj = UIApplication.shared.delegate as! AppDelegate
        appObj.window?.rootViewController =  sessionController
      
    }
}
