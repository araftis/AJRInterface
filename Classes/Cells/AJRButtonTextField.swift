//
//  AJRButtonTextField.m
//  AJRInterface
//
//  Created by A.J. Raftis on 2/17/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

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
            cell.alternateImage = templateImage?.ajr_templateImage(with: .alternateSelectedControlColor)
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
