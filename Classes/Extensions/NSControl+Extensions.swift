//
//  NSControl+Extensions.swift
//  AJRInterface
//
//  Created by AJ Raftis on 2/20/19.
//

import Foundation

import AJRFoundation

public extension NSControl {
    
    @objc(URLValue)
    var urlValue : URL? {
        get {
            return URL(parsableString: stringValue)
        }
        set {
            stringValue = newValue?.absoluteString ?? ""
        }
    }
    
}

