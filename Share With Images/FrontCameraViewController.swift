//
//  FrontCameraViewControllerViewController.swift
//

import AVFoundation
import Vision
import UIKit
import os.log

class FrontCameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var highlightView: UIView!{
        didSet {
            self.highlightView?.layer.borderColor = UIColor.red.cgColor
            self.highlightView?.layer.borderWidth = 4
            self.highlightView?.backgroundColor = .clear
        }
    }
    
    
    //Hide the default status bar in this view
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard
            let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: frontCamera)
            else { return session }
        session.addInput(input)
        return session
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make the camera appear on the screen
        self.cameraView?.layer.addSublayer(self.cameraLayer)
        
        // hide the red focus area on load
        self.highlightView?.frame = .zero
        
        // register to receive buffers from the camera
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        self.captureSession.addOutput(videoOutput)
        
        // begin the session
        self.captureSession.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // make sure the layer is the correct size
        self.cameraLayer.frame = self.cameraView?.bounds ?? .zero
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard
            // make sure the pixel buffer can be converted
            let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            else { return }
        
        var requestOptions: [VNImageOption: Any] = [:]
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics: cameraIntrinsicData]
        }
        let visionImageHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: requestOptions)
        let rectFinderRequest = VNDetectRectanglesRequest(completionHandler: handleRectRequest)
        rectFinderRequest.minimumConfidence = 0.7
        rectFinderRequest.maximumObservations = 1
        do {
            try visionImageHandler.perform([rectFinderRequest])
        } catch {
            print(error)
        }
    }
    
    private func handleRectRequest(_ request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
        // make sure we have an actual result
        guard let newObservation = request.results?.first as? VNRectangleObservation else {
            // hide the red focus area
            self.highlightView?.frame = .zero
            return }
        //for observation in (request.results) {
            //guard let rectObservation = observation as! VNRectangleObservation else {return}
            var rectBoundingBox = newObservation.boundingBox
            //rectBoundingBox.origin.y = 1 - rectBoundingBox.origin.y
            //rectBoundingBox.origin.x = 1 - rectBoundingBox.origin.x
            print(rectBoundingBox)
        let convertedRect = self.cameraLayer.layerRectConverted(fromMetadataOutputRect: rectBoundingBox)
        
        // move the highlight view
        self.highlightView?.frame = convertedRect
        //}
        }
    }
    
}
