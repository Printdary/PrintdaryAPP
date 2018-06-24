//
//  ARKitCameraViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 07.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import ARKit
import Firebase
import FirebaseStorage


class ARKitCameraViewController: UIViewController, ARSCNViewDelegate , SCNSceneRendererDelegate{

    @IBOutlet weak var sceneView: ARSCNView!
    var appObj = UIApplication.shared.delegate as! AppDelegate
    var hitNote : SCNNode?
    var currentScale1: Float = 0
    var currentScale2: Float = 0
    var currentScale3: Float = 0
    var isLoaded = false
    var actInd: UIActivityIndicatorView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        let assimpScene: SCNAssimpScene?
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.showsStatistics = false
        sceneView.allowsCameraControl = true
        sceneView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if DetectedUnitView.model_name != nil {
            dawnload3DObjectsFrom(url: DetectedUnitView.model_name!)
        }
      
       // ARKitWrapper.shared().loadScen("", view: self.sceneView)
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gestureRecognize:)))
        sceneView?.addGestureRecognizer(panRecognizer)
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scalePiece(gestureRecognizer:)))
        sceneView?.addGestureRecognizer(pinchRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARKitCameraViewController.addModelToSceneView(withGestureRecognizer:)))
        sceneView?.addGestureRecognizer(tapGestureRecognizer)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @objc func addModelToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z
        let vek = SCNVector3(x,y,z)
        ARKitWrapper.shared().pos = vek
        if (ARKitWrapper.shared().scene != nil) {
        for ob in ARKitWrapper.shared().scene.rootNode.childNodes {
            ob.position = vek
        }
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
        //sceneView.scene.rootNode.childNodes[0].rotation = rotationVector
       // sceneView.scene.rootNode.childNodes[2].rotation = rotationVector
        for no in  sceneView.scene.rootNode.childNodes {
            no.rotation = rotationVector
        }
       // self.sceneView.scene.rootNode.transform = SCNMatrix4MakeRotation(anglePan, -y, x, 0)
        if !isLoaded {
             //dawnloadModel()
       // uploadModelToFirebase()
        }
       
    }
    
    func uploadModelToFirebase(){
         isLoaded = true
        let imageName = NSUUID().uuidString // Unique string to reference image
         var storage     =   Storage.storage()
        //Create storage reference for image
        let storageRef = storage.reference().child("SCNModels").child("\(imageName).zip")
        let uploadTask = storageRef.putFile(from: URL.init(fileURLWithPath: ARKitWrapper.shared().uploadPath), metadata: nil, completion: { (metadata, error) in
            if error != nil{
                print(error)
                return
            }
            if let modelURL = metadata?.downloadURL()?.absoluteString{
                print(modelURL)
                let dbRef = Database.database().reference().child("SCNModels").child("Citric_Acid")
                dbRef.updateChildValues(["dawnloadURL": modelURL])
            }
            
        })
    }
    func dawnloadModel(){
        isLoaded = true
        let url1 = URL.init(string: "https://firebasestorage.googleapis.com/v0/b/ziyadios-451ea.appspot.com/o/SCNModels%2FF40115B6-511F-4AD2-A89C-A1E8812461EB.zip?alt=media&token=86382889-9026-4207-ac26-28a98bc79c5a")
        URLSession.shared.downloadTask(with: url1!) { (url, res, error) in
            if error != nil {
                print(error)
            }
            do {
               // let obj = try NSKeyedUnarchiver.unarchiveObject(with: Data.init(contentsOf: url!))
            }catch {
                
            }
            ARKitWrapper.shared().loadScen("\(url!)", view: self.sceneView)
            print(res)
        }.resume()
    }
    
    
    
    func dawnload3DObjectsFrom(url: String) {
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
                    
                    DispatchQueue.main.async {
                        self.actInd?.stopAnimating()
                    }
                    ARKitWrapper.shared().loadScen(url?.absoluteString, view: self.sceneView)
                }).resume()
                
            }
        }
    }
    
    @IBAction func arOffButtonAction(_ sender: UIButton) {
         self.navigationController?.popViewController(animated: false)
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
    
    
    @objc func scalePiece(gestureRecognizer : UIPinchGestureRecognizer) {
        if gestureRecognizer.state == .changed {
            
//            guard let sceneView = gestureRecognizer.view as? ARSCNView else {
//                return
//            }
            
            let touch = gestureRecognizer.location(in: sceneView)
            
            let hitTestResults = self.sceneView.hitTest(touch, options: nil)
            
            if let hitTest = hitTestResults.first {
                
                let chairNode = sceneView.scene.rootNode.childNodes[0]
                
                let pinchScaleX = Float(gestureRecognizer.scale) * chairNode.scale.x
                let pinchScaleY = Float(gestureRecognizer.scale) * chairNode.scale.y
                let pinchScaleZ = Float(gestureRecognizer.scale) * chairNode.scale.z
                
                for no in  sceneView.scene.rootNode.childNodes {
                    no.scale = SCNVector3(pinchScaleX,pinchScaleY,pinchScaleZ)
                }
                
                
                gestureRecognizer.scale = 1
                
            }
        }
    }
    

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
  
    
    /*
     Called when a SceneKit node's properties have been
     updated to match the current state of its corresponding anchor.
     */
    func renderer(_ renderer: SCNSceneRenderer,
                  didUpdate node: SCNNode, for anchor: ARAnchor) {
        if !anchor.isKind(of: ARPlaneAnchor.self) {
            DispatchQueue.main.async {
                print("anchor =\(anchor.transform.columns)")
                let modelClone = ARKitWrapper.shared().scene.rootNode.childNodes[0]
                //self.hitNote?.rotation = SCNVector4Make(12, 76, 1, 22)
                // Add model as a child of the node
                modelClone.rotation = SCNVector4Make(12, 76, 1, 22)
                node.addChildNode(modelClone)
            }
        }
        // ...
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //if !anchor.isKind(of: ARPlaneAnchor.self) {
//            DispatchQueue.main.async {
//                let modelClone = ARKitWrapper.shared().scene.rootNode.clone()
//                modelClone.position = SCNVector3Make(0, 0, 69)
//
//                // Add model as a child of the node
//                node.addChildNode(modelClone)
//            }
//        }
            
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            
            // 2
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            let plane = SCNPlane(width: width, height: height)
            
            // 3
            plane.materials.first?.diffuse.contents = UIColor.clear
            
            // 4
            let planeNode = SCNNode(geometry: plane)
            
            // 5
            let x = CGFloat(planeAnchor.center.x)
            let y = CGFloat(planeAnchor.center.y)
            let z = CGFloat(planeAnchor.center.z)
            planeNode.position = SCNVector3(x,y,z)
            planeNode.eulerAngles.x = -.pi / 2
            
            // 6
            node.addChildNode(planeNode)
    }
    /*
     Called when SceneKit node corresponding to a removed
     AR anchor has been removed from the scene.
     */
    func renderer(_ renderer: SCNSceneRenderer,
                  didRemove node: SCNNode, for anchor: ARAnchor) {
        // ...
    }
    func getParent(_ nodeFound: SCNNode?) -> SCNNode? {
        if let node = nodeFound {
            if node.name == "Cam" {
                return node
            } else if let parent = node.parent {
                return getParent(parent)
            }
        }
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
//        UserDefaults.standard.set(true, forKey: "FromARmode")
//        self.dismiss(animated: true, completion: {
//          
//        })
        self.navigationController?.popToRootViewController(animated: false)
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
