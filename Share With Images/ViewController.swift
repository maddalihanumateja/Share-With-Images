//
//  ViewController.swift
//  Share With Images
//
//  Created by Hanuma Teja Maddali on 3/10/18.
//  Copyright © 2018 Hanuma Teja Maddali. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        resetTracking()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start the AR experience
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        guard let imageAnchor = anchor as? ARImageAnchor else { return node}
        let referenceImage = imageAnchor.referenceImage
        updateQueue.async {
            
            // Create a plane to visualize the initial position of the detected image.
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 0.25
            
            /*
             `SCNPlane` is vertically oriented in its local coordinate space, but
             `ARImageAnchor` assumes the image is horizontal in its local space, so
             rotate the plane to match.
             */
            planeNode.eulerAngles.x = -.pi / 2
            
            /*
             Image anchors are not tracked after initial detection, so create an
             animation that limits the duration for which the plane visualization appears.
             */
            planeNode.runAction(self.imageHighlightAction)
            
            // Add the plane visualization to the scene.
            node.addChildNode(planeNode)
        }
        
        DispatchQueue.main.async {
            let imageName = referenceImage.name ?? ""
            print("Detected image “\(imageName)”")
            if imageName == "gmail"{
                let email = "foo@bar.com"
                if let url = URL(string: "mailto:\(email)") {
                    UIApplication.shared.open(url)
                }
            }
        }
    
        return node
    }
     
     var imageHighlightAction: SCNAction {
     return .sequence([
     .wait(duration: 0.25),
     .fadeOpacity(to: 0.85, duration: 0.25),
     .fadeOpacity(to: 0.15, duration: 0.25),
     .fadeOpacity(to: 0.85, duration: 0.25),
     .fadeOut(duration: 0.5),
     .removeFromParentNode()
     ])
     }
 
    // MARK: - Session management (Image detection setup)
    
    /// Creates a new AR configuration to run on the `session`.
    /// - Tag: ARReferenceImage-Loading
    func resetTracking() {
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Load the images to be tracked and cast them as ARReferenceImage
        guard let sharingImages =  NSKeyedUnarchiver.unarchiveObject(withFile: SharingImage.ArchiveURL.path) as? [SharingImage] else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let referenceCGImages = sharingImages.map{$0.photo.cgImage!}
        var referenceARImages: Set<ARReferenceImage> = Set<ARReferenceImage>()
        
        for (index,referenceCGImage) in referenceCGImages.enumerated(){
            let referenceARImage = ARReferenceImage(referenceCGImage, orientation: CGImagePropertyOrientation.up, physicalWidth: CGFloat(0.1))
            referenceARImage.name = sharingImages[index].name
            referenceARImages.insert(referenceARImage)
        }
        
        configuration.detectionImages = referenceARImages
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        resetTracking()
    }
}
