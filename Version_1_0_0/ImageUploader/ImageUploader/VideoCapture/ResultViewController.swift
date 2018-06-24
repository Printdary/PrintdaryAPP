//
//  ResultViewController.swift
//  VideoCapture
//
//  Created by Armen Nikodhosyan on 10.11.17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import UIKit
import CircleProgressBar
import MessageUI
import Firebase

@available(iOS 10.0, *)
class ResultViewController: UIViewController , MFMailComposeViewControllerDelegate{
    var linkURL: [String] = Array(repeating: "", count: 12)
    
    
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var repsTopLabel: UILabel!
    @IBOutlet weak var setsTopLabel: UILabel!
    @IBOutlet weak var frequencyTopLabel: UILabel!
    
    
    @IBOutlet weak var repsMidleLabel: UILabel!
    @IBOutlet weak var setsMidleLabel: UILabel!
    @IBOutlet weak var frequencyMidleLabel: UILabel!
    
    
    @IBOutlet weak var repsBottomLabel: UILabel!
    @IBOutlet weak var setsBottomLabel: UILabel!
    @IBOutlet weak var frequencyBottomLabel: UILabel!
    
    
    @IBOutlet weak var assessmentLabel: UILabel!
    
    @IBOutlet weak var weaknessSeverityLevelLabel: UILabel!
   
    
    @IBOutlet weak var exercise1: UIButton!
    @IBOutlet weak var exercise2: UIButton!
    @IBOutlet weak var exercise3: UIButton!
    @IBOutlet weak var progressBar: CircleProgressBar!
    let appObj = UIApplication.shared.delegate as! AppDelegate
    
    var score : Double = 0
    override func viewDidLoad() {
        self.backImageView.layer.cornerRadius = self.backImageView.frame.size.width/2
        self.backImageView.layer.borderColor = UIColor.red.cgColor
        self.backImageView.layer.borderWidth = 1
        self.exercise1.titleLabel?.lineBreakMode = .byWordWrapping
        self.exercise1.titleLabel?.textAlignment = .center
        
        self.exercise2.titleLabel?.lineBreakMode = .byWordWrapping
        self.exercise2.titleLabel?.textAlignment = .center
        
        self.exercise3.titleLabel?.lineBreakMode = .byWordWrapping
        self.exercise3.titleLabel?.textAlignment = .center
    }
    
