//
//  ObjectRecognition.swift
//  CoreMLDemos
//
//  Created by Kasey Schindler on 7/25/17.
//  Copyright © 2017 Kasey Schindler. All rights reserved.
//

import AVFoundation
import CoreML
import Vision

final class ObjectRecognition {
    
    static let shared = ObjectRecognition()
    private let coreMLModel: Inceptionv3
    private let visionModel: VNCoreMLModel

    private init() {
        coreMLModel = Inceptionv3()
        visionModel = try! VNCoreMLModel(for: Inceptionv3().model)
    }
    
    func analyze(handler: VNImageRequestHandler, completion: @escaping ([VNClassificationObservation]) -> ()) {
        let request = VNCoreMLRequest(model: visionModel) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Error calculating results.")
            }
            
            let classifications = results[0...6].flatMap({ $0 })
            
            DispatchQueue.main.async {
                completion(classifications)
            }
        }
        
        request.imageCropAndScaleOption = .centerCrop
        
        // execute handler
        guard (try? handler.perform([request])) != nil else {
            fatalError("Error with the model.")
        }
    }
    
    func analyzeImageBuffer(imageBuffer: CMSampleBuffer, withCoreML: Bool, completion: @escaping ([String : String]) -> ()) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(imageBuffer) else {
            return
        }
        
        if withCoreML {
            // analysis done with Core ML framework
            do {
                let prediction = try coreMLModel.prediction(image: resize(pixelBuffer: pixelBuffer)!)
                
                var identifier = "Unknown"
                var confidence = "Unknown"
                
                if let prob = prediction.classLabelProbs[prediction.classLabel] {
                    identifier = prediction.classLabel
                    confidence = "\((prob * 100).rounded())"
                }
            
                DispatchQueue.main.async {
                    completion(["identifier" : identifier, "confidence" : confidence])
                }
            } catch let error as NSError {
                fatalError("Unexpected error ocurred: \(error.localizedDescription).")
            }
        } else {
            // analysis done with Vision framework
            let request = VNCoreMLRequest(model: visionModel) { request, error in
                guard let results = request.results as? [VNClassificationObservation] else {
                    fatalError("Error calculating results.")
                }
                
                var identifier = "Unknown"
                var confidence = "Unknown"
                
                if let classification = results.first {
                    identifier = classification.identifier
                    confidence = "\((classification.confidence * 100).rounded())"
                }
                
                DispatchQueue.main.async {
                    completion(["identifier" : identifier, "confidence" : confidence])
                }
            }
            
            request.imageCropAndScaleOption = .centerCrop
            
            // options for handler
            var options : [VNImageOption : Any] = [:]
            
            if let cameraIntrinsicData = CMGetAttachment(imageBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
                options = [.cameraIntrinsics : cameraIntrinsicData]
            }
            
            // execute handler
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .down, options: options)
            
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    private func resize(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        let imageSide = 299
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer, options: nil)
        let transform = CGAffineTransform(scaleX: CGFloat(imageSide) / CGFloat(CVPixelBufferGetWidth(pixelBuffer)), y: CGFloat(imageSide) / CGFloat(CVPixelBufferGetHeight(pixelBuffer)))
        ciImage = ciImage.applying(transform).cropping(to: CGRect(x: 0, y: 0, width: imageSide, height: imageSide))
        let ciContext = CIContext()
        var resizeBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, imageSide, imageSide, CVPixelBufferGetPixelFormatType(pixelBuffer), nil, &resizeBuffer)
        ciContext.render(ciImage, to: resizeBuffer!)
        
        return resizeBuffer
    }
}
