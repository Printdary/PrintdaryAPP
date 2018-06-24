//
//  SessionViewController.swift
//  VideoCapture
//
//  Created by MacMini on 7/25/17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import MobileCoreServices
import AVFoundation
import AVKit
import SystemConfiguration
import Alamofire
import Photos
import Crashlytics
import CoreMotion
import RSLoadingView

enum Position {
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
}

class SessionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StreamDelegate {
   
    
    
    @IBOutlet weak var sessionsTableView: UITableView!
    var sessionName: String?
    var menuItems = [UIImage]()
    var existingVideos = [Int]()
    var videoInfo : [[String: String]]?
    var rightItem : UIBarButtonItem?
    var uploadView: UIView?
    var indikator: UIActivityIndicatorView?
    var isMenuShowed: Bool = false
    @IBOutlet weak var cellName: UILabel!
    var selectedCell: SessionCell?
    var appObj = UIApplication.shared.delegate as! AppDelegate
    var _uid = Auth.auth().currentUser?.uid
    var recorder: UIImagePickerController?
    let semaphore = DispatchSemaphore(value: 1)
    let writeBackgroundQueue = DispatchQueue(label: "writheBackgroundQueue", qos: .background)
    let readBackgroundQueue   = DispatchQueue(label: "readBackgroundQueue", qos: .userInitiated)
    let manager = CMMotionManager()
    
