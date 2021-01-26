//
//  NSAppearance+Extensions.swift
//  AJRInterface
//
//  Created by AJ Raftis on 2/12/20.
//

import AppKit

@objc
public extension NSAppearance {
    
    @objc var isDarkMode : Bool {
        switch self.name {
        case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
            return true
        default:
            return false
        }
    }
    
}
