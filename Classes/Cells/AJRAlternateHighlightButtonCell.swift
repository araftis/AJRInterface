/*
 AJRAlternateHighlightButtonCell.swift
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Cocoa

@objcMembers
open class AJRAlternateHighlightButtonCell: NSButtonCell {
    
    @IBInspectable var tintColor = NSColor(calibratedWhite: 1.0, alpha: 0.7) {
        didSet {
            print("color now: \(tintColor)")
        }
    }
    @IBInspectable var highlightedTintColor = NSColor.selectedContentBackgroundColor
    @IBInspectable var disabledTintColor = NSColor(calibratedWhite: 1.0, alpha: 0.3)

    open func completeInit() {
        if alternateImage == nil, let image = image, image.isTemplate {
            alternateImage = image.ajr_imageTinted(with: highlightedTintColor)
        }
    }
    
    public override init(imageCell image: NSImage?) {
        super.init(imageCell: image)
        completeInit()
    }
    
    public override init(textCell string: String) {
        super.init(textCell: string)
        completeInit()
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)
        completeInit()
    }
    
    public override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        if let button = controlView as? NSButton {
            if button.isBordered {
                super.drawInterior(withFrame: cellFrame, in: controlView)
            } else {
                var color : NSColor? = nil
                
                if button.isEnabled {
                    if button.isHighlighted {
                        color = highlightedTintColor
                    } else {
                        color = tintColor
                    }
                } else {
                    color = disabledTintColor
                }
                
                if let color = color, let image = self.image {
                    let tintedImage = image.ajr_imageTinted(with: color)
                    tintedImage.draw(in: cellFrame)
                }
            }
        }
    }
    
    open override func copy(with zone: NSZone? = nil) -> Any {
        if let copy = super.copy(with: zone) as? AJRAlternateHighlightButtonCell {
            copy.tintColor = tintColor.copy(with: zone) as! NSColor
            AJRForceRetain(copy.tintColor)
            copy.highlightedTintColor = highlightedTintColor.copy(with: zone) as! NSColor
            AJRForceRetain(copy.highlightedTintColor)
            copy.disabledTintColor = disabledTintColor.copy(with: zone) as! NSColor
            AJRForceRetain(copy.disabledTintColor)
            return copy
        }
        preconditionFailure("Calling super.\(#function) didn't produce an instance of \(Self.self).")
    }

}
