//
//  LiveObjectRecognitionViewController.swift
//  CoreMLDemos
//
//  Created by Kasey Schindler on 7/25/17.
//  Copyright © 2017 Kasey Schindler. All rights reserved.
//

import UIKit
import AVFoundation

final class LiveObjectRecognitionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: - Private Properties
    
    private let session = AVCaptureSession()
    private let captureQueue = DispatchQueue(label: "captureQueue")
    private var capturePreviewLayer: AVCaptureVideoPreviewLayer?
    private var useCoreML = true
    
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
            captureView.layer.addSublayer(capturePreviewLayer!)
            
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
        if let capturePreviewLayer = capturePreviewLayer {
            session.stopRunning()
            capturePreviewLayer.removeFromSuperlayer()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let capturePreviewLayer = capturePreviewLayer {
            capturePreviewLayer.frame = captureView.bounds
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        ObjectRecognition.shared.analyzeImageBuffer(imageBuffer: sampleBuffer, withCoreML: useCoreML) { result in
            self.nameLabel.text = result["identifier"]
            self.confidenceLabel.text = result["confidence"]
        }
    }
    
    // MARK: - IBActions
    
    @IBAction private func useCoreMLSwitchChanged(sender: UISwitch) {
        useCoreML = sender.isOn
    }
    
}
