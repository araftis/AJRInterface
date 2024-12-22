//
//  NSScreen+Extensions.swift
//  AJRInterface
//
//  Created by AJ Raftis on 4/22/23.
//

import AppKit
import AJRInterfaceFoundation

@objc
public extension NSScreen {

    var resolution : NSSize {
        if let resolution = (deviceDescription[.resolution] as? NSValue)?.sizeValue {
            return resolution
        }
        return NSSize(width: 92.0, height: 92.0) // Punt...
    }

}
