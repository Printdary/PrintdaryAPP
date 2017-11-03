//
//  SearchTableViewController.swift
//  ARKitExample
//
//  Created by McNels Sylvestre on 8/17/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

protocol ModelSelectionDelegate: class {
    func didSelectModel(model: Model)
}

class SearchTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, ModelDownloaderDelegate {

    weak var delegate: ModelSelectionDelegate?
    
    private var searchController: UISearchController!

    private let activityView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityView)
        activityView.activityIndicatorViewStyle = .gray
        activityView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.bringSubview(toFront: activityView)
        activityView.isHidden = true
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ModelTableViewCell.reuseIdentifier, for: indexPath) as! ModelTableViewCell
        cell.setup(with: models[indexPath.row])
        return cell
    }
    
    // MARK: UITableViewDelegate

    var downloader: ModelDownloader?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = models[indexPath.row]
        
        activityView.isHidden = false
        activityView.startAnimating()
        
        updateViewCount(uploadId: model.uploadId ?? "0")
        
        if !ModelDownloader.modelAlreadyDownloaded(model: model) {
            downloader = ModelDownloader(model: model)
            downloader?.delegate = self
            downloader?.start()
        }
        else {
            completeFetchingModel(model: model)
        }
    }
    
    private func completeFetchingModel(model: Model) {
		
        activityView.stopAnimating()
        activityView.isHidden = true
        searchController.isActive = false
        dismiss(animated: true, completion: nil)
        delegate?.didSelectModel(model: model)
    }
    
    // MARK: ModelDownloaderDelegate
    
    func didFinishDownload() {
        print("Finished a download")
    }
    
    func didFinishAllDownloads(model: Model) {
        print("Finished all downloads for model: \(model.uploadId!)")
        completeFetchingModel(model: model)
    }
    
    @IBAction func dismissSearchTableView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        search(text: self.searchController.searchBar.text)
    }
    
    private var models = [Model]()
    
    private func updateViewCount(uploadId: String) {
        let urlString = "http://ec2-18-220-220-31.us-east-2.compute.amazonaws.com/testing/service.php?increase=\(uploadId)"
        if let url = URL(string: urlString) {
            let task = URLSession(configuration: .default).dataTask(with: url)
            task.resume()
        }
    }
    
    private func search(text: String?) {
        guard let text = text else { return }
        
        let urlString = "http://ec2-18-220-220-31.us-east-2.compute.amazonaws.com/testing/service.php?search=\(text)"
        if let url = URL(string: urlString) {
            let task = URLSession(configuration: .default).dataTask(with: url) {
                data, response, error in
                // stop refreshing
                if let data = data {
                    if let tryJson = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: [Any]], let json = tryJson, let results = json["results"] {
                        var models = [Model]()
                        for modelJson in results {
                            let model = Model(json: modelJson)
                            models.append(model)
                        }
                        DispatchQueue.main.async {
                            self.models = models
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            // start refreshing
            task.resume()
        }
    }
}

class ModelTableViewCell: UITableViewCell {
    @IBOutlet private var previewImage: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var viewCountLabel: UILabel!
    
    func setup(with model: Model) {
        titleLabel.text = model.title
        viewCountLabel.text = "Views: \(model.viewCount ?? "0")"
        
        DispatchQueue.global().async {
            if let imageUrlString = model.imageUrl, let url = URL(string: imageUrlString) {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        if let image = UIImage(data: data) {
                            self.previewImage.image = image
                        }
                    }
                }
            }
        }
        
    }
    
    static var reuseIdentifier: String {
        return "ModelCell"
    }
}

struct Model {
    var uploadId: String?
    var title: String?
    var viewCount: String?
    var modelUrl: String?
    var audioUrl: String?
    var imageUrl: String?
    var textures: [Texture]?
    
    init(json: Any) {
        guard let jsonDic = json as? [String: Any] else { return }
        uploadId = jsonDic["uploadID"] as? String
        title = jsonDic["title"] as? String
        viewCount = jsonDic["viewCount"] as? String
        modelUrl = jsonDic["3Dmodel"] as? String
        audioUrl = jsonDic["audio"] as? String
        imageUrl = jsonDic["image"] as? String
        if let texturesArray = jsonDic["textures"] as? [String] {
            var textures = [Texture]()
            for textureString in texturesArray {
                let texture = Texture(url: textureString)
                textures.append(texture)
            }
            self.textures = textures
        }
    }
}

struct Texture {
    var url: String?
}
