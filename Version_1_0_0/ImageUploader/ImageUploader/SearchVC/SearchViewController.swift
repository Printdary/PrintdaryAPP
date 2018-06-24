//
//  SearchViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 06.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {

    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var modelSearchBar: UISearchBar!
    var modelNames = [String]()
    var modelNamesOld = [String]()
    let imageCache = NSCache<NSString, UIImage>()
    var modelImagesArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       let searchView = UINib.init(nibName: "SearchTableViewCell", bundle: Bundle.main)
       searchTableView.register(searchView, forCellReuseIdentifier: "cell")
       searchTableView.delegate = self
       searchTableView.dataSource = self
       searchTableView.delegate = self
      modelSearchBar.delegate = self
       // getModelsNames()
        modelImagesArray = [UIImage.init(named: "Acetic_Acid.jpg"), UIImage.init(named: "Acetone.jpg"), UIImage.init(named: "Acetonitrile.jpg"), UIImage.init(named: "Ammonia.jpg"), UIImage.init(named: "Aspartame.jpg"), UIImage.init(named: "Benzoic_Acid.jpg"), UIImage.init(named: "Bisphenol_A.jpg"), UIImage.init(named: "Butane.jpg"), UIImage.init(named: "Butylethylene.jpg"), UIImage.init(named: "Cadaverine.jpg"), UIImage.init(named: "Caffeine.jpg"), UIImage.init(named: "Chloromethane.jpg"), UIImage.init(named: "Citric_Acid.jpg")] as! [UIImage]
        // Do any additional setup after loading the view.
        
        modelNames = ["Acetic_Acid","Acetone","Acetonitrile","Ammonia","Aspartame","Benzoic_Acid","Bisphenol_A","Butane","Butylethylene","Cadaverine","Caffeine","Chloromethane","Citric_Acid"]
        self.modelNamesOld = self.modelNames

    }
    
    /*
     ,"Cyanic_Acid","Cyclobutane","Cyclopentane","DDT","Diamond","Dimethyl_sulfoxide","Dimethylcyclobutane","Disulfiram","Ethanamide"
    ,"Ethanol","Ethene","Heptane","Isoamyl_acetate","Isobutane","Isopentane","sopropanol","Isopropyl_chloride","Lactic_acid","Maleic_acid","Mercuric_acetate","Methane","Methylamine","Methylammonium_ion","Octane","Paracetamol","Pentane","Phthalic_acid","Propyl_Chloride","Putricine","Saccharine","T_Butyl_Chloride","Tetrahydrofuran","Tetramethyl_ethylene","Tetramethylsilane","Thalidomide","Trifluoroethanol","Trinitrotoluene","Urea","Water"
     
     
     
    , UIImage.init(named: "Cyanic_Acid.jpg"), UIImage.init(named: "Cyclobutane.jpg"), UIImage.init(named: "Cyclopentane.jpg"), UIImage.init(named: "DDT.jpg"), UIImage.init(named: "Diamond.jpg"), UIImage.init(named: "Dimethyl_sulfoxide.jpg"), UIImage.init(named: "Dimethylcyclobutane.jpg"), UIImage.init(named: "Disulfiram.jpg"), UIImage.init(named: "Ethanamide.jpg"),  , UIImage.init(named: "Ethanol.jpg"), UIImage.init(named: "Ethene.jpg"), UIImage.init(named: "Heptane.jpg"), UIImage.init(named: "Isoamyl_acetate.jpg"), UIImage.init(named: "Isobutane.jpg"), UIImage.init(named: "Isopentane.jpg"), UIImage.init(named: "Isopropanol.jpg"), UIImage.init(named: "Isopropyl_chloride.jpg"), UIImage.init(named: "Lactic_acid.jpg"), UIImage.init(named: "Maleic_acid.jpg"), UIImage.init(named: "Mercuric_acetate.jpg"), UIImage.init(named: "Methane.jpg"), UIImage.init(named: "Methylamine.jpg"), UIImage.init(named: "Methylammonium_ion.jpg"), UIImage.init(named: "Octane.jpg"), UIImage.init(named: "Paracetamol.jpg"), UIImage.init(named: "Pentane.jpg"), UIImage.init(named: "Phthalic_acid.jpg"), UIImage.init(named: "Propyl_Chloride.jpg"), UIImage.init(named: "Putricine.jpg"), UIImage.init(named: "Saccharine.jpg"), UIImage.init(named: "T_Butyl_Chloride.jpg"), UIImage.init(named: "Tetrahydrofuran.jpg"), UIImage.init(named: "Tetramethyl_ethylene.jpg"), UIImage.init(named: "Tetramethylsilane.jpg"), UIImage.init(named: "Thalidomide.jpg"), UIImage.init(named: "Trifluoroethanol.jpg"), UIImage.init(named: "Trinitrotoluene.jpg"), UIImage.init(named: "Urea.jpg"),UIImage.init(named: "Water.jpg")
    */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearchTableViewCell
        cell.modelImageView.image = nil
        cell.modelImageView.image = modelImagesArray[indexPath.row]
        let name = self.modelNames[indexPath.row]
        cell.nameLabel.text = name
     //   let name1 = name.replacingOccurrences(of: " ", with: "_")
       // let urlStr = "http://ec2-18-220-100-17.us-east-2.compute.amazonaws.com/models/\(name1)/\(name1).jpg"
      //  let url = URL.init(string: urlStr)