    var readStream  :Unmanaged<CFReadStream>?
    var writeStream :Unmanaged<CFWriteStream>?
    var inputStream : InputStream?
    var outputStream : OutputStream?
    var homVC : HomeViewController? = HomeViewController.init(nibName: nil, bundle: nil)
    var loadingView : RSLoadingView? =  RSLoadingView()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    
    }
    
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {

        self.navigationController?.navigationBar.isHidden = true
        self.sessionName = UserDefaults.standard.value(forKey: "sessionName") as? String
        cellName.text = sessionName
        self.setupTableView()
        self.chackRecordedVideos(sessionName: self.sessionName!, complatition: {})
        self.homVC?.capturedBlock = {[unowned self] in
            DispatchQueue.main.async { [unowned self] in
                self.inputStream?.close()
                self.outputStream?.close()
                self.inputStream?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
                self.outputStream?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
                self.inputStream?.delegate = nil
                self.outputStream?.delegate = nil
                if  self.homVC?.rectView != nil {
                    self.homVC?.rectView.removeFromSuperview()
                }
                self.homVC?.rectView = nil
            }
           
        }
  
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {});
        self.navigationController?.popViewController(animated: true);
    }
    
  
    
    func setupTableView() {
        sessionsTableView.register(UINib.init(nibName: "SessionCell", bundle: nil), forCellReuseIdentifier: "cell")
        sessionsTableView.delegate = self
        sessionsTableView.dataSource = self
    }
    
    
    
    func chackRecordedVideos(sessionName: String, complatition: @escaping ()->Void) {
        
        let alert = VideoUploader.sharedInstance.checkUploadedVideosFor(session: sessionName) { [unowned self] (exitingVideos, videoInfo) in
            self.existingVideos = [Int]()
            print("videoInfo = \(videoInfo)")
            self.videoInfo = videoInfo as? [[String : String]]
                DispatchQueue.main.async { [unowned self] in
                         self.sessionsTableView.reloadData()
                    
                }
               
               
                
            }
            complatition()
        
        if alert != nil {
            self.present(alert!, animated: true, completion: nil)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! SessionCell
        if indexPath.row == 0 {
            cell.labelForPosition.text = "Left"
        }else if indexPath.row == 1 {
            cell.labelForPosition.text = "Front"
        }else {
            cell.labelForPosition.text = "Right"
        }
        var videoLength = ""
        var videoURL = ""
        var imageURL = ""
        if let dict = self.videoInfo?[indexPath.row] {
            print(dict)
            videoLength = dict["length"]!
            videoURL    = dict["videoURL"]!
            imageURL    = dict["imageURL"]!
        }
        cell.originalImage.image = nil
        cell.setupCell(name: self.sessionName, type: indexPath.row, parrent: self, length: videoLength, videoURL: videoURL, imageUrl : imageURL)
        cell.emptyVideoPressed = { [unowned self] (type, cell) in
            
             self.connectSocket()
             UserDefaults.standard.set(type + 3, forKey: "positionImage")
             UserDefaults.standard.synchronize()
            
            self.homVC?.recordFinishedBlock = { (url) in
                self.homVC?.dismiss(animated: true, completion: nil)
                UserDefaults.standard.set(type, forKey: "position")
                UserDefaults.standard.synchronize()
                self.selectedCell = cell
                let uid = Auth.auth().currentUser?.uid
                let url = url //(info[UIImagePickerControllerMediaURL] as! NSURL) as URL
                let dict = ["url" : url!, "cell" : cell, "type": type, "name" : self.sessionName!, "uid" :uid! ] as [String : Any]
                VideoUploader.sharedInstance.videoURLs.append(dict)
                if !VideoUploader.sharedInstance.isUploading {
                    VideoUploader.sharedInstance.isUploading = true
                    VideoUploader.sharedInstance.uploadVideoServer()
                    }
            }
            
            self.homVC?.recordCancelBlock = { [unowned self] in
                DispatchQueue.main.async {
                    self.inputStream?.close()
                    self.outputStream?.close()
                    self.inputStream?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
                    self.outputStream?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
                    self.inputStream?.delegate = nil
                    self.outputStream?.delegate = nil
                    self.homVC?.rectView = nil
                    self.homVC?.dismiss(animated: true, completion: nil)
                }
                
            }
            
            self.homVC?.socetConnectionBlock = { [unowned self] in
                self.connectSocket()
            }
            
            
            self.homVC?.imageCapturedBlock = { [unowned self] (image) in
            self.writeBackgroundQueue.async {
                self.semaphore.wait()
                var data = image?.cgImage?.dataProvider?.data! as Data?
                data!.insert(UInt8(type), at: 0)
                data!.insert(UInt8(1), at: 0)
                data!.insert(UInt8(1), at: 0)
                data!.insert(UInt8(1), at: 0)
                
                let bytesWritten = data?.withUnsafeBytes { self.outputStream?.write($0, maxLength: (data?.count)!) }
               // print("bytesWritten = \(String(describing: bytesWritten))")
                self.semaphore.signal()
                }
                
            }
           
       
            
            self.present(self.homVC!, animated: true, completion: {

            })
           

        }
        return cell
    }
    
    
    func connectSocket() {
            CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, "52.175.233.168" as CFString, 44444, &self.readStream, &self.writeStream)
            self.inputStream = self.readStream!.takeRetainedValue()
            self.outputStream = self.writeStream!.takeRetainedValue()
            self.inputStream?.delegate = self
            self.outputStream?.delegate = self
            self.inputStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            self.outputStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            self.inputStream?.open()
            self.outputStream?.open()
        
        
        
        
    }

    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
       
       switch eventCode {
        case .openCompleted:
            print("openCompleted")
            break
        case .hasBytesAvailable:
            print("hasBytesAvailable")
            let bufferSize = 1024
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            if ( aStream == inputStream){
            while (inputStream?.hasBytesAvailable)!{
                
                let numberOfBytesRead = inputStream?.read(buffer, maxLength: bufferSize)
                if numberOfBytesRead! < 0 {
                    if let _ = inputStream?.streamError {
                        break
                    }
                }
                
                
                
             let stringArray = String(bytesNoCopy: buffer,
                                               length: numberOfBytesRead!,
                                               encoding: .utf16,
                                               freeWhenDone: true)?.components(separatedBy: ":")
                
                self.preparToDraw(componentsArry: stringArray!)
            }
            }
           
            break
        case .hasSpaceAvailable:
            break
        case .errorOccurred:
            print("NSStreamEventErrorOccurred")
            let alert = Alerts.sharedInstance.callToAlert(title: "", message: "Socket connection failed")
            UIApplication.topViewController()?.show(alert, sender: nil)
            break
        case . endEncountered:
            print("NSStreamEventEndEncountered")
            
            break
        default:
            print("default")
        }
    }
    
    
    
    
    func getCurrentMillis()->String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd H:m:ss.SSSS"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
   
    
    func preparToDraw(componentsArry: Array<String>) {
        if componentsArry.count > 0 {
            let str = componentsArry.first
            let strArry = str?.components(separatedBy: "/")
            let screen  = UIScreen.main.bounds
            
            if strArry!.count > 5 {
                var xPos = 0.0;
                var yPos = 0.0;
                var width = 0.0;
                var height = 0.0;
                var isGood = 0;
                var frameIndex = 0;
                if let mxPos = Double.init(strArry![(strArry?.count)! - 5]){
                    xPos = mxPos
                }
                if let myPos = Double.init(strArry![(strArry?.count)! - 4]) {
                    yPos = myPos
                }
                if let mwidth = Double.init(strArry![(strArry?.count)! - 2]) {
                    width = mwidth
                }
                if let mheight = Double.init(strArry![(strArry?.count)! - 3]) {
                    height = mheight
                }
                if let misGood = Int.init(strArry![(strArry?.count)! - 6]) {
                    isGood = misGood
                }
                if let mframeIndex = Int.init(strArry![(strArry?.count)! - 1]) {
                    frameIndex = mframeIndex
                }
                let xDif = Double.init(screen.width)
                let yDif = Double.init(screen.height)
                let rect = CGRect.init(x: CGFloat.init(xPos *  xDif),
                                       y: CGFloat.init(yPos * yDif),
                                       width: CGFloat.init(width * xDif),
                                       height: CGFloat.init(height * yDif
                ))
    
    
                if isGood == 1{
                    homVC?.snapButton.isEnabled = true;
                    homVC?.drowRect(rect, andStatus:true )
                } else {
                    homVC?.drowRect(rect, andStatus:false )
                }
            }
        }
        
        
    }
    
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.height / 4.4
    }
    
    
    
  
    

    @IBAction func showResultAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.loadingView?.show(on:self.view)
        }
        if ViewController.isConnected() {
            self.saveCSV(type: 0, name: self.sessionName!)
           
        }
        else {
                self.internetConnectionAlert()
        }
        
    }
    
    

    func internetConnectionAlert () {
        
        let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "You do not have internet access")
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func saveCSV(type: Int, name: String) {
    
      self.dawnloadLeftCSV(type: type, name: name)
       //self.dawnloadLeftCSV(type: 0, name: "11292017-v2")
    }
    
    
    
    
    func dawnloadLeftCSV(type: Int, name: String) {
        let leftStendingVC = LeftStandViewController.sharedInstance
        leftStendingVC.setup(type: type, name: name, success: {
            leftStendingVC.nextCSV()
            
            let leftStendingORVC = LeftStandORViewController.sharedInstance
                        leftStendingORVC.setup(type: 0, name: name, success: {
                            leftStendingORVC.nextCSV()
                            
                            let leftSquatVC = LeftSquatViewController.sharedInstance
                                        leftSquatVC.setup(type: 0, name: name, success: { [unowned self] in
                                            leftSquatVC.nextCSV()
                                             self.dawnloadFrontCSV(type: 1, name: name)
                                            
                                        },failured: {
                                            DispatchQueue.main.async {
                                                self.resultCalculaintigFailedAlert()
                                            }
                                        })
                        },failured: {
                            DispatchQueue.main.async {
                                self.resultCalculaintigFailedAlert()
                            }
                        })
            
        }, failured: {
            DispatchQueue.main.async {
                self.resultCalculaintigFailedAlert()
            }
        })
        
        
    }
    func dawnloadFrontCSV(type: Int, name: String) {
        let frontStendingVC = FrontStandViewController.sharedInstance
        frontStendingVC.setup(type: type, name: name, success: {
            frontStendingVC.nextCSV()
            
            let frontStendingORVC = FrontStandORViewController.sharedInstance
            frontStendingORVC.setup(type: 1, name: name, success: {
                frontStendingORVC.nextCSV()
                
                        let frontSquatVC = FrontSquatViewController.sharedInstance
                                    frontSquatVC.setup(type: 1, name: name, success: { [unowned self] in
                                        frontSquatVC.nextCSV()
                                        self.dawnloadRightCSV(type: 2, name: name)
                                    },failured: {
                                        DispatchQueue.main.async {
                                            self.resultCalculaintigFailedAlert()
                                        }
                                    })
                    },failured: {
                        DispatchQueue.main.async {
                            self.resultCalculaintigFailedAlert()
                        }
                    })
            
        }, failured: {
            DispatchQueue.main.async {
                self.resultCalculaintigFailedAlert()
            }
        })
        
    }
    func dawnloadRightCSV(type: Int, name: String) {
        let rightStendingVC = RightStandViewController.sharedInstance
        rightStendingVC.setup(type: type, name: name, success: {
            rightStendingVC.nextCSV()
            
            let rightStendingORVC = RightStandORViewController.sharedInstance
                    rightStendingORVC.setup(type: 2, name: name, success: {
                        rightStendingORVC.nextCSV()
                        
                                let rightSquatVC = RightSquatViewController.sharedInstance
                                rightSquatVC.setup(type: 2, name: name, success: {
                                    rightSquatVC.nextCSV()
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let controller = storyboard.instantiateViewController(withIdentifier: "resultVC")
                                    DispatchQueue.main.async {
                                        self.loadingView?.hide()
                                        self.navigationController?.pushViewController(controller, animated: true)
                                    }
                                },failured: {
                                    DispatchQueue.main.async {
                                        self.resultCalculaintigFailedAlert()
                                    }
                                })
                    },failured: {
                        DispatchQueue.main.async {
                            self.resultCalculaintigFailedAlert()
                        }
                    })
            
        }, failured: {
            DispatchQueue.main.async {
                self.resultCalculaintigFailedAlert()
            }
        })
    }

}

 extension SessionViewController: UINavigationControllerDelegate {
    
        func videoExistAlert () {
            let alert = Alerts.sharedInstance.callToAlert(title: "Info", message: "Video of this type already exist.")
            self.present(alert, animated: true, completion: nil)
        }
    
    
        func resultCalculaintigFailedAlert () {
            
            let resultCalculaintigFailedAlert = UIAlertController.init(title: "Info", message: "Result calculating failed", preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: "Cancel", style: .default, handler: nil)
            resultCalculaintigFailedAlert.addAction(cancelAction)
            DispatchQueue.main.async {
                
                self.present(resultCalculaintigFailedAlert, animated: true, completion: nil)
                
            }
             self.loadingView?.hide()
           
            
            
        }
    }



extension AVURLAsset {
    var fileSize: Int? {
        var keys = Set<URLResourceKey>()
        keys.insert(.totalFileSizeKey)
        keys.insert(.fileSizeKey)
        
        do {
            let resourceValues = try self.url.resourceValues(forKeys: keys)
            
            return resourceValues.fileSize ?? resourceValues.totalFileSize
        } catch {
            return nil
        }
    }
    
    
    
}

extension Data {
    func sizeString(units: ByteCountFormatter.Units = [.useAll], countStyle: ByteCountFormatter.CountStyle = .file) -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = units
        bcf.countStyle = .file
        
        return bcf.string(fromByteCount: Int64(count))
    }
    func toArray<T>(type: T.Type) -> [T] {
        return self.withUnsafeBytes {
            [T](UnsafeBufferPointer(start: $0, count: self.count/MemoryLayout<T>.stride))
        }
    }
}


extension String {
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
}

extension InputStream {
    func read(data: inout Data) -> Int {
        return data.withUnsafeMutableBytes { read($0, maxLength: data.count) }
    }
}



