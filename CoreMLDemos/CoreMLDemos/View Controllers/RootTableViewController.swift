//
//  RootTableViewController.swift
//  CoreMLDemos
//
//  Created by Kasey Schindler on 7/17/17.
//  Copyright © 2017 Kasey Schindler. All rights reserved.
//

import UIKit

final class RootTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DemoType.count()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let demoType = DemoType(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Basic Cell", for: indexPath)
        cell.textLabel?.text = demoType.name()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let demoType = DemoType(rawValue: indexPath.row) else {
            return
        }
        
        switch demoType {
        case .staticObjectRecognition:
            let storyboard = UIStoryboard(name: "StaticObjectRecognition", bundle: nil)
            if let vc = storyboard.instantiateInitialViewController() {
                navigationController?.pushViewController(vc, animated: true)
            }
        case .liveObjectRecognition:
            let storyboard = UIStoryboard(name: "LiveObjectRecognition", bundle: nil)
            if let vc = storyboard.instantiateInitialViewController() {
                navigationController?.pushViewController(vc, animated: true)
            }
        case .tbd:
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
    }

}
