//
//  ObjectRecognitionViewController.swift
//  CoreMLDemos
//
//  Created by Kasey Schindler on 7/17/17.
//  Copyright © 2017 Kasey Schindler. All rights reserved.
//

import UIKit
import CoreML
import Vision

final class ObjectRecognitionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet private var pictureImageView: UIImageView!
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Properties
    
    private var objectRecognitionModel: VNCoreMLModel!
    private var results = [VNClassificationObservation]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        objectRecognitionModel = try? VNCoreMLModel(for: GoogLeNetPlaces().model)
    }
    
    // MARK: - IBActions
    
    @IBAction private func cameraButtonTapped() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        let camera = UIImagePickerController()
        camera.delegate = self
        camera.sourceType = .camera
        camera.allowsEditing = false
        
        present(camera, animated: true)
    }
    
    @IBAction private func libraryButtonTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        
        present(picker, animated: true)
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Object Cell", for: indexPath)
        let classification = results[indexPath.row]
        
        cell.textLabel?.text = classification.identifier
        cell.detailTextLabel?.text = "\(classification.confidence * 100)%"
        
        return cell
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }

        pictureImageView.image = image
        
        // analyze image
        let request = VNCoreMLRequest(model: objectRecognitionModel) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Error calculating results.")
            }
            
            self.results = results
        }
        
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        guard (try? handler.perform([request])) != nil else {
            fatalError("Error with the model.")
        }
    }
    
}
