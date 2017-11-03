//
//  ModelDownloader.swift
//  ARKitExample
//
//  Created by Jesse Ziegler on 9/6/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SSZipArchive

protocol ModelDownloaderDelegate: class {
    func didFinishDownload()
    func didFinishAllDownloads(model: Model)
}

class ModelDownloader: NSObject, URLSessionDownloadDelegate {

    weak var delegate: ModelDownloaderDelegate?

    private let model: Model
    private var session: URLSession!
    private let requiredDownloads: Int

    private var downloadsCompleted = 0
	private var audioDownloadTask: URLSessionDownloadTask?
	private var zipDownloadTask: URLSessionDownloadTask?

    private var textureTaskToTextureName = [URLSessionDownloadTask: String]()

    init(model: Model) {
        self.model = model
        let configuration = URLSessionConfiguration.default
        requiredDownloads = (model.modelUrl != nil ? 1 : 0) + (model.audioUrl != nil ? 1 : 0)// + (model.textures?.count ?? 0)
        super.init()
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
    }

    func start() {
		
		guard let modelUrlString = model.modelUrl, let modelUrl = URL(string: modelUrlString) else { return }
			
		zipDownloadTask = session.downloadTask(with: modelUrl)
		zipDownloadTask?.resume()
		
		if let audioURLString = model.audioUrl, let audioURL = URL(string: audioURLString) {
			audioDownloadTask = session.downloadTask(with: audioURL)
		}
		
		audioDownloadTask?.resume()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Did Finish Downloading: \(downloadTask.taskIdentifier) to \(location.absoluteString)")
		
		let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0]
        let directory = path + "/" + model.uploadId! + "/"
		let audioPath = directory + "audio.mp3"

		let directoryUrl = URL(fileURLWithPath: directory, isDirectory: true)
		let audioUrl = URL(fileURLWithPath: audioPath, isDirectory: true)

		try? fileManager.createDirectory(atPath: directory + "textures/", withIntermediateDirectories: true, attributes: nil)
				
		// Zip Download of model
		if downloadTask == zipDownloadTask {
			
			let downloadedUrl = directoryUrl.appendingPathComponent(model.uploadId! + ".scnassets.zip")
			do {
				try fileManager.copyItem(at: location, to: downloadedUrl)
				SSZipArchive.unzipFile(atPath: directory + model.uploadId! + ".scnassets.zip", toDestination: directory, overwrite: true, password: nil, progressHandler: { (entry, zipInfo, entry_num, total) in
					print(entry_num)
				}, completionHandler: { (path, succeed, error) in
					print("✔︎  Unzipped to: \(path)")
					print("✔︎  Unzipping Succeeded :\(succeed)")
					print("✔︎  Error :\(String(describing: error?.localizedDescription))")
					
					if succeed {
						
						self.compressColladaFile()
					}
					
					self.checkAllDownloaded()
				})
			} catch {
				print("FileManager Error")
			}
		} else if downloadTask == audioDownloadTask {
			// Audio
			do {
				try fileManager.copyItem(at: location, to: audioUrl)
				print("✔︎ Audio File Downloaded To - \(audioUrl)")
			}
			catch {
				print(error.localizedDescription)
			}
			checkAllDownloaded()
        }
    }
	
	func checkAllDownloaded() {
		
		// Serial Queue
		DispatchQueue.main.async {
			[weak self] in
			guard let `self` = self else { return }
			self.downloadsCompleted += 1
			
			if self.downloadsCompleted < self.requiredDownloads {
				self.delegate?.didFinishDownload()
			}
			
			if self.downloadsCompleted == self.requiredDownloads {
				self.delegate?.didFinishAllDownloads(model: self.model)
			}
		}
	}
	
	func compressColladaFile() {
		
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let path = paths[0]
		let directory = path + "/" + model.uploadId! + "/"
		
	}

    static func modelAlreadyDownloaded(model: Model) -> Bool {
		
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0]
        let directory = path + "/" + model.uploadId! + "/" + model.uploadId! + ".scnassets.zip"
        return FileManager.default.fileExists(atPath: directory)
    }
}
