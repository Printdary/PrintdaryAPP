//
//  ImageTableViewCell.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 16.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    

    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var baseView: UIView!
    var _rootViewController: InprintTableViewController?
    var imagePickerController = UIImagePickerController()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        baseView.layer.cornerRadius = 10
        baseView.layer.borderWidth = 1
        baseView.layer.borderColor = UIColor.init(red: 25, green: 184, blue: 255).cgColor
        let nibName = UINib(nibName: "PhotosCollectionViewCell", bundle:nil)
        imageCollectionView.register(nibName, forCellWithReuseIdentifier: "photosCell")
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
    }
    
    
    func reloadCollectionView(){
        imageCollectionView.reloadData()
    }
    @IBAction func addImageAction(_ sender: UIButton) {
        if sender.tag == 1 {
            let st = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let vc = st.instantiateViewController(withIdentifier: "TackPhotto")
            _rootViewController?.present(vc, animated: false, completion: nil)
        }
        if sender.tag == 2 {
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = false
            _rootViewController?.present(imagePickerController, animated: true, completion: nil)
        }
        

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CurrentSession.currentSession.imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCell", for: indexPath) as! PhotosCollectionViewCell
        cell.setImage(imageobj: CurrentSession.currentSession.imageArray[indexPath.row])
        cell.photoObj = CurrentSession.currentSession.imageArray[indexPath.row]
        cell.handleDeletButtonPressed = { photoCell in
            if let index =  CurrentSession.currentSession.imageArray.index(of: photoCell.photoObj!) {
                CurrentSession.currentSession.imageArray.remove(at: index)
                self._rootViewController?.baseTableView.reloadData()
            }
        }
        return cell
    }
    
  
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
           
            let imageObj = ImageObject()
            imageObj.image = pickedImage
            CurrentSession.currentSession.imageArray.append(imageObj)
        }
        
        _rootViewController?.dismiss(animated: true, completion: nil)
        
      
    }
}
