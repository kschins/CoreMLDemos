//
//  StaticObjectRecognitionViewController.swift
//  CoreMLDemos
//
//  Created by Kasey Schindler on 7/17/17.
//  Copyright © 2017 Kasey Schindler. All rights reserved.
//

import UIKit
import Vision

final class StaticObjectRecognitionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: - Properties
    private var results = [VNClassificationObservation]()
    
    // MARK: - IBOutlets
    
    @IBOutlet private var pictureImageView: UIImageView!
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - IBActions
    
    @IBAction private func cameraButtonTapped() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alertVC = UIAlertController(title: NSLocalizedString("Camera Not Available on this Device.", comment: ""), message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
            alertVC.addAction(okAction)
            present(alertVC, animated: true)
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
        
        ObjectRecognition.shared.analyze(handler: handler) { results in
            self.results = results
            self.tableView.reloadData()
        }
    }
    
}
