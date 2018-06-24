//
//  ImprintTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 23.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit

class ImprintTableViewCell: UITableViewCell {
    
    @IBOutlet weak var editwidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewsWidthConstrint: NSLayoutConstraint!
    @IBOutlet var imprintMediaIcons: [UIImageView]!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imprintBaseImageView: UIImageView!
    @IBOutlet weak var publishedDayLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var moreButton: UIButton!
    var isSelectedCell = false
    var unitModel: UnitModel?
    var rootViewController: ProfileViewController?
    var index: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        logoImageView.layer.borderColor = UIColor.white.cgColor
        logoImageView.layer.borderWidth = 1
        viewsWidthConstrint.constant = 0
        editwidthConstraint.constant = 0
    }
    
    
    func setUnitModel(unitModel: UnitModel){
        self.unitModel = unitModel
        DispatchQueue.global(qos: .background).async {
            
        DispatchQueue.main.async {
            self.imprintBaseImageView.image = nil
        }
        if unitModel.imprintImage != nil {
            
            if let image = CacheHelper.sharid.getObjectForKey(key: (self.unitModel?.unitID)!)  {
                DispatchQueue.main.async {
                    self.imprintBaseImageView.image = image
                }
                
            } else {
                    do {
                    let imageData = try Data.init(contentsOf:unitModel.imprintImage!)
                    let image = UIImage.init(data: imageData)
                        CacheHelper.sharid.setObjectFor(key: (self.unitModel?.unitID)!, object: image!)
                        DispatchQueue.main.async {
                            self.imprintBaseImageView.image = image
                        }
                    } catch let error {
                        print(error.localizedDescription)
                    }
            }
        }
        if unitModel.title != nil {
            DispatchQueue.main.async {
            self.titleLabel.text = unitModel.title
            }
        }
            
       
        DispatchQueue.main.async {
            self.configurMediaIcons(model: self.unitModel)
            self.configureCreatedDate(interval: (self.unitModel?.createdDate)!)
        }
        
        }
    }
    
    func configureCreatedDate(interval: Double){
        let timeInterval = TimeInterval.init(interval)
        let createdDate = Date.init(timeIntervalSinceReferenceDate: timeInterval)
        let forrmater = DateFormatter.init()
        forrmater.dateStyle = .medium
        let strDate = forrmater.string(from: createdDate)
        self.publishedDayLabel.text = strDate
    }
    
    func configurMediaIcons(model: UnitModel?){
        if (model != nil) {
            if model?.unitAudio.count == 0 {
                self.imprintMediaIcons[0].alpha = 0.5
            }else{
                self.imprintMediaIcons[0].alpha = 1
            }
            if model?.unitImage.count == 0 {
                self.imprintMediaIcons[1].alpha = 0.5
            }
            else{
                self.imprintMediaIcons[1].alpha = 1
            }
            if model?.unitVideo.count == 0 {
                self.imprintMediaIcons[2].alpha = 0.5
            }else{
                self.imprintMediaIcons[2].alpha = 1
            }
            if model?.unitModel.count == 0 {
                self.imprintMediaIcons[3].alpha = 0.5
            }else{
                self.imprintMediaIcons[3].alpha = 1
            }
            if model?.unitUrl.count == 0 {
                self.imprintMediaIcons[4].alpha = 0.5
            }else{
                self.imprintMediaIcons[4].alpha = 1
            }
            if model?.unitState == "0" {
                logoImageView.image = UIImage.init(named: "draftIcon")
            }
            if model?.unitState == "1" {
                logoImageView.image = UIImage.init(named: "geography-512")
            }
        }
    }
    
    @IBAction func editButtonAction(_ sender: UIButton) {
        self.setSellectedStyle()
        CurrentSession.currentSession.title = ""
        CurrentSession.currentSession.category = ""
        CurrentSession.currentSession.note = ""
        CurrentSession.currentSession.croppedImage = nil
        
        if unitModel?.title != nil {
            CurrentSession.currentSession.title = (unitModel?.title)!
        }
        if unitModel?.category != nil {
            CurrentSession.currentSession.category = (unitModel?.category)!
        }
        
        if unitModel?.note != nil {
            CurrentSession.currentSession.note = (unitModel?.note)!
        }
        
        if unitModel?.imprintImage != nil {
            do {
                let imageData = try Data.init(contentsOf:(unitModel?.imprintImage)!)
                let image = UIImage.init(data: imageData)
                CurrentSession.currentSession.croppedImage = image
            }catch let error  {
                print(error.localizedDescription)
            }
        }
        
        CurrentSession.currentSession.videosArray.removeAll()
        if unitModel?.unitVideo != nil {
        if (unitModel?.unitVideo.count)! > 0 {
            
            CurrentSession.currentSession.videosArray = (unitModel?.unitVideo)!
        }
        }
        
         CurrentSession.currentSession.imageArray.removeAll()
        if unitModel?.unitImage != nil {
        if (unitModel?.unitImage.count)! > 0 {
           
            CurrentSession.currentSession.imageArray = (unitModel?.unitImage)!
           
        }
        }
        
        
        CurrentSession.currentSession.audioArray.removeAll()
        if unitModel?.unitAudio != nil {
        if (unitModel?.unitAudio.count)! > 0 {
            
            CurrentSession.currentSession.audioArray = (unitModel?.unitAudio)!
          
        }
        }
        CurrentSession.currentSession.urlArray.removeAll()
        if unitModel?.unitUrl != nil {
        if (unitModel?.unitUrl.count)! > 0 {
            
            CurrentSession.currentSession.urlArray = (unitModel?.unitUrl)!
            
        }
        }
        CurrentSession.currentSession.modelsArray.removeAll()
        if unitModel?.unitModel != nil {
        if (unitModel?.unitModel.count)! > 0 {
            CurrentSession.currentSession.modelsArray = (unitModel?.unitModel)!
            
        }
        }
        if unitModel?.unitID == nil || unitModel?.unitID == "" {
            print("---------------ERROR UNIT ID IS NiL------------")
            return
        }
        UserModel.currentUser.uploadID = (unitModel?.unitID)!
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "imprintVC") as! InprintTableViewController
        self.rootViewController?.present(vc, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func viewsButtonAction(_ sender: UIButton) {
        self.setSellectedStyle()
        let fView = Bundle.main.loadNibNamed("ViewsView", owner: ViewsView(), options: nil)?.first as! ViewsView
        fView.frame = (rootViewController?.view.frame)!
        fView.unitId = unitModel?.unitID
        rootViewController?.view.addSubview(fView)
        fView.getViewsList()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func moreButtonAction(_ sender: UIButton) {
        self.setSellectedStyle()
    }
    
    func setSellectedStyle(){
        if isSelectedCell {
             NotificationCenter.default.post(name: Notification.Name.init("REMOVE_BLUR"), object: nil, userInfo: nil)
            viewsWidthConstrint.constant = 0
            editwidthConstraint.constant = 0
            isSelectedCell = false
            return
        }
        let rect = self.rootViewController?.imprintsTableView.rectForRow(at: self.index!)
        let rectOfCellInSuperview = self.rootViewController?.imprintsTableView.convert(rect!, to: self.rootViewController?.imprintsTableView.superview)

        NotificationCenter.default.post(name: Notification.Name.init("ADD_BLUR_FOR_UNIT"), object: nil, userInfo: ["area": rectOfCellInSuperview])
        viewsWidthConstrint.constant = 40
        editwidthConstraint.constant = 40
        isSelectedCell = true
    }
}
