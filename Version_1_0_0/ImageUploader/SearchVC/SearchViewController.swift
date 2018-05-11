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
    
    override func viewDidLoad() {
        super.viewDidLoad()
       let searchView = UINib.init(nibName: "SearchTableViewCell", bundle: Bundle.main)
       searchTableView.register(searchView, forCellReuseIdentifier: "cell")
       searchTableView.delegate = self
       searchTableView.dataSource = self
       searchTableView.delegate = self
        modelSearchBar.delegate = self
        getModelsNames()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearchTableViewCell
        cell.modelImageView.image = nil
        let name = self.modelNames[indexPath.row]
        cell.nameLabel.text = name
        let name1 = name.replacingOccurrences(of: " ", with: "_")
        let urlStr = "http://ec2-18-188-59-112.us-east-2.compute.amazonaws.com/models/\(name1)/\(name1).jpg"
        let url = URL.init(string: urlStr)

        if let cachedImage = imageCache.object(forKey: urlStr as NSString) {
            DispatchQueue.main.async {
                cell.modelImageView.image = cachedImage
            }
        } else {
        
        DispatchQueue.global().async {
            do {
               
                print(url)
                if (url != nil) {
                    let data = try Data.init(contentsOf: url!)
                    let img = UIImage.init(data: data)
                    DispatchQueue.main.async {
                        cell.modelImageView.image = img
                        self.imageCache.setObject(img!, forKey: urlStr as NSString)
                    }
                }
                
               
            }catch let _{
               print("load error")
            }
           
         }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelNames.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as? SearchTableViewCell
        let name = self.modelNames[indexPath.row]
        let name1 = name.replacingOccurrences(of: " ", with: "_")
        let urlStr = "http://ec2-18-188-59-112.us-east-2.compute.amazonaws.com/models/\(name1)/\(name1).jpg"
        let url = URL.init(string: urlStr)
        DispatchQueue.global().async {
            do {
                
                print(url)
                if (url != nil) {
                    let data = try Data.init(contentsOf: url!)
                    let img = UIImage.init(data: data)
                    DispatchQueue.main.async {
                        CurrentSession.currentSession.modelImagesArray.append(img!)
                        CurrentSession.currentSession.modelUrlArray.append(name)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
                
            }catch let _{
                print("load error")
            }
        
    }
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
        Downloader.load(url: URL.init(string: "http://ec2-18-188-59-112.us-east-2.compute.amazonaws.com/models/names.txt")!, to: nil) { names in
            self.modelNames = names
            self.modelNames.removeLast()
            self.modelNamesOld = self.modelNames
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