//        if let cachedImage = imageCache.object(forKey: urlStr as NSString) {
//            DispatchQueue.main.async {
//                cell.modelImageView.image = cachedImage
//            }
//        } else {
        
//        DispatchQueue.global().async {
//            do {
//
//                if (url != nil) {
//                    let data = try Data.init(contentsOf: url!)
//
//                    if let img = UIImage.init(data: data) {
//                        DispatchQueue.main.async {
//                            cell.modelImageView.image = img
//                            self.imageCache.setObject(img, forKey: urlStr as NSString)
//                        }
//                    }
//                }
//
//
//            }catch let _{
//               print("load error")
//            }
//
//         }
     //   }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelNames.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as? SearchTableViewCell
        let name = self.modelNames[indexPath.row]
        
        let obj = ModelObject()
        obj.image = modelImagesArray[indexPath.row]
        obj.modelUrl = name
        CurrentSession.currentSession.modelsArray.append(obj)
        self.dismiss(animated: true, completion: nil)
//        let name1 = name.replacingOccurrences(of: " ", with: "_")
//        let urlStr = "http://ec2-18-221-24-209.us-east-2.compute.amazonaws.com/models/\(name1)/\(name1).jpg"
//        let url = URL.init(string: urlStr)
//        DispatchQueue.global().async {
//            do {
//
//                print(url)
//                if (url != nil) {
//                    let data = try Data.init(contentsOf: url!)
//                    let img = UIImage.init(data: data)
//                    DispatchQueue.main.async {
//                        let obj = ModelObject()
//                        obj.image = img
//                        obj.modelUrl = name
//                        CurrentSession.currentSession.modelsArray.append(obj)
//                        self.dismiss(animated: true, completion: nil)
//                    }
//                }
//
//
//            }catch let _{
//                print("load error")
//            }
//
//    }
}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.height / 3
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
   
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.modelNames  = self.modelNamesOld
        DispatchQueue.global().async {
            
        
        if searchText != "" {
                print(self.modelNames)
            for str  in self.modelNames {
                if str == ""{
                    continue
                }
                for i in 0..<searchText.characters.count {
                    if (str as! String)[i] != searchText[i] {
                        self.modelNames.remove(at: self.modelNames.index(of: str)!)
                         break
                    }
                   
                }
                
            }
            
            
           
        }else {
            self.modelNames = self.modelNamesOld
        }
        DispatchQueue.main.async {
            self.searchTableView.reloadData()
           
        }
        }
       
    }
    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getModelsNames(){
        modelNames = [String]()
        Downloader.load(url: URL.init(string: "http://ec2-18-221-24-209.us-east-2.compute.amazonaws.com/models/names.txt")!, to: nil) { names in
            self.modelNames = names
            self.modelNames.removeLast()
            
            DispatchQueue.main.async {
                 self.searchTableView.reloadData()
            }
           
        }
    }

}

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}
