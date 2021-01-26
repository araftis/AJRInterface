//
//  NSImage+Extensions.swift
//  AJRInterface
//
//  Created by AJ Raftis on 7/13/20.
//

import Foundation

public extension NSImage {

    var basicCGImage : CGImage? {
        return cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
}
