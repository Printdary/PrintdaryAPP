//
//  ViewController.swift
//  VideoCapture
//
//  Created by MacMini on 7/1/17.
//  Copyright © 2017 com.armomik. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import MobileCoreServices
//import RealmSwift
import AVFoundation
import AVKit
import SystemConfiguration
import Alamofire
import Photos





class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var myTableView: UITableView!
    var appObj = UIApplication.shared.delegate as! AppDelegate
    //private var myTableView: UITableView!
    //var ref: UIRefreshControl?
    var data : NSData?
    var dbSessionRef: DatabaseReference?
    var dbReference : DatabaseReference?
    var myArray = [[String: Any]]()
    var menuItems = [UIImage]()
    var existingVideos = [Int]()
    var dawnloadTimer: Timer?
    var uploadView: UIView?
    var indikator: UIActivityIndicatorView?
    var videosInProcess = [Int]()
    var isMenuShowed : Bool = false
    var sessionNames = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
//        self.ref = UIRefreshControl.init()
//        self.ref?.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        self.setupTableView()
        
        myTableView.register(UINib.init(nibName: "SessionCellNew", bundle: nil), forCellReuseIdentifier: "CustomCellOne")
        
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleLogout),
            name: Notification.Name("LogoutNotifikation"),
            object: nil)
        }

    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
       self.navigationController?.navigationBar.isHidden = true
       self.myArray =  [[String: Any]]()
        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
        }
        else {
            do {
                let rech = try Reachability.init()
                if (rech?.isConnectedToNetwork)!{
                    getSessionsFromFirebase()
                }
                else {
                    let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "You do not have internet access")
                    self.present(alert, animated: true, completion: nil)
                }
            }
            catch {
                print("ERROR Internet")
            }
        }
        if appObj.newSessionButtonPressed {
            appObj.newSessionButtonPressed = false
            handleNewSession()
        }

    }
    
    
    @IBAction func newButtonAction(_ sender: Any) {
        appObj.newSessionButtonPressed = true
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let profileViewController = storyboard.instantiateViewController(withIdentifier: "ParticipationFormViewController")
        self.present(profileViewController, animated: true, completion: nil)
    }
    
    @IBAction func removeButtonAction(_ sender: Any) {
        
        do {
            let rech = try Reachability.init()
            if (rech?.isConnectedToNetwork)!{
                if appObj.sessionsForDelate.count > 0 {
                    self.dbReference = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions")
                    for session in appObj.sessionsForDelate {
                        self.dbReference?.child(session).removeValue()
                        if let index = appObj.sessionsForDelate.index(of:session) {
                            appObj.sessionsForDelate.remove(at: index)
                        }
                    }
                    
//self.refreshAction()
                }
            }
            else {
                let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "You do not have internet access")
                self.present(alert, animated: true, completion: nil)
            }
        }
        catch {
            print("ERROR Internet")
        }
        
    }
    
    @IBAction func renameButtonAction(_ sender: Any) {
        
        
    }
    
    @IBAction func logoutButtonAction(_ sender: Any) {
        handleLogout()
    }
    
    @IBAction func moreButtonAction(_ sender: Any) {
        
    }
    
    
    func refreshAction() {
         self.myArray =  [[String: Any]]()
    }
    
    func setupTableView() {
        if #available(iOS 10.0, *) {
            //myTableView.refreshControl = self.ref
        } else {
            // Fallback on earlier versions
        }

        self.view.addSubview(myTableView)
    }
    
    
    
    
    func getSessionsFromFirebase() {
        self.myTableView.isUserInteractionEnabled = false
        self.perform(#selector(changeTableviewStatus), with: nil, afterDelay: 2)
        self.dbReference = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions")
        self.dbReference?.observe(.childAdded, with: { [unowned self] ( snapshot) in
            let obj = snapshot.value as! [String: Any]
            print("snapshot === \(snapshot)")
            DispatchQueue.main.async {
               self.myArray.append(obj)
               self.myTableView.reloadData()
                
            }
        })
        
        
        self.dbReference?.observe(.childRemoved, with: { [unowned self] ( snapshot) in
            let obj = snapshot.value as! [String: Any]
            let name = obj["Session Name"] as! String
            print("snapshot === \(snapshot)")
            DispatchQueue.main.async {
                let filteredDetails = self.myArray.filter {($0["Session Name"] as! String) != name  }
                self.myArray = filteredDetails
                self.myTableView.reloadData()
            }
        })



    }
    
    
    @objc func changeTableviewStatus() {
        self.myTableView.isUserInteractionEnabled = true
    }
    
    func handleNewSession() {
        //self.showNewSessionAlert()
        if let name = UserDefaults.standard.value(forKey: "UserName") as? String {
         self.makeNewSession(SessionName: name)
        }
    }
    
    func makeNewSession(SessionName: String) {
        
        let sessionNameWithoutSpace = SessionName.removingWhitespaces()
        print("sessionNameWithoutSpace = \(sessionNameWithoutSpace)")
        do {
            let rech = try Reachability.init()
            if (rech?.isConnectedToNetwork)!{
                let sessionName = "\(sessionNameWithoutSpace)"
                Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    print(snapshot)
                    if snapshot.hasChild(sessionName) {
                        let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "Name is already in use")
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        self.dbSessionRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Sessions").child(sessionName)
                        let date = Date()
                        
                        var dayString: String
                        var monthString: String
                        var hourString: String
                        var minuteString: String
                        var secondString: String
                        
                        let calendar = Calendar.current
                        let day = calendar.component(.day, from: date) as Int
                        if day < 10 {
                            dayString = "0\(day)"
                        }else {
                            dayString = "\(day)"
                        }
                        
                        let month = calendar.component(.month, from: date) as Int
                        if month < 10 {
                            monthString = "0\(month)"
                        }else {
                            monthString = "\(month)"
                        }
                        
                        let year = calendar.component(.year, from: date)
                        
                        let hour = calendar.component(.hour, from: date) as Int
                        if hour < 10 {
                            hourString = "0\(hour)"
                        }else {
                            hourString = "\(hour)"
                        }
                        
                        let minute = calendar.component(.minute, from: date) as Int
                        if minute < 10 {
                            minuteString = "0\(minute)"
                        }else {
                            minuteString = "\(minute)"
                        }
                        
                        let second = calendar.component(.second, from: date) as Int
                        if second < 10 {
                            secondString = "0\(second)"
                        }else {
                            secondString = "\(second)"
                        }
                        
                        let dateString = "\(dayString)/\(monthString)/\(year) \(hourString):\(minuteString):\(secondString)"
                        self.dbSessionRef?.updateChildValues(["Session Name" : sessionName, "Date" : dateString])
                        UserDefaults.standard.set(sessionName, forKey: "sessionName")
                        UserDefaults.standard.synchronize()
                        
                    }
                    
                })

                
            }
            else {
                let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "You do not have internet access")
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        catch {
            print("ERROR Internet")
        }

  
        
    }
    
    func showNewSessionAlert() {
    
        let alert = UIAlertController(title: "", message: "Create New Session", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter name"
            textField.keyboardType = .emailAddress
            textField.isUserInteractionEnabled = false
            if let sessionName =  UserDefaults.standard.value(forKey: "UserName"){
                 textField.text = sessionName as? String
            }
           
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField?.text != "" && !((textField?.text?.rangeOfCharacter(from: CharacterSet.init(charactersIn: "_"))) != nil)  {
                 DispatchQueue.main.async {
                         self.makeNewSession(SessionName: (textField?.text)!)
                }
            }else{
                DispatchQueue.main.async {
                        let alertName = UIAlertController(title: "", message: "Name is not valid", preferredStyle: UIAlertControllerStyle.alert)
                        alertName.addAction(UIAlertAction.init(title: "OK", style: .default, handler: {[unowned self] (action) in
                        self.showNewSessionAlert()
                        }))
                        self.present(alertName, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
  
    
    
    @objc func handleLogout() {
         self.myArray =  [[String: Any]]()
         self.myTableView.reloadData()
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let loginController = storyboard.instantiateViewController(withIdentifier: "loginVC")
        present(loginController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
         self.dbReference?.removeAllObservers()
    }
    
  
   
    
    
    //MARK: TableViewDelegate

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "sessionID")
        let cell = tableView.cellForRow(at: indexPath) as! SessionCellNew
        let sessionName = cell.labelForSessionName?.text
        UserDefaults.standard.set(sessionName, forKey: "sessionName")
        UserDefaults.standard.synchronize()
        
       if ViewController.isConnected() {
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        }
       else {
        
            self.internetConnectionAlert()
        }
        
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(myArray.count)
        return  myArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCellOne", for: indexPath) as! SessionCellNew
        let obj = myArray[indexPath.row]
        DispatchQueue.main.async {
            cell.thumbnailLeftImageView.image = nil
            cell.thumbnailFrontImageView.image = nil
            cell.thumbnailRightImageView.image = nil
        }
        
        cell.setupCell(snapshot: obj)
        cell.namePressed = {[unowned self] (name) in
            if self.sessionNames.contains(name) {
                let index = self.sessionNames.index(of: name)
                self.sessionNames.remove(at: index!)
            }else {
                self.sessionNames.append(name)
            }
            
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            return self.view.frame.size.height / 2
        }
        return self.view.frame.size.height / 5
    }
    
    
    func internetConnectionAlert () {
        
        let alert = Alerts.sharedInstance.callToAlert(title: "Error", message: "You do not have internet access")
        self.present(alert, animated: true, completion: nil)
        
    }
 

}


extension ViewController {
    
    class func isConnected()-> Bool {
        do {
            let rech = try Reachability.init()
                if (rech?.isConnectedToNetwork)!{
                     return true
                }
                else {
                     return false
                }
        }
        catch {
            return false
        }
    }
    
 
    func videoExistAlert () {
        let alert = Alerts.sharedInstance.callToAlert(title: "Info", message: "Video of this type already exist.")
        self.present(alert, animated: true, completion: nil)
    }


}

class Reachability {
    var hostname: String?
    var isRunning = false
    var isReachableOnWWAN: Bool
    var reachability: SCNetworkReachability?
    var reachabilityFlags = SCNetworkReachabilityFlags()
    let reachabilitySerialQueue = DispatchQueue(label: "ReachabilityQueue")
    init?(hostname: String) throws {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, hostname) else {
            throw Network.Error.failedToCreateWith(hostname)
        }
        self.reachability = reachability
        self.hostname = hostname
        isReachableOnWWAN = true
    }
    init?() throws {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let reachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }}) else {
                throw Network.Error.failedToInitializeWith(zeroAddress)
        }
        self.reachability = reachability
        isReachableOnWWAN = true
    }
    var status: Network.Status {
        return  !isConnectedToNetwork ? .unreachable :
            isReachableViaWiFi    ? .wifi :
            isRunningOnDevice     ? .wwan : .unreachable
    }
    var isRunningOnDevice: Bool = {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            return false
        #else
            return true
        #endif
    }()
    deinit { stop() }
}

