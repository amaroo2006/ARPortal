//
//  ViewController.swift
//  ARPortal
//
//  Created by Ansh Maroo on 9/8/19.
//  Copyright © 2019 Mygen Contac. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var planeDetected: UILabel!
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        //Set the ARSCNDelegate
        sceneView.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if !hitTestResult.isEmpty {
            //add the room
            addPortal(hitTestResult: hitTestResult.first!)
        }
    }
    
    func addPortal(hitTestResult: ARHitTestResult) {
        let portalScene = SCNScene(named: "Portal.scnassets/Portal.scn")
        let portalNode = portalScene?.rootNode.childNode(withName: "Portal", recursively: false)
        let transform = hitTestResult.worldTransform
        let planeXposition = transform.columns.3.x
        let planeYposition = transform.columns.3.y
        let planeZposition = transform.columns.3.z
        portalNode?.position = SCNVector3(planeXposition,planeYposition,planeZposition)
        sceneView.scene.rootNode.addChildNode(portalNode!)
        addPlane(nodeName: "roof", portalNode: portalNode!, imageName: "top")
        addPlane(nodeName: "floor", portalNode: portalNode!, imageName: "bottom")
        addWalls(nodeName: "backWall", portalNode: portalNode!, imageName: "back")
        addWalls(nodeName: "sideWallA", portalNode: portalNode!, imageName: "sideA")
        addWalls(nodeName: "sideWallB", portalNode: portalNode!, imageName: "sideB")
        addWalls(nodeName: "sideDoorA", portalNode: portalNode!, imageName: "sideDoorA")
        addWalls(nodeName: "sideDoorB", portalNode: portalNode!, imageName: "sideDoorB")
    }
    
    func addPlane(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named:"Portal.scnassets/\(imageName).png")
        child?.renderingOrder = 200
    }
    func addWalls(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named:"Portal.scnassets/\(imageName).png")
        
        child?.renderingOrder = 200
        
        if let mask = child?.childNode(withName: "mask", recursively: false) {
            mask.geometry?.firstMaterial?.transparency = 0.000001
            
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        DispatchQueue.main.async {
            self.planeDetected.isHidden = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.planeDetected.isHidden = true
        }
    }
    
}
