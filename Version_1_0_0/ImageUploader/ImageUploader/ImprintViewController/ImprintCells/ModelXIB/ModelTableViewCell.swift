//
//  ModelTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 16.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit

class ModelTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    var _rootViewController: InprintTableViewController?
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var modelCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        baseView.layer.cornerRadius = 10
        baseView.layer.borderWidth = 1
        baseView.layer.borderColor = UIColor.init(red: 25, green: 184, blue: 255).cgColor
        let nibName = UINib(nibName: "PhotosCollectionViewCell", bundle:nil)
        modelCollectionView.register(nibName, forCellWithReuseIdentifier: "photosCell")
        modelCollectionView.delegate = self
        modelCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func  reloadCollectionView(){
        modelCollectionView.reloadData()
    }
    
    @IBAction func addModelAction(_ sender: UIButton) {
            let searchVC  = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "searchViewController") as? SearchViewController
            self._rootViewController?.present(searchVC!, animated: false, completion: nil)

    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return   CurrentSession.currentSession.modelsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCell", for: indexPath) as! PhotosCollectionViewCell
        if let modelObj = CurrentSession.currentSession.modelsArray[indexPath.row] as? ModelObject {
            cell.modelObject = modelObj
            if let image  = modelObj.image as? UIImage {
               cell.baseImageView.image = image
            }
            
        }
       
        cell.handleDeletButtonPressed = { cell in
            if let index = CurrentSession.currentSession.modelsArray.index(of:cell.modelObject!) {
                CurrentSession.currentSession.modelsArray.remove(at: index)
                self._rootViewController?.baseTableView.reloadData()
            }
        }
        return cell
    }
    
}
