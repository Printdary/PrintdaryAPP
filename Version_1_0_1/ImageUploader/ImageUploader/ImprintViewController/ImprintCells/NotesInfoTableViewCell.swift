//
//  NotesInfoTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 16.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import DropDown


class NotesInfoTableViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var cambutton: UIButton!
    
    @IBOutlet weak var dawnLoadIcon: UIImageView!
    @IBOutlet weak var camIcon: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var foldetTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTestView: UITextView!
    @IBOutlet weak var noteBaseView: UIView!
    @IBOutlet weak var imprintImageView: UIImageView!
    var _rootViewController: InprintTableViewController?
    let dropDown = DropDown()
    let directoryDropDown = DropDown()
    var existingChapters = [ChapterModel]()
    var chapterNames = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        registerNotifications()
        titleTextField.delegate = self
        noteTestView.delegate = self
        noteBaseView.layer.cornerRadius = 10
        noteBaseView.layer.borderWidth = 1
        noteBaseView.layer.borderColor = UIColor.init(red: 25, green: 184, blue: 255).cgColor
        
        
    }
    
    
    func setupCell(){
        self.chapterNames.removeAll()
        titleTextField.text = CurrentSession.currentSession.title
        noteTestView.text = CurrentSession.currentSession.note
        categoryTextField.text = CurrentSession.currentSession.category
        if PathModel.shared.existingChapters != nil {
             self.existingChapters = PathModel.shared.existingChapters
            for chapter in existingChapters {
                self.chapterNames.append(chapter.name!)
            }
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        CurrentSession.currentSession.title = textField.text!
        return true
    }
    
    
    
    func setTextFields(){
        titleTextField.layer.borderColor = UIColor.gray.cgColor
        categoryTextField.layer.borderColor = UIColor.gray.cgColor
        foldetTextField.layer.borderColor = UIColor.gray.cgColor
        
        titleTextField.layer.borderWidth = 1
        categoryTextField.layer.borderWidth = 1
        foldetTextField.layer.borderWidth = 1
        
        titleTextField.layer.cornerRadius = 5
        categoryTextField.layer.cornerRadius = 5
        foldetTextField.layer.cornerRadius = 5
    }
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleResivedPhoto(userInfo:)), name: Notification.Name.init("CROP_PRESSED"), object: nil)
    }
    
    func setImprintImage(image: UIImage?){
        if image != nil {
        DispatchQueue.main.async {
            self.capturedImage.image = image
             self.capturedImage.isHidden = false
            self.camIcon.isHidden = true
            self.uploadButton.isHidden = true
            self.cambutton.isHidden = true
            self.dawnLoadIcon.isHidden = true
        }
        }
    }
    
    @IBAction func categoryDropDawnAction(_ sender: UIButton) {
        
        
        dropDown.anchorView = sender // UIView or UIBarButtonItem
        dropDown.dataSource = ["Math", "Science","Economics and Finance", "Arts & Humanities","Computing","Personal","Enginering", "Other"]
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.categoryTextField.text = item
            CurrentSession.currentSession.category =  self.categoryTextField.text!
            self.dropDown.hide()
        }
        
        // Will set a custom width instead of the anchor view width
        dropDown.width = sender.frame.size.width
        dropDown.show()
        
        
    }
    @objc func handleResivedPhoto(userInfo: Notification){
        if let info = userInfo.userInfo as? [String: Any]{
            if let image = info["cropedImage"] as? UIImage {
                CurrentSession.currentSession.croppedImage = image
            }
        }
        print("handleResivedPhoto")
    }
    
    @IBAction func directoryDropDawnAction(_ sender: UIButton) {
        directoryDropDown.anchorView = sender // UIView or UIBarButtonItem
        directoryDropDown.dataSource = self.chapterNames
        
        directoryDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.foldetTextField.text = item
            PathModel.shared.selectedChapter = self.existingChapters[index].chapterID
            self.directoryDropDown.hide()
        }
        
        // Will set a custom width instead of the anchor view width
        directoryDropDown.width = sender.frame.size.width
        directoryDropDown.show()
    }
   
    @IBAction func cameraButtonAction(_ sender: UIButton) {
            let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let vc = storyboard.instantiateViewController(withIdentifier: "CameraViewController")
            _rootViewController?.present(vc, animated: true, completion: nil)
    }
    
}



extension NotesInfoTableViewCell : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            UserDefaults.standard.set(textView.text, forKey: "note")
            UserDefaults.standard.synchronize()
            textView.resignFirstResponder()
            CurrentSession.currentSession.note = textView.text
            return false
        }
        return true
}
}
