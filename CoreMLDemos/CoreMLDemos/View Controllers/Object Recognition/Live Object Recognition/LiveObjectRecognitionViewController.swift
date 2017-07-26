//
//  LiveObjectRecognitionViewController.swift
//  CoreMLDemos
//
//  Created by Kasey Schindler on 7/25/17.
//  Copyright © 2017 Kasey Schindler. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation

final class LiveObjectRecognitionViewController: ObjectRecognitionViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: - Private Properties
    
    private let session = AVCaptureSession()
    private let captureQueue = DispatchQueue(label: "captureQueue")
    private var capturePreviewLayer: AVCaptureVideoPreviewLayer!
    
    // MARK: - IBOutlets
    
    @IBOutlet private var captureView: UIView!
    @IBOutlet private var resultView: UIView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var confidenceLabel: UILabel!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // some view setup
        resultView.layer.cornerRadius = 16
        
        // setup the video camera session
        // first see if the camera is even available - need a device, if not - show alert
        if let camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) {
            // add the capture layer to the capture view so we can see the camera session
            capturePreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            captureView.layer.addSublayer(capturePreviewLayer)
            
            // create input and output streams for the camera
            let cameraInputDevice = try? AVCaptureDeviceInput(device: camera)
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: captureQueue)
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
            
            // setup the session
            session.sessionPreset = AVCaptureSessionPresetHigh
            session.addInput(cameraInputDevice)
            session.addOutput(videoOutput)
            
            let connection = videoOutput.connection(withMediaType: AVMediaTypeVideo)
            connection?.videoOrientation = .portrait
            
            session.startRunning()
        } else {
            let alertVC = UIAlertController(title: NSLocalizedString("Video Capture Not Available", comment: ""), message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
            alertVC.addAction(okAction)
            present(alertVC, animated: true)
        }
    }
    
    deinit {
        // tear down session
        session.stopRunning()
        capturePreviewLayer.removeFromSuperlayer()
        capturePreviewLayer = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        capturePreviewLayer.frame = captureView.bounds
    }
    
    func captureOutput(_ output: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            // error processing buffer
            return
        }
        
        var options : [VNImageOption : Any] = [:]
        
        if let data = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            options = [.cameraIntrinsics : data]
        }
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .downMirrored, options: options)
        analyze(handler: requestHandler) { results in
            let classification = results[0]
            self.nameLabel.text = classification.identifier
            self.confidenceLabel.text = "\((classification.confidence * 100).rounded())%"
        }
    }
    
}
