//
//  StaticObjectRecognitionViewController.swift
//  CoreMLDemos
//
//  Created by Kasey Schindler on 7/17/17.
//  Copyright © 2017 Kasey Schindler. All rights reserved.
//

import UIKit
import CoreML
import Vision

final class StaticObjectRecognitionViewController: ObjectRecognitionViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet private var pictureImageView: UIImageView!
    @IBOutlet private var tableView: UITableView!
    
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
        cell.detailTextLabel?.text = "\((classification.confidence * 100).rounded())%"
        
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
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        
        analyze(handler: handler) { results in
            self.results = results
            self.tableView.reloadData()
        }
    }
    
}
