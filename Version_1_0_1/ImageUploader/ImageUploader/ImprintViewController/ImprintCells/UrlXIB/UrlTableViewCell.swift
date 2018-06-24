//
//  UrlTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 16.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit

class UrlTableViewCell: UITableViewCell {

  
    @IBOutlet weak var baseView: UIView!
     var _rootViewController: InprintTableViewController?
    var index: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        baseView.layer.cornerRadius = 10
        baseView.layer.borderWidth = 1
        baseView.layer.borderColor = UIColor.init(red: 25, green: 184, blue: 255).cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(urlViewDelated(info:)), name: Notification.Name.init("URLVIEWDELETED"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop(info:)), name: Notification.Name.init("TextFieldDidBeginEditing"), object: nil)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func scrollToTop(info: Notification){
        self._rootViewController?.baseTableView.scrollToRow(at: index!, at: .top, animated: true)
//        let rect = self._rootViewController?.baseTableView.rectForRow(at: self.index!)
//        let rectOfCellInSuperview = self._rootViewController?.baseTableView.convert(rect!, to: self._rootViewController?.baseTableView.superview)
//        self._rootViewController?.baseTableView.scrollRectToVisible(rect!, animated: true)
    }
    
    @objc func urlViewDelated(info: Notification){
        if let info = info.userInfo as? [String: Any]{
            if let obj = info["urlObj"] as? UrlObject {
                if let index =  CurrentSession.currentSession.urlArray.index(of: obj) {
                    CurrentSession.currentSession.urlArray.remove(at: index)
                    self._rootViewController?.baseTableView.performBatchUpdates(nil, completion: { (ststus) in
                         self.setUrlViews(urls: CurrentSession.currentSession.urlArray)
                    })
                   
                }
            }
        }
        self._rootViewController?.baseTableView.performBatchUpdates(nil, completion: { (ststus) in
            self.setUrlViews(urls: CurrentSession.currentSession.urlArray)
        })
    }
    
    @IBAction func addUrlAction(_ sender: UIButton) {
        
        let urlObj = UrlObject()
        CurrentSession.currentSession.urlArray.append(urlObj)
        self._rootViewController?.baseTableView.performBatchUpdates({
        }, completion: { (status) in
            self.setUrlViews(urls: CurrentSession.currentSession.urlArray)
        })

    }
    
    
    
    func setUrlViews(urls: [UrlObject]) {
        for obj in self.baseView.subviews {
            if obj.isKind(of: UrlView.self) {
                obj.removeFromSuperview()
            }
        }
        if urls.count == 0 {
            return
        }
        for obj in  1...urls.count { //CGFloat.init(obj) * 60
            let urlViewNib = Bundle.main.loadNibNamed("eUrlView", owner: UrlView(), options: nil)?.first as! UrlView
             urlViewNib.frame = CGRect.init(x: 0, y: CGFloat.init(obj) * 40 , width: self.frame.size.width - 20, height:40)
            if let urlText = CurrentSession.currentSession.urlArray[obj - 1].url {
                urlViewNib.urlTextField.text = urlText.absoluteString
            }else{
                urlViewNib.urlTextField.becomeFirstResponder()
            }
            urlViewNib.urlObj = CurrentSession.currentSession.urlArray[obj - 1]
            DispatchQueue.main.async {
                self.baseView.addSubview(urlViewNib)
            }
        }
        
    }
}