extension Reachability {
    func start() throws {
        guard let reachability = reachability, !isRunning else { return }
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = Unmanaged<Reachability>.passUnretained(self).toOpaque()
        guard SCNetworkReachabilitySetCallback(reachability, callout, &context) else { stop()
            throw Network.Error.failedToSetCallout
        }
        guard SCNetworkReachabilitySetDispatchQueue(reachability, reachabilitySerialQueue) else { stop()
            throw Network.Error.failedToSetDispatchQueue
        }
        reachabilitySerialQueue.async { self.flagsChanged() }
        isRunning = true
    }
    func stop() {
        defer { isRunning = false }
        guard let reachability = reachability else { return }
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
        self.reachability = nil
    }
    var isConnectedToNetwork: Bool {
        return isReachable &&
            !isConnectionRequiredAndTransientConnection &&
            !(isRunningOnDevice && isWWAN && !isReachableOnWWAN)
    }
    var isReachableViaWiFi: Bool {
        return isReachable && isRunningOnDevice && !isWWAN
    }
    
    /// Flags that indicate the reachability of a network node name or address, including whether a connection is required, and whether some user intervention might be required when establishing a connection.
    var flags: SCNetworkReachabilityFlags? {
        guard let reachability = reachability else { return nil }
        var flags = SCNetworkReachabilityFlags()
        return withUnsafeMutablePointer(to: &flags) {
            SCNetworkReachabilityGetFlags(reachability, UnsafeMutablePointer($0))
            } ? flags : nil
    }
    
