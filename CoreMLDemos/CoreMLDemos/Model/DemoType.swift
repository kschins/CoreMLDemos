//
//  DemoType.swift
//  CoreMLDemos
//
//  Created by Kasey Schindler on 7/17/17.
//  Copyright © 2017 Kasey Schindler. All rights reserved.
//

import Foundation

enum DemoType: Int {
    case objectRecognition, tbd
    
    func name() -> String {
        switch self {
        case .objectRecognition:
            return NSLocalizedString("Object Recognition", comment: "")
        case .tbd:
            return NSLocalizedString("To Be Determined", comment: "")
        }
    }
    
    static func count() -> Int {
        return 2
    }
}
