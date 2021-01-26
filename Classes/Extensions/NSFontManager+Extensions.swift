//
//  NSFontManager+Extensions.swift
//  AJRInterface
//
//  Created by AJ Raftis on 7/21/20.
//

import Foundation

public extension NSFontManager {
    
    func convertWeight(by count: Int, of font: NSFont) -> NSFont {
        var newFont = font
        
        if count > 0 {
            for _ in 0 ..< count {
                newFont = convertWeight(true, of: newFont)
            }
        } else {
            for _ in 0 ..< abs(count) {
                newFont = convertWeight(false, of: newFont)
            }
        }
        
        return newFont
    }
    
}
