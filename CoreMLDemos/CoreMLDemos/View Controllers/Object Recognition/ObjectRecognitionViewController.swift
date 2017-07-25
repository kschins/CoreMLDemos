//
//  ObjectRecognitionViewController.swift
//  CoreMLDemos
//
//  Created by Kasey Schindler on 7/25/17.
//  Copyright © 2017 Kasey Schindler. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ObjectRecognitionViewController: UIViewController {

    // MARK: - Properties
    
    private var objectRecognitionModel: VNCoreMLModel!
    private var requests = [VNRequest]()
    var results = [VNClassificationObservation]()

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        objectRecognitionModel = try? VNCoreMLModel(for: Inceptionv3().model)
    }
    
    // MARK: - IBActions
    
    func analyze(handler: VNImageRequestHandler, completion: @escaping ([VNClassificationObservation]) -> ()) {
        let request = VNCoreMLRequest(model: objectRecognitionModel) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Error calculating results.")
            }
            
            let classifications = results[0...4].flatMap({ $0 })
            
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
}
