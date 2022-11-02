/*
 AJRButtonTextField.swift
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

@objc
public enum AJRButtonTextFieldButtonPosition : Int {
    
    case `default`
    case followsText
    case trailing
    
}

@objcMembers
open class AJRButtonTextField : NSTextField {

    static internal var buttonTextFieldCellClass : AnyObject.Type = AJRButtonTextFieldCell.self

    open class override var cellClass : AnyObject.Type? {
        get {
            return Self.buttonTextFieldCellClass
        }
        set {
            Self.buttonTextFieldCellClass = newValue ?? AJRButtonTextFieldCell.self
        }
    }

    open var buttonTarget : AnyObject? {
        get {
            return (cell as? AJRButtonTextFieldCell)?.buttonTarget
        }
        set {
            (cell as? AJRButtonTextFieldCell)?.buttonTarget = newValue
        }
    }
    
    open var buttonAction : Selector? {
        get {
            return (cell as? AJRButtonTextFieldCell)?.buttonAction
        }
        set {
            (cell as? AJRButtonTextFieldCell)?.buttonAction = newValue
        }
    }
    
    open var buttonPosition : AJRButtonTextFieldButtonPosition {
        get {
            return (cell as? AJRButtonTextFieldCell)?.buttonPosition ?? .default
        }
        set {
            (cell as? AJRButtonTextFieldCell)?.buttonPosition = newValue
            needsDisplay = true
        }
    }
    
    open func setImages(withTemplate templateImage: NSImage?) -> Void {
        if let cell = cell as? AJRButtonTextFieldCell {
            cell.image = templateImage?.ajr_templateImage(with: .secondaryLabelColor)
            cell.alternateImage = templateImage?.ajr_templateImage(with: .selectedContentBackgroundColor)
            cell.highlightImage = templateImage?.ajr_templateImage(with: .controlBackgroundColor)
        }
    }
    
    open override func mouseDown(with event: NSEvent) {
        if cell?.hitTest(for: event, in: bounds, of: self) == .trackableArea {
            cell?.trackMouse(with: event, in: bounds, of: self, untilMouseUp: true)
        } else {
            super.mouseDown(with: event)
        }
    }

}
