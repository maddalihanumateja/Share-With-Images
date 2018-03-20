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
    
    //MARK: Properties
    
    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return childViewControllers.lazy.flatMap({ $0 as? StatusViewController }).first!
    }()
    
    //Hide the default status bar in this view
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // A controller that keeps track of the images that have already been  detected
    // and decides on how to respond to the user (both through dialogue and executing the required actions associated with the inputs)
    
    var aiResponder: AIFeedbackController = AIFeedbackController(structuredInteraction: true, interactionStructure: [SharingImage.sharingImageType.Action, SharingImage.sharingImageType.Person])

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    // A variable that keeps track of the previous detected SharingImage ARAnchor and if it was presented in the correct sequence
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self as? ARSessionDelegate
        
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        
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
        
        struct previousNode {
            static var previousARAnchor: ARAnchor = ARAnchor(transform: matrix_float4x4())
            static var previousReturnCorrectInput: Bool = true
        }
        
        guard let imageAnchor = anchor as? ARImageAnchor else { return node }
        let referenceImage = imageAnchor.referenceImage
        
        let imageName: String = referenceImage.name ?? ""
        node.name = "parent;" + (imageName)
        
        // An example implementation where a gmail photo triggers opening the email app
        // when the obama picture has been shown previously (and is stored in the stack)
        
        // Generate a response to be shown in the status container for the input image
        let aiResponse = self.aiResponder.generateResponse(inputSharingImage: imageName)
        
        updateQueue.async {
            
            // Create a plane to visualize the initial position of the detected image.
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            let planeNode = SCNNode(geometry: plane)
            planeNode.name = referenceImage.name ?? ""
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
        
        DispatchQueue.main.sync {
            //Display the status message
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage(aiResponse.returnDialogue)
            
            // Perform the action (if any) after a delay of a few seconds
            let actionDelay: Int = 3
            if (aiResponse.returnActionURL != nil){
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(actionDelay), execute: {
                        UIApplication.shared.open(aiResponse.returnActionURL!)
                    }
                )
            }
        }
        
        // We want the ARAnchor for the incorrect input image to be removed ideally after the next image is detected (using something like removal after a delay just complicates things if the object stays in view). Else the image will just continue to be tracked invisibly till the ARSession is reset
        // Referred to this post https://stackoverflow.com/questions/27517632/how-to-create-a-delay-in-swift
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            if(!previousNode.previousReturnCorrectInput){
                
                print("Removing the previous ARAnchor")
                
                let tempAnchor: ARAnchor? = previousNode.previousARAnchor
                previousNode.previousARAnchor = ARAnchor(transform: matrix_float4x4())
                
                self.sceneView.session.remove(anchor: tempAnchor!)
                // Got the following line from https://stackoverflow.com/questions/45803884/arkit-how-to-reset-world-orientation-after-interruption
                self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    if(node.name == "parent;"+imageName){
                        node.removeFromParentNode()
                    }
                }
            }
            
            // Update previousReturnCorrectInput and previousARAnchor to the current values
            previousNode.previousARAnchor = anchor
            previousNode.previousReturnCorrectInput = aiResponse.returnCorrectInput
        })
        
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
    
    /// Prevents restarting the session while a restart is in progress.
    var isRestartAvailable = true
    
    /// Creates a new AR configuration to run on the `session`.
    /// - Tag: ARReferenceImage-Loading
    func resetTracking() {
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Clear the sharingImage input history to delete records of previously detected images
        self.aiResponder.clearHistory()
        
        // Load the images to be tracked and cast them as ARReferenceImage
        guard let sharingImages =  NSKeyedUnarchiver.unarchiveObject(withFile: SharingImage.ArchiveURL.path) as? [SharingImage] else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let referenceCGImages = sharingImages.map{$0.photo.cgImage!}
        var referenceARImages: Set<ARReferenceImage> = Set<ARReferenceImage>()
        
        for (index,referenceCGImage) in referenceCGImages.enumerated(){
            let referenceARImage = ARReferenceImage(referenceCGImage, orientation: CGImagePropertyOrientation.up, physicalWidth: CGFloat(0.1))
            referenceARImage.name = "\(sharingImages[index].name);\(sharingImages[index].type.rawValue)"
            referenceARImages.insert(referenceARImage)
        }
        
        configuration.detectionImages = referenceARImages
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        statusViewController.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
        
        switch camera.trackingState {
        case .notAvailable, .limited:
            statusViewController.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
        case .normal:
            statusViewController.cancelScheduledMessage(for: .trackingStateEscalation)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Use `flatMap(_:)` to remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        blurView.isHidden = false
        statusViewController.showMessage("""
        SESSION INTERRUPTED
        The session will be reset after the interruption has ended.
        """, autoHide: false)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
        blurView.isHidden = true
        statusViewController.showMessage("RESETTING SESSION")

        // Reset tracking and/or remove existing anchors if consistent tracking is required
        restartExperience()
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    // MARK: - Error handling
    
    func displayErrorMessage(title: String, message: String) {
        // Blur the background.
        blurView.isHidden = false
        
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.blurView.isHidden = true
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Interface Actions
    
    func restartExperience() {
        guard isRestartAvailable else { return }
        isRestartAvailable = false
        
        statusViewController.cancelAllScheduledMessages()
        
        resetTracking()
        
        // Disable restart for a while in order to give the session time to restart.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
        }
    }
}