    /// compares the current flags with the previous flags and if changed posts a flagsChanged notification
    func flagsChanged() {
        guard let flags = flags, flags != reachabilityFlags else { return }
        reachabilityFlags = flags
        NotificationCenter.default.post(name: .flagsChanged, object: self)
    }
    
    /// The specified node name or address can be reached via a transient connection, such as PPP.
    var transientConnection: Bool { return flags?.contains(.transientConnection) == true }
    
    /// The specified node name or address can be reached using the current network configuration.
    var isReachable: Bool { return flags?.contains(.reachable) == true }
    
    /// The specified node name or address can be reached using the current network configuration, but a connection must first be established. If this flag is set, the kSCNetworkReachabilityFlagsConnectionOnTraffic flag, kSCNetworkReachabilityFlagsConnectionOnDemand flag, or kSCNetworkReachabilityFlagsIsWWAN flag is also typically set to indicate the type of connection required. If the user must manually make the connection, the kSCNetworkReachabilityFlagsInterventionRequired flag is also set.
    var connectionRequired: Bool { return flags?.contains(.connectionRequired) == true }
    
    /// The specified node name or address can be reached using the current network configuration, but a connection must first be established. Any traffic directed to the specified name or address will initiate the connection.
    var connectionOnTraffic: Bool { return flags?.contains(.connectionOnTraffic) == true }
    
