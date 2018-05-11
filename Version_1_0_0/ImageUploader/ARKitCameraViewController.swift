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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        
        //        let assimpScene: SCNAssimpScene?
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.showsStatistics = false
        sceneView.allowsCameraControl = false

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
        self.sceneView.pointOfView?.position = SCNVector3Make(78, 13,  13);
         self.sceneView.scene.rootNode.rotation = rotationVector
        
        self.sceneView.scene.rootNode.transform = SCNMatrix4MakeRotation(anglePan, -y, x, 0)
        
        if(gestureRecognize.state == UIGestureRecognizerState.ended) {
            let currentPivot = self.sceneView.scene.rootNode.pivot
            let changePivot = SCNMatrix4Invert( (self.sceneView.scene.rootNode.transform))
         
           self.sceneView.scene.rootNode.pivot = SCNMatrix4Mult(changePivot, currentPivot)
            
          self.sceneView.scene.rootNode.transform = SCNMatrix4Identity
        }
    }
    
    
//    @objc func scalePiece(gestureRecognizer : UIPinchGestureRecognizer) {   guard gestureRecognizer.view != nil else { return }
//        
//        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
//            
//            let scale = Float(gestureRecognizer.scale)
//            
//            let newscalex = scale / currentscalex
//            let newscaley = scale / currentscaley
//            let newscalez = scale / currentscalez
//            
//            self.drone.scale = SCNVector3(newscalex, newscaley, newscalez)
//            
//        }}
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
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
