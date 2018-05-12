//
//  ARKitCameraViewController.swift
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 07.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

import UIKit
import ARKit



class ARKitCameraViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    var appObj = UIApplication.shared.delegate as! AppDelegate
    var hitNote : SCNNode?
    var currentScale1: Float = 4.0
    var currentScale2: Float = 2.0
    var currentScale3: Float = 3.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        
        //        let assimpScene: SCNAssimpScene?
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.showsStatistics = false
        sceneView.allowsCameraControl = true
        sceneView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()//AROrientationTrackingConfiguration()//ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let path = UserDefaults.standard.value(forKey: "filePath") as? String {
            ARKitWrapper.shared().loadScen(path, view: self.sceneView)
        }
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gestureRecognize:)))
        sceneView?.addGestureRecognizer(panRecognizer)
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scalePiece(gestureRecognizer:)))
        sceneView?.addGestureRecognizer(pinchRecognizer)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
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
        sceneView.scene.rootNode.childNodes[0].rotation = rotationVector
        
       // self.sceneView.scene.rootNode.transform = SCNMatrix4MakeRotation(anglePan, -y, x, 0)
        
        if(gestureRecognize.state == UIGestureRecognizerState.ended) {
            let currentPivot = self.sceneView.scene.rootNode.pivot
            let changePivot = SCNMatrix4Invert( (self.sceneView.scene.rootNode.transform))
         
           //sceneView.scene.rootNode.childNodes[0].pivot = SCNMatrix4Mult(changePivot, currentPivot)
            
           //sceneView.scene.rootNode.childNodes[0].transform = SCNMatrix4Identity
        }
    }
    
    
    @objc func scalePiece(gestureRecognizer : UIPinchGestureRecognizer) {
        guard gestureRecognizer.view != nil
            else { return }
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            
            let scale = Float(gestureRecognizer.scale)
            
            let newscalex = scale / 4
            let newscaley = scale / 4
            let newscalez = scale / 4
            sceneView.scene.rootNode.childNodes[0].scale = SCNVector3(newscalex, newscaley, newscalez)
            //currentScale = newscalex
            
        }}
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let location = touches.first!.location(in: sceneView)
//        var hitTestOptions = [SCNHitTestOption: Any]()
//        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
//        let hitResults: [SCNHitTestResult]  =
//            sceneView.hitTest(location, options: hitTestOptions)
//        if let hit = hitResults.first {
//            hitNote = hit.node
//            //if let node = getParent(hit.node) {
//            print("note name = \(hit.node.name)")
//                sceneView.scene.rootNode.childNodes[0].rotation = SCNVector4Make(12, 76, 1, 22)
//               // return
//           // }
//        }

//        let hitResultsFeaturePoints: [ARHitTestResult] =
//            sceneView.hitTest(location, types: .featurePoint)
//        if let hit = hitResultsFeaturePoints.first {
//            // Get a transformation matrix with the euler angle of the camera
//            let rotate = simd_float4x4(SCNMatrix4MakeRotation(sceneView.session.currentFrame!.camera.eulerAngles.y, 0, 1, 0))
//
//            // Combine both transformation matrices
//            let finalTransform = simd_mul(hit.worldTransform, rotate)
//
//            // Use the resulting matrix to position the anchor
//            sceneView.session.add(anchor: ARAnchor(transform: finalTransform))
//            // sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
       // }
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
        if !anchor.isKind(of: ARPlaneAnchor.self) {
            DispatchQueue.main.async {
                let modelClone = ARKitWrapper.shared().scene.rootNode.clone()
                modelClone.position = SCNVector3Make(0, 0, 69)
                
                // Add model as a child of the node
                node.addChildNode(modelClone)
            }
        }
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
        self.dismiss(animated: true, completion: nil)
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