    /// The specified node name or address can be reached using the current network configuration, but a connection must first be established.
    var interventionRequired: Bool { return flags?.contains(.interventionRequired) == true }
    
    /// The specified node name or address can be reached using the current network configuration, but a connection must first be established. The connection will be established "On Demand" by the CFSocketStream programming interface (see CFStream Socket Additions for information on this). Other functions will not establish the connection.
    var connectionOnDemand: Bool { return flags?.contains(.connectionOnDemand) == true }
    
    /// The specified node name or address is one that is associated with a network interface on the current system.
    var isLocalAddress: Bool { return flags?.contains(.isLocalAddress) == true }
    
    /// Network traffic to the specified node name or address will not go through a gateway, but is routed directly to one of the interfaces in the system.
    var isDirect: Bool { return flags?.contains(.isDirect) == true }
    
    /// The specified node name or address can be reached via a cellular connection, such as EDGE or GPRS.
    var isWWAN: Bool { return flags?.contains(.isWWAN) == true }
    
    /// The specified node name or address can be reached using the current network configuration, but a connection must first be established. If this flag is set
    /// The specified node name or address can be reached via a transient connection, such as PPP.
    var isConnectionRequiredAndTransientConnection: Bool {
        return (flags?.intersection([.connectionRequired, .transientConnection]) == [.connectionRequired, .transientConnection]) == true
    }
}

func callout(reachability: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
    guard let info = info else { return }
    DispatchQueue.main.async {
        Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue().flagsChanged()
    }
}



extension Notification.Name {
    static let flagsChanged = Notification.Name("FlagsChanged")
}

struct Network {
    static var reachability: Reachability?
    enum Status: String, CustomStringConvertible {
        case unreachable, wifi, wwan
        var description: String { return rawValue }
    }
    enum Error: Swift.Error {
        case failedToSetCallout
        case failedToSetDispatchQueue
        case failedToCreateWith(String)
        case failedToInitializeWith(sockaddr_in)
    }
}


