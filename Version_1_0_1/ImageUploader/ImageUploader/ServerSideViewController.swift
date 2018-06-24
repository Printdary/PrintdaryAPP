import Foundation
import UIKit
import Photos
import AVKit
import Metal
import SceneKit
import QuartzCore
import ModelIO
import SceneKit.ModelIO
import MetalKit
import Firebase


class ServerSideViewController: UIViewController {
    
    @IBOutlet weak var storyboardSCNView: SCNView!
    var scnView: SCNView?
    var geometryNode: SCNNode = SCNNode()
    var currentYAngle: Float = 0.0
    var currentXAngle: Float = 0.0
    var actInd: UIActivityIndicatorView?
    
    
    static let sharedInstance: ServerSideViewController = {
        let instance = ServerSideViewController()
        return instance
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(deleteController), name: Notification.Name.init("DELETE_CANTROLER"), object: nil)
        self.storyboardSCNView.backgroundColor = UIColor.clear
       
            
    }
    
    @objc func deleteController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool){
        if UserDefaults.standard.bool(forKey: "FromARmode"){
            UserDefaults.standard.set(nil, forKey: "FromARmode")
            self.dismiss(animated: false, completion: nil)
        }
    
         self.download3DObjectsFrom(url: DetectedUnitView.model_name!)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
    
    }
    
    @IBAction func areButtonAction(_ sender: UIButton) {
        
    }
    
    
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
 
    func showActivityIndicatory(uiView: UIView) {
        actInd = UIActivityIndicatorView()
        actInd?.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
        actInd?.center = (uiView.center)
        actInd?.hidesWhenStopped = true
        actInd?.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        uiView.addSubview(actInd!)
        actInd?.startAnimating()
    }
    
    func download3DObjectsFrom(url: String) {
        self.showActivityIndicatory(uiView: self.view)
        let modelRef = Database.database().reference().child("SCNModels").child(url)
        modelRef.observeSingleEvent(of: .value) { (snapshot) in
            if let dic  = snapshot.value as? [String: AnyObject]{
                let urlModel = dic["dawnloadURL"]
                let modUrl = URL.init(string: urlModel as! String)
                
                URLSession.shared.downloadTask(with: modUrl!, completionHandler: { (url , res, error ) in
                    if error != nil {
                        print(error?.localizedDescription as Any)
                    }
                    UserDefaults.standard.set(url, forKey: "filePath")
                    UserDefaults.standard.synchronize()
                    
                    self.objthreed(filePath: url!)
                }).resume()
                
            }
        }
    }
    
    
    func objthreed(filePath: URL) {

        do {
            let dataForNote = try Data.init(contentsOf:filePath )
            let scene  = NSKeyedUnarchiver.unarchiveObject(with: dataForNote) as? SCNScene
            self.scnView = self.storyboardSCNView
            scnView?.scene = scene
            scnView?.backgroundColor = UIColor.clear
            scnView?.autoenablesDefaultLighting = true
            scnView?.allowsCameraControl = true
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3.init(x: 0, y: 5, z: 45)
            DispatchQueue.main.async {
                self.actInd?.stopAnimating()
            }
           
        }catch let  error {
            print(error.localizedDescription)
        }

    }
    
    
    @objc func panGesture(gestureRecognize: UIPanGestureRecognizer){
        let translation = gestureRecognize.translation(in: gestureRecognize.view!)
        
        let x = Float(translation.x)
        let y = Float(-translation.y)
        
        let anglePan = sqrt(pow(x,2)+pow(y,2))*(Float)(Double.pi)/180.0
        
        var rotationVector = SCNVector4()
        rotationVector.x = y
        rotationVector.y = x
        rotationVector.z = 0
        rotationVector.w = anglePan
        
        geometryNode.rotation = rotationVector
        
        
        if(gestureRecognize.state == UIGestureRecognizerState.ended) {
            let currentPivot = geometryNode.pivot
            let changePivot = SCNMatrix4Invert( geometryNode.transform)
            
            geometryNode.pivot = SCNMatrix4Mult(changePivot, currentPivot)
            
            geometryNode.transform = SCNMatrix4Identity
        }
    }
    
  
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.allButUpsideDown.rawValue)
        }else {
            return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.all.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
       // NotificationCenter.default.removeObserver(self, name: Notification.Name.init("DELETE_CANTROLER"), object: nil)
    }
    
  
}


extension MDLMaterial {
    func setTextureProperties( textures: [MDLMaterialSemantic:String], fileName: String?) -> Void {
        
        for (key,value) in textures {
            var finalURL = Bundle.main.url(forResource: value, withExtension: "")
            guard let url = finalURL else {
                // fatalError("Failed to find URL for resource \(value).")
                return
            }
            
            let property = MDLMaterialProperty(name:fileName!, semantic: key, url: url)
            self.setProperty(property)
        }
    }
}

extension SCNNode {
    
    convenience init(named name: String) {
        self.init()
        
        guard let scene = SCNScene(named: name) else {
            return
        }
        
        for childNode in scene.rootNode.childNodes {
            addChildNode(childNode)
        }
    }
    
}