    override func viewDidDisappear(_ animated: Bool) {
         WSItems = Array(repeating: 0, count: 100)
         diagnosisItems = Array(repeating: "", count: 100)
         duplicateItemsQty = Array(repeating: 0, count: 100)
         totalDiagnosisItems = 0
         LEFSValue = 40.0

    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
  
        if totalDiagnosisItems > 0 {
            for index in 0...totalDiagnosisItems - 1 {
                WSItems[index] = (WSItems[index]/Double(duplicateItemsQty[index])*1000).rounded()/1000
            }
            //Sort in descending order and pick the top 3 diagnosis items by firing strength for the display
            var tempFSItem: Double = 0.0
            var tempDuplicateQty: Int = 0
            var tempDiagItem: String = ""
            
            for i in 0...totalDiagnosisItems - 1 {
                for j in 0...totalDiagnosisItems - i - 1 {
                    if WSItems[j] < WSItems[j+1] {
                        tempFSItem = WSItems[j]
                        tempDiagItem = diagnosisItems[j]
                        tempDuplicateQty = duplicateItemsQty[j]
                        WSItems[j] = WSItems[j+1]
                        diagnosisItems[j] = diagnosisItems[j+1]
                        duplicateItemsQty[j] = duplicateItemsQty[j+1]
                        WSItems[j+1] = tempFSItem
                        diagnosisItems[j+1] = tempDiagItem
                        duplicateItemsQty[j+1] = tempDuplicateQty
                        
                        // Re-order within same firing strength so that diagnosis with 'Hip' and 'Low Back' take higher priority within the order
                    } else if WSItems[j] == WSItems[j+1] && (diagnosisItems[j].range(of: "Hip") == nil && diagnosisItems[j].range(of:"Low Back") == nil) && (diagnosisItems[j+1].contains("Hip") || diagnosisItems[j+1].contains("Low Back")) {
                        
                        tempFSItem = WSItems[j]
                        tempDiagItem = diagnosisItems[j]
                        tempDuplicateQty = duplicateItemsQty[j]
                        WSItems[j] = WSItems[j+1]
                        diagnosisItems[j] = diagnosisItems[j+1]
                        duplicateItemsQty[j] = duplicateItemsQty[j+1]
                        WSItems[j+1] = tempFSItem
                        diagnosisItems[j+1] = tempDiagItem
                        duplicateItemsQty[j+1] = tempDuplicateQty
                    }
                }
            }
            
            // Determining ZScore (determined by average of top 5 weakness values) and then display final score on screen
            var zscoreAvg: Double = 0.0
            for i in 0...totalDiagnosisItems - 1 {
                zscoreAvg = zscoreAvg + WSItems[i]
            }
            zscoreAvg = (1-(zscoreAvg / Double(totalDiagnosisItems)*1000).rounded()/1000)*100
            
            let avgWSString = NSMutableAttributedString(string: String(describing: String(zscoreAvg)))
            let rangezscore = (String(zscoreAvg) as NSString).range(of: String(zscoreAvg))
            if zscoreAvg <= 30.0 {
                avgWSString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: rangezscore)
            } else if zscoreAvg > 30.0 && zscoreAvg < 70.0 {
                avgWSString.addAttribute(UIKit.NSAttributedStringKey.foregroundColor, value: UIColor.orange, range: rangezscore)
            } else {
                avgWSString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.blue, range: rangezscore)
            }
            //zscore.attributedText = avgWSString
            print("avgWSString = \(avgWSString)")
            let val = Double.init(avgWSString.string)
            print("val = \(val)")
            self.score = zscoreAvg
            DispatchQueue.main.async {
                print("zscoreAvg = \(zscoreAvg)")
                self.progressBar.setProgress(CGFloat(zscoreAvg/100), animated: true)
            }
           
            
            // Show Lower Extremity Functional Scale value (LEFS)
            let LEFSString = NSMutableAttributedString(string: String(describing: String(LEFSValue)))
            let rangeLEFS = (String(LEFSValue) as NSString).range(of: String(LEFSValue))
            if LEFSValue <= 25.0 {
                LEFSString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: rangeLEFS)
            } else if LEFSValue > 25.0 && LEFSValue < 50.0 {
                LEFSString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.orange, range: rangeLEFS)
            } else {
                LEFSString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.blue, range: rangeLEFS)
            }
           
            
            // Color code red for intensity level greater than or = to .75, orange for intensity level between .3 - .75, and blue for intensity level less than .3
            let tempAssessment = NSMutableAttributedString()
            let tempWS = NSMutableAttributedString()
            for i in 0...2 {
                let myMutableString = NSMutableAttributedString(string: String(describing: diagnosisItems[i]))
                let myMutableWS = NSMutableAttributedString(string: String(describing: String(WSItems[i])))
                
                let range = (diagnosisItems[i] as NSString).range(of: diagnosisItems[i])
                let rangeWS = (String(WSItems[i]) as NSString).range(of: String(WSItems[i]))
                if WSItems[i] >= 0.7 {
                    myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: range)
                    myMutableWS.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: rangeWS)
                    tempAssessment.append(myMutableString)
                    tempWS.append(myMutableWS)
                    tempAssessment.append(NSMutableAttributedString(string: "\n"))
                    tempWS.append(NSMutableAttributedString(string: "\n"))
                } else if WSItems[i] >= 0.3 && WSItems[i] < 0.7 {
                    myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.orange, range: range)
                    myMutableWS.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.orange, range: rangeWS)
                    tempAssessment.append(myMutableString)
                    tempWS.append(myMutableWS)
                    tempAssessment.append(NSMutableAttributedString(string: "\n"))
                    tempWS.append(NSMutableAttributedString(string: "\n"))
                } else {
                    myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.blue, range: range)
                    myMutableWS.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.blue, range: rangeWS)
                    tempAssessment.append(myMutableString)
                    tempWS.append(myMutableWS)
                    tempAssessment.append(NSMutableAttributedString(string: "\n"))
                    tempWS.append(NSMutableAttributedString(string: "\n"))
                }
                
            }
            print("mut = \(tempAssessment.string)")
            weaknessSeverityLevelLabel.attributedText = tempWS
            assessmentLabel.attributedText = tempAssessment
            //assessmentLabel.text = tempAssessment.string
            
            var WSTVP: [[Double]] = [[0,0,0], [0,0,0], [0,0,0]]
            var BPM: [[Double]] = [[0.2,0.4,0.6,0.8], [5,8,18,22,31,34,44,47,55,62,70]]
            var refItems: [Double] = Array(repeating: 0, count: 100)
            // Find the Weakness Severity Truth Value Proposition (WSTVP)
            
            for i in 0...2 {
                var j = 0
                
                // Need to capture the complement of weakness level (1 - weakness level) rather than using actual weakness level
                
                refItems[i] = 1 - WSItems[i]
                
                // Calculate Positive Severe (NS)
                if refItems[i] <= BPM[0][0] {
                    WSTVP[i][j] = 1
                } else if refItems[i] >= BPM[0][0] && refItems[i] <= BPM[0][1] {
                    WSTVP[i][j] = 1.0 - (refItems[i] - BPM[0][0]) / (BPM[0][1] - BPM[0][0])
                } else if refItems[i] >= BPM[0][1] {
                    WSTVP[i][j] = 0
                }
                // Calculate Normal (NR)
                j += 1
                if refItems[i] <= BPM[0][0] {
                    WSTVP[i][j] = 0
                } else if refItems[i] >= BPM[0][0] && refItems[i] <= BPM[0][1] {
                    WSTVP[i][j] = (refItems[i] - BPM[0][0])/(BPM[0][1] - BPM[0][0])
                } else if refItems[i] > BPM[0][1] && refItems[i] <= BPM[0][2] {
                    WSTVP[i][j] = 1
                } else if refItems[i] >= BPM[0][2] && refItems[i] <= BPM[0][3] {
                    WSTVP[i][j] = 1.0 - (refItems[i] - BPM[0][2])/(BPM[0][3] - BPM[0][2])
                } else if refItems[i] >= BPM[0][3] {
                    WSTVP[i][j] = 0
                }
                // Calculate Negative Severe (PS)
                j += 1
                if refItems[i] <= BPM[0][2] {
                    WSTVP[i][j] = 0
                } else if refItems[i] >= BPM[0][2] && refItems[i] <= BPM[0][3] {
                    WSTVP[i][j] = (refItems[i] - BPM[0][2])/(BPM[0][3] - BPM[0][2])
                } else if refItems[i] >= BPM[0][3] && refItems[i] <= 1.0 {
                    WSTVP[i][j] = 1
                }
            }
            
            // Calculate Truth Value Propositions for LEFS (LEFSTVP)
            var LEFSTVP: [[Double]] = [[0,0,0,0,0,0], [0,0,0,0,0,0], [0,0,0,0,0,0]]
            for i in 0...2 {
                var j = 0
                
                // Calculate TVP if LEFS (LEFSValue) is very low (5-15)
                if LEFSValue >= BPM[1][0] && LEFSValue <= BPM[1][1] {
                    LEFSTVP[i][j] = 1
                } else if LEFSValue >= BPM[1][1] && LEFSValue <= BPM[1][2] {
                    LEFSTVP[i][j] = 1 - (LEFSValue - BPM[1][1]) / (BPM[1][2] - BPM[1][1])
                } else if LEFSValue >= BPM[1][2] {
                    LEFSTVP[i][j] = 0
                }
                
                // Calculate TVP if LEFS (LEFSValue) is Low (16-25)
                j += 1
                if LEFSValue <= BPM[1][1] {
                    LEFSTVP[i][j] = 0
                } else if LEFSValue >= BPM[1][1] && LEFSValue <= BPM[1][2] {
                    LEFSTVP[i][j] = (LEFSValue - BPM[1][1])/(BPM[1][2] - BPM[1][1])
                } else if LEFSValue >= BPM[1][2] && LEFSValue <= BPM[1][3] {
                    LEFSTVP[i][j] = 1
                } else if LEFSValue >= BPM[1][3] && LEFSValue <= BPM[1][4] {
                    LEFSTVP[i][j] = 1 - (LEFSValue - BPM[1][3]) / (BPM[1][4] - BPM[1][3])
                } else if LEFSValue >= BPM[1][4] {
                    LEFSTVP[i][j] = 0
                }
                
                // Calculate TVP if LEFS (LEFSValue) is Low Average (26 - 37)
                j += 1
                if LEFSValue <= BPM[1][3] {
                    LEFSTVP[i][j] = 0
                } else if LEFSValue >= BPM[1][3] && LEFSValue <= BPM[1][4] {
                    LEFSTVP[i][j] = (LEFSValue - BPM[1][3])/(BPM[1][4] - BPM[1][3])
                } else if LEFSValue >= BPM[1][4] && LEFSValue <= BPM[1][5] {
                    LEFSTVP[i][j] = 1
                } else if LEFSValue >= BPM[1][5] && LEFSValue <= BPM[1][6] {
                    LEFSTVP[i][j] = 1 - (LEFSValue-BPM[1][5])/(BPM[1][6]-BPM[1][5])
                } else if LEFSValue >= BPM[1][6] {
                    LEFSTVP[i][j] = 0
                }
                
                // Calculate TVP if LEFS (LEFSValue) is High Average (38 - 49)
                j += 1
                if LEFSValue <= BPM[1][5] {
                    LEFSTVP[i][j] = 0
                } else if LEFSValue >= BPM[1][5] && LEFSValue <= BPM[1][6] {
                    LEFSTVP[i][j] = (LEFSValue - BPM[1][5])/(BPM[1][6] - BPM[1][5])
                } else if LEFSValue >= BPM[1][6] && LEFSValue <= BPM[1][7] {
                    LEFSTVP[i][j] = 1
                } else if LEFSValue >= BPM[1][7] && LEFSValue <= BPM[1][8] {
                    LEFSTVP[i][j] = 1 - (LEFSValue - BPM[1][7])/(BPM[1][8]-BPM[1][7])
                } else if LEFSValue >= BPM[1][8] {
                    LEFSTVP[i][j] = 0
                }
                
                // Calculate TVP if LEFS (LEFSValue) is High (50 - 69)
                j += 1
                if LEFSValue <= BPM[1][7] {
                    LEFSTVP[i][j] = 0
                } else if LEFSValue >= BPM[1][7] && LEFSValue <= BPM[1][8] {
                    LEFSTVP[i][j] = (LEFSValue - BPM[1][7])/(BPM[1][8] - BPM[1][7])
                } else if LEFSValue >= BPM[1][8] && LEFSValue <= BPM[1][9] {
                    LEFSTVP[i][j] = 1
                } else if LEFSValue >= BPM[1][9] && LEFSValue <= BPM[1][10] {
                    LEFSTVP[i][j] = 1 - (LEFSValue - BPM[1][9])/(BPM[1][10] - BPM[1][9])
                } else if LEFSValue >= BPM[1][10] {
                    LEFSTVP[i][j] = 0
                }
                
                // Calculate TVP if LEFS (LEFSValue) is Very High (70+)
                j += 1
                if LEFSValue <= BPM[1][9] {
                    LEFSTVP[i][j] = 0
                } else if LEFSValue >= BPM[1][9] && LEFSValue <= BPM[1][10] {
                    LEFSTVP[i][j] = (LEFSValue - BPM[1][9]) / (BPM[1][10] - BPM[1][9])
                } else if LEFSValue >= BPM[1][10] {
                    LEFSTVP[i][j] = 1
                }
            }
            // Retrieve information from csv file to permanently store data
            // Get Number of Sets, Number of Repititions, and Frequency of Exercises from Exercise Matrix file
            let exerciseMatrix = getCSV(filename: "ExerciseMatrix")
            var exSets = Array(repeating: 0, count: exerciseMatrix.rowsQty)
            var exReps = Array(repeating: 0, count: exerciseMatrix.rowsQty)
            var exFreq = Array(repeating: 0.0, count:exerciseMatrix.rowsQty)
            
            for index in 0...exerciseMatrix.rowsQty-1 {
                exSets[index] = Int(exerciseMatrix.CSVString[index][0])!
                exReps[index] = Int(exerciseMatrix.CSVString[index][1])!
                exFreq[index] = Double(exerciseMatrix.CSVString[index][2])!
            }
            
            var assessFS: [[Double]] = [[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]]
            var assessSets: [Double] = [0,0,0]
            var assessReps: [Double] = [0,0,0]
            var assessFreq: [Double] = [0,0,0]
            var maxFSRow: [Int] = [0,0,0]
            var tempSets: Double = 0.0
            var tempReps: Double = 0.0
            var tempFreq: Double = 0.0
            var count = 0
            
            // For each assessment, calculate the Firing Strength by capturing the product when comparing LEFSTVP[1] with WSVTVP[1]; LEFSTVP[1] with WSVTPV[2], etc.
            for i in 0...2 {
                count = 0
                tempSets = 0.0
                tempReps = 0.0
                tempFreq = 0.0
                for j in 0...5 {
                    for k in 0...2 {
                        assessFS[i][count] = LEFSTVP[i][j] * WSTVP[i][k]
                        
                        // Add the sets, reps, and frequency for each assessment
                        tempSets = tempSets + assessFS[i][count] * Double(exSets[count])
                        tempReps = tempReps + assessFS[i][count] * Double(exReps[count])
                        tempFreq = tempFreq + assessFS[i][count] * exFreq[count]
                        
                        // Find the row that has the maximum firing strength for each assessment
                        if assessFS[i][count] > assessFS[i][maxFSRow[i]] {
                            maxFSRow[i] = count
                        }
                        count += 1
                    }
                }
                assessSets[i] = tempSets
                assessReps[i] = tempReps
                assessFreq[i] = tempFreq
                
                // Determine the LEFS - Low, Medium, High on the Exercises data sheet
                if maxFSRow[i] > 2 {
                    maxFSRow[i] = maxFSRow[i] - 3
                    if maxFSRow[i] > 5 {
                        maxFSRow[i] = maxFSRow[i] - 3
                        if maxFSRow[i] > 8 {
                            maxFSRow[i] = maxFSRow[i] - 3
                        }
                    }
                }
            }
            
            // Get exercises for each assessment organized by Low Extremity Functional Scale (LEFS) Values and Weakness Severity Values
            let exerciseList = getCSV(filename: "Exercises")
            
            var assessmentVal: [String] = Array(repeating: "", count: exerciseList.rowsQty)
            var exVal = Array<Array<String>>()
            
            // Initialize the double array to empty values
            for _ in 0...exerciseList.rowsQty {
                exVal.append(Array(repeating: String(), count: 9))
            }
            for index in 0...exerciseList.rowsQty-3 {
                var oneLine = exerciseList.CSVString[index]
                assessmentVal[index] = oneLine[0]
                oneLine.removeFirst()
                for i in 0...8 {
                    exVal[index][i] = oneLine[i]
                }
            }
            // Match the assessment values with the diagnosis item from the ExercisesTKA and capture the exercises from appropriate row using maxFSRow
            var displayExVal:[String] = ["","",""]
            for index in 0...2 {
                for i in 0...exerciseList.rowsQty - 1 {
                    if diagnosisItems[index] == assessmentVal[i] {
                        displayExVal[index] = exVal[i][maxFSRow[index]]
                    }
                }
            }
            
            var tempItem: [[String]] = [[""],[""],[""]]
            for i in 0...2 {
                if displayExVal[i].contains("\r") {
                    var singleLine = displayExVal[i].components(separatedBy: "\r")
                    // Clean up exercise values and remove characters '\"' from the exercises from each item
                    for index in 0...singleLine.count - 1 {
                        singleLine[index] = singleLine[index].replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
                    }
                    tempItem[i] = singleLine
                } else {
                    tempItem[i] = [displayExVal[i]]
                }
            }
            
            // Remove duplicate exercises if they already exist. Compare top row with the next two rows and 2nd row with last.
            for index in 0...1 {
                if tempItem[index].count > 0 {
                    for i in 0...tempItem[index].count - 1{
                        // De-dupe from 1st assessment to 2nd assessment; 1st assessment to 3rd assessment; 2nd assessment to 3rd assessment
                        if tempItem[index+1].count > 0 {
                            for j in 0...tempItem[index+1].count - 1{
                                if tempItem[index][i] == tempItem[index+1][j] {
                                    tempItem[index+1].remove(at: 0)
                                }
                                if index == 0 {
                                    if tempItem[index][i] == tempItem[index+2][j] {
                                        tempItem[index+2].remove(at: 0)
                                    } else if tempItem[index+1].count == 0 {
                                        tempItem[index+1] = tempItem[index+2]
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Retrieve hyperlinks associated with exercises from csv file regarding hyperlinks for exercises
            let exerciseUniqueList = getCSV(filename: "ExerciseLinks")
            
            // Incorporate the non duplicate exercises to be displayed on the screen
            var exerciseDisplay: [String] = Array(repeating: "", count: 12)
            var containsStretchOrtho: [Bool] = [false, false, false]
            var counter = 0
            // Identify unique exercise values with corresponding URLs
            for i in 0...2 {
                if tempItem[i].count > 0 {
                    for j in 0...tempItem[i].count - 1 {
                        if j < tempItem[i].count {
                            exerciseDisplay[counter] = tempItem[i][j]
                            for index in 0...exerciseUniqueList.rowsQty - 1 {
                                if exerciseDisplay[counter] == exerciseUniqueList.CSVString[index][0] {
                                    linkURL[counter] = exerciseUniqueList.CSVString[index][1]
                                }
                            }
                            counter += 1
                            if tempItem[i][j].contains("Stretch") || tempItem[i][j].contains("Orthotics") {
                                containsStretchOrtho[i] = true
                            }
                            
                        }
                    }
                }
            }
            // checking that all the values in exercise list are included in the hyperlink list
            /*        for i in 0...exerciseList.rowsQty - 1 {
             for j in 1...9 {
             var noValue = true
             if exerciseList.CSVString[i][j].characters.contains("\r"){
             let rows = exerciseList.CSVString[i][j].components(separatedBy: "\r")
             for row in rows {
             noValue = true
             var checkValue = row
             if checkValue.characters.contains("\"") {
             checkValue = checkValue.replacingOccurrences(of: "\"", with: "", options:NSString.CompareOptions.literal, range:nil)
             }
             for index in 0...exerciseUniqueList.rowsQty - 1 {
             if checkValue == exerciseUniqueList.CSVString[index][0] {
             noValue = false
             }
             }
             if noValue {
             print("\(i) \(j) \(checkValue) not listed in ExerciseLinks.csv")
             }
             }
             } else {
             for index in 0...exerciseUniqueList.rowsQty - 1 {
             if exerciseList.CSVString[i][j] == exerciseUniqueList.CSVString[index][0] {
             noValue = false
             }
             }
             if noValue {
             print("\(i) \(j) \(exerciseList.CSVString[i][j]) not listed in ExerciseLinks.csv")
             }                }
             }
             
             }
             
             */
            // Put the exercise values in each of the buttons and associated URL
            let button = [exercise1, exercise2, exercise3]
            for index in 0...counter - 1 {
                let ex = NSMutableAttributedString(string: exerciseDisplay[index])
                ex.addAttribute(.link, value: linkURL[index], range:NSRange(location:0, length:exerciseDisplay[index].count))
                button[index]?.setTitle(exerciseDisplay[index], for: .normal)
            }
            //Add the sets, reps, and frequency to the display
            var exerciseSets: [String] = ["","",""]
            var exerciseReps: [String] = ["","",""]
            var exerciseFreq: [String] = ["","",""]
            
            //check if 'Stretch' Exercise is the only exercise or there are several exercises, if several then combine the sets, reps, and frequency
            for i in 0...counter - 1 {
                if containsStretchOrtho[i] {
                    for j in 0...tempItem[i].count - 1 {
                        if tempItem[i][j].contains("Stretch") {
                            exerciseSets[i] = exerciseSets[i] + "1 Set"
                            exerciseReps[i] = exerciseReps[i] + "3 Reps. Hold for 15s"
                            exerciseFreq[i] = exerciseFreq[i] + "Atleast 2x Per Day"
                            
                        } else if tempItem[i][j].contains("Orthotics") {
                            exerciseSets[i] = exerciseSets[i] + "-"
                            exerciseReps[i] = exerciseReps[i] + "-"
                            exerciseFreq[i] = exerciseFreq[i] + "-"
                            
                        } else {
                            exerciseSets[i] = exerciseSets[i] + String(Int(round(assessSets[i])))
                            if Int(round(assessSets[i])) > 1 {
                                exerciseSets[i] = exerciseSets[i] + " Sets"
                            } else {
                                exerciseSets[i] = exerciseSets[i] + " Set"
                            }
                            exerciseReps[i] = exerciseReps[i] + String(Int(round(assessReps[i]))) + " Reps"
                            if assessFreq[i] < 1 {
                                exerciseFreq[i] = exerciseFreq[i] + String(Int(round(assessFreq[i]*7))) + "x Per Week"
                            } else {
                                exerciseFreq[i] = exerciseFreq[i] + String(Int(round(assessFreq[i]))) + "x Per Day"
                            }
                        }
                        if i <= 2 && j <= tempItem[i].count - 1 {
                            exerciseSets[i] = exerciseSets[i] + "\n"
                            exerciseReps[i] = exerciseReps[i] + "\n"
                            exerciseFreq[i] = exerciseFreq[i] + "\n"
                        }
                    }
                } else {
                    if tempItem[i].count > 0 {
                        for j in 0...tempItem[i].count - 1 {
                            exerciseSets[i] = exerciseSets[i] + String(Int(round(assessSets[i])))
                            if Int(round(assessSets[i])) > 1 {
                                exerciseSets[i] = exerciseSets[i] + " Sets"
                            } else {
                                exerciseSets[i] = exerciseSets[i] + " Set"
                            }
                            exerciseReps[i] = exerciseReps[i] + String(Int(round(assessReps[i]))) + " Reps"
                            if assessFreq[i] < 1 {
                                exerciseFreq[i] = exerciseFreq[i] + "Atleast " + String(Int(round(assessFreq[i]*7))) + "x Per Week"
                            } else {
                                exerciseFreq[i] = exerciseFreq[i] + "Atleast " + String(Int(round(assessFreq[i]))) + "x Per Day"
                            }
                            if i <= 2 && j <= tempItem[i].count - 1 {
                                exerciseSets[i] = exerciseSets[i] + "\n"
                                exerciseReps[i] = exerciseReps[i] + "\n"
                                exerciseFreq[i] = exerciseFreq[i] + "\n"
                            }
                        }
                    }
                    
                }
            }
            // Pad the Sets, Reps, and Frequency with additional lines for text alignment on display
 /*           if counter < 12 {
                for _ in 0...(11-counter) {
                    exerciseSets[2] = exerciseSets[2] + "\n"
                    exerciseReps[2] = exerciseReps[2] + "\n"
                    exerciseFreq[2] = exerciseFreq[2] + "\n"
                }
            }
 */
            // values to be displayed on screen
            setsTopLabel.text = exerciseSets[0]
            setsMidleLabel.text = exerciseSets[1]
            setsBottomLabel.text = exerciseSets[2]
            repsTopLabel.text = exerciseReps[0]
            repsMidleLabel.text = exerciseReps[1]
            repsBottomLabel.text = exerciseReps[2]
            frequencyTopLabel.text = exerciseFreq[0]
            frequencyMidleLabel.text = exerciseFreq[1]
            frequencyBottomLabel.text = exerciseFreq[2]
            
            
            
        } else {
            weaknessSeverityLevelLabel.text = "N/A"
            assessmentLabel.text = "Little to no muscle or joint weakness"
            exercise1.setTitle("Continue with your exercise routine", for:.normal)
            setsTopLabel.text = "0"
            repsTopLabel.text = "0"
            frequencyTopLabel.text = "0"
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func suggestedExerciseTopAction(_ sender: UIButton) {
        
        if linkURL[0] != "" {
            UIApplication.shared.open(URL(string:linkURL[0])!, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func suggestedExerciseMidleAction(_ sender: UIButton) {
        
        if linkURL[1] != "" {
            UIApplication.shared.open(URL(string:linkURL[1])!, options: [:], completionHandler: nil)
        }
    }
    
    @available(iOS 10.0, *)
    @IBAction func suggestedExerciseBottomAction(_ sender: UIButton) {
        
        if linkURL[2] != "" {
            UIApplication.shared.open(URL(string:linkURL[2])!, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        scoreArry = [0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01];
        LEFSValue = 40.0
        
        DispatchQueue.main.async {
          //  self.navigationController?.popToRootViewController(animated: true)
        }
    }
    func getCSV(filename: String) -> (rowsQty: Int, CSVString: [[String]]) {
        var rowsQty: Int = 0
        var CSVString: [[String]] = []
        
        guard let path = Bundle.main.url(forResource: filename, withExtension: "csv") else {
            print("File Read Error")
            return (rowsQty, CSVString)
        }
        do {
            let content = try String(contentsOf:path, encoding: String.Encoding.utf8)
            let rows = content.components(separatedBy: "\r\n")
            for row in rows {
                rowsQty += 1
                let columns = row.components(separatedBy: ",")
                CSVString.append(columns)
            }
            return (rowsQty,CSVString)
        } catch {
            print("File Data Error")
            return (rowsQty, CSVString)
        }
        
    }
    
    
    func getParticipationContentFormImage(siccess : @escaping (_ image: UIImage)->Void) {
    let sessionName = UserDefaults.standard.value(forKey: "sessionName") as? String
    let ref = Database.database().reference(fromURL: "https://zofie-15b4f.firebaseio.com/")
        
        let userReference = ref.child("users").child(Auth.auth().currentUser!.uid).child("ParticipantConsentForms").child(sessionName!)
        userReference.observeSingleEvent(of: .value, with: { (snapshot) in
            ref.removeAllObservers()
            print(snapshot)
            if snapshot.hasChild("ParticipantConsentForm") {
                if let value = snapshot.value as? [String : Any] {
                    let dawnloadPath  = value["ParticipantConsentForm"] as? String
                    let url = URL.init(string: dawnloadPath!)
                    do {
                        let imgData = try Data.init(contentsOf: url!)
                    let image = UIImage.init(data: imgData)
                        siccess(image!)
                    }catch let error {
                        print("error \(error.localizedDescription)")
                    }
                   
                }
            }
        })
    }
                    
        
    
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let image = UIImage.init(view: self.view)
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
    //    let filePath = Bundle.main.path(forResource:"ZsolutionzDisclaimer", ofType: "docx")
    mailComposerVC.setMessageBody("ZSOLUTIONZ DISCLAIMER: This Software Application DOES NOT Provide Medical Advice \n The information, including but not limited to, text, graphics, images, videos and other material contained in this email are for informational purposes only. The purpose of this information is to promote broad consumer understanding and knowledge of various smart health technologies and to improve individual health. It is not intended to be a substitute for professional medical advice, diagnosis or treatment. Always seek the advice of your physician or other qualified health care provider with any questions you may have regarding a medical condition or treatment and before undertaking a new health care regimen, and never disregard professional medical advice or delay in seeking it because of something you have read in this email. If you have any questions, please contact info@zsolutionz.com.", isHTML: false)
        
        self.getParticipationContentFormImage { image in
                mailComposerVC.addAttachmentData(UIImageJPEGRepresentation(image, 1)!, mimeType: "image/jpeg", fileName: "participantForm.jpeg")
            
        }
        
    //    let url = URL.init(fileURLWithPath: filePath!)
//        do {
//        let textData = try Data.init(contentsOf: url)
//        mailComposerVC.addAttachmentData(textData, mimeType: "text/docx", fileName: "Zsolutionz Disclaimer.docx")
//        }catch let error {
//            print("data reading ERROR\(error)")
//        }
        mailComposerVC.addAttachmentData(UIImageJPEGRepresentation(image, 1.0)!, mimeType: "image/jpeg", fileName: "results.jpeg")
        mailComposerVC.setSubject("Zofie Results")
        return mailComposerVC
    }
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController.init(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        sendMailErrorAlert.addAction(action)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        if result == .sent {
            self.showSendSuccessAlert()
        }else if result == .cancelled {
            
        }
        else {
            self.showSendMailErrorAlert()
        }
    }
    
    
    func showSendSuccessAlert() {
        
        let sendMailSuccessAlert = UIAlertController.init(title: "Mail successfully sented", message: "Information captured successfully", preferredStyle: .alert)
        let startOver = UIAlertAction.init(title: "Start Over", style: .default, handler: { (action)in
            self.navigationController?.popToRootViewController(animated: true)
        })
        
        let exit = UIAlertAction.init(title: "Exit", style: .destructive, handler: {(action) in
            
           NotificationCenter.default.post(name: Notification.Name("LogoutNotifikation"), object: nil)
            self.navigationController?.popToRootViewController(animated: true)
        })
        
        sendMailSuccessAlert.addAction(startOver)
        sendMailSuccessAlert.addAction(exit)
        self.present(sendMailSuccessAlert, animated: true, completion: nil)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}
