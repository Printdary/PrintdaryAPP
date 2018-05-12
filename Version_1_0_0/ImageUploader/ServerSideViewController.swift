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


class ServerSideViewController: UIViewController {
    
    @IBOutlet weak var storyboardSCNView: SCNView!
    var scnView: SCNView?
    var geometryNode: SCNNode = SCNNode()
    var currentYAngle: Float = 0.0
    var currentXAngle: Float = 0.0
    
    static let sharedInstance: ServerSideViewController = {
        let instance = ServerSideViewController()
        return instance
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.storyboardSCNView.backgroundColor = UIColor.clear
       
            
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let path = UserDefaults.standard.value(forKey: "filePath") as? String {
            self.objthreed(filePath: path)
        }
    }
    
    @IBAction func areButtonAction(_ sender: UIButton) {
        
    }
    
    
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func objthreed(filePath: String) {

        
        let url = URL.init(fileURLWithPath: filePath)
        let asset = MDLAsset(url: url)
        guard let object = asset.object(at: 0) as? MDLMesh else {
            fatalError("Failed to get mesh from asset.")
        }
        let node = SCNNode(mdlObject: object)
        node.scale = SCNVector3.init(10, 10, 10)
        
        let scene = SCNScene()
        
        
        self.scnView = self.storyboardSCNView//self.view as? SCNView
        scnView?.scene = scene
        scnView?.backgroundColor = UIColor.clear
        scnView?.autoenablesDefaultLighting = true
        scnView?.allowsCameraControl = true

        
//        let scatteringFunction = MDLScatteringFunction()
//        let material = MDLMaterial(name: "baseMaterial", scatteringFunction: scatteringFunction)
//        material.setTextureProperties(textures: [
//            .baseColor:"Wolf_Body.jpg",
//            .specular:"Wolf_Eyes_2.jpg",
//            .emission:"Wolf_Fur.jpg"])
//
//
//        for  submesh in object.submeshes!  {
//            if let submesh = submesh as? MDLSubmesh {
//                submesh.material = material
//            }
//        }
         scene.rootNode.addChildNode(node)
        
        if let model = UserDefaults.standard.value(forKey: "filePathMTL") as? String{
            let image = UIImage.init(contentsOfFile: model)
            let material = SCNMaterial()
            material.diffuse.contents = image
            scene.rootNode.childNodes[0].geometry?.materials = [material]
           
        }
       

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3.init(x: 0, y: 5, z: 45)
        scene.rootNode.addChildNode(cameraNode)
        
       
        
        let action = SCNAction.rotate(by: 90 * CGFloat((Double.pi / 180.0)), around: SCNVector3.init(0.0, 1.0, 0.0), duration: 3)
        let repeatAction = SCNAction.repeatForever(action)
        node.runAction(repeatAction)
        geometryNode = node
 
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gestureRecognize:)))
      //  scnView?.addGestureRecognizer(panRecognizer)
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
        
        //geometryNode.transform = SCNMatrix4MakeRotation(anglePan, -y, x, 0)
        
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
    
    
  
}


extension MDLMaterial {
    func setTextureProperties(textures: [MDLMaterialSemantic:String]) -> Void {
        for (key,value) in textures {
            guard let url = Bundle.main.url(forResource: value, withExtension: "") else {
                fatalError("Failed to find URL for resource \(value).")
            }
            let property = MDLMaterialProperty(name:value, semantic: key, url: url)
            self.setProperty(property)
        }
    }
}



