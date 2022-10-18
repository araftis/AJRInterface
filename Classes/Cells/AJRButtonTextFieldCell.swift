/*
AJRButtonTextFieldCell.swift
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
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

import AJRFoundation

@objcMembers
open class AJRButtonTextFieldCell : NSTextFieldCell {

    open var alwaysShowButton = true
    internal var inButton = false
    internal var cellFrame = NSRect.zero
    open var buttonTarget : AnyObject?
    open var buttonAction : Selector?
    open var buttonPosition : AJRButtonTextFieldButtonPosition = .default

    internal var _image : NSImage?
    open override var image : NSImage! {
        get {
            return _image ?? NSImage(named: NSImage.followLinkFreestandingTemplateName)?.ajr_templateImage(with: .secondaryLabelColor)
        }
        set {
            _image = newValue
        }
    }

    internal var _alternateImage : NSImage?
    open var alternateImage : NSImage! {
        get {
            return _alternateImage ?? NSImage(named: NSImage.followLinkFreestandingTemplateName)?.ajr_templateImage(with: .selectedContentBackgroundColor)
        }
        set {
            _alternateImage = newValue
        }
    }

    internal var _highlightImage : NSImage?
    open var highlightImage : NSImage! {
        get {
            return _highlightImage ?? NSImage(named: NSImage.followLinkFreestandingTemplateName)?.ajr_templateImage(with: .white)
        }
        set {
            _highlightImage = newValue
        }
    }

    internal var workingAttributedStringValue: NSAttributedString {
        var string = attributedStringValue

        if string.string.isEmpty {
            string = placeholderAttributedString ?? NSAttributedString()
        }

        return string
    }

    open func textRect(forBounds cellFrame: NSRect, in controlView: NSView) -> NSRect {
        var textRect = titleRect(forBounds: cellFrame)
        let textSize = workingAttributedStringValue.size()

        textRect.size.width = textSize.width + 4.0

        return textRect
    }

    open func iconRect(forBounds cellFrame: NSRect, in controlView: NSView) -> NSRect {
        let image = self.image!
        let imageSize = image.size
        let textRect = self.textRect(forBounds: cellFrame, in: controlView)
        var imageRect = cellFrame
        var scale : CGFloat = 1.0

        if textRect.size.width == 0.0 {
            return .zero
        }

        if imageSize.height > cellFrame.size.height {
            scale = cellFrame.size.height / imageSize.height
        }
        if imageSize.width * scale > cellFrame.size.width {
            scale = cellFrame.size.width / (imageSize.width * scale)
        }

        if scale != 1.0 {
            imageRect.size.width = round(imageSize.width * scale)
            imageRect.size.height = round(imageSize.height * scale)
        } else {
            imageRect.size = imageSize
        }

        switch buttonPosition {
        case .default:
            if controlView is NSTableView {
                imageRect.origin.x = cellFrame.origin.x + cellFrame.size.width - imageRect.size.width
            } else {
                imageRect.origin.x += textRect.origin.x + textRect.size.width + 5.0
            }
        case .followsText:
            imageRect.origin.x += textRect.origin.x + textRect.size.width + 5.0
        case .trailing:
            if controlView is NSTableView {
                imageRect.origin.x = cellFrame.origin.x + cellFrame.size.width - imageRect.size.width
            } else {
                imageRect.origin.x = cellFrame.origin.x + cellFrame.size.width - (imageRect.size.width + 3.0)
            }
        }
        imageRect.origin.y = cellFrame.origin.y + (cellFrame.size.height - imageRect.size.height) / 2.0

        return imageRect
    }

    open override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        var buttonImage : NSImage? = nil

        if controlView is NSTableView && !alwaysShowButton {
            if isHighlighted {
                buttonImage = inButton ? image : highlightImage
            }
        } else {
            if isHighlighted && highlightImage != nil {
                buttonImage = highlightImage
            } else {
                buttonImage = inButton ? alternateImage : image
            }
        }

        super.draw(withFrame: cellFrame, in: controlView)

        if let buttonImage = buttonImage {
            let imageRect = iconRect(forBounds: cellFrame, in: controlView)
            buttonImage.draw(in: imageRect, from: NSRect(origin: .zero, size: buttonImage.size), operation: .sourceOver, fraction: 1.0, respectFlipped: true, hints: nil)
        }

        //		NSColor.red.set()
        //		textRect(forBounds: cellFrame, in: controlView).frame()
        //		NSColor.blue.set()
        //		iconRect(forBounds: cellFrame, in: controlView).frame()
        //		NSColor.green.set()
        //		titleRect(forBounds: cellFrame).frame()
    }

    private typealias TrackMouse = @convention(c) (_ receiver: Any, _ selector: Selector, _ event: NSEvent, _ cellFrame: NSRect, _ controlView: NSView, _ flag: Bool) -> Bool
    open override func trackMouse(with event: NSEvent, in cellFrame: NSRect, of controlView: NSView, untilMouseUp flag: Bool) -> Bool {
        let method = class_getInstanceMethod(NSActionCell.self, #selector(trackMouse(with:in:of:untilMouseUp:)))
        let original = unsafeBitCast(method_getImplementation(method!), to: TrackMouse.self)

        controlView.setNeedsDisplay(cellFrame)

        _ = original(self, #selector(trackMouse(with:in:of:untilMouseUp:)), event, cellFrame, controlView, flag)

        return true
    }

    open override func startTracking(at startPoint: NSPoint, in controlView: NSView) -> Bool {
        return true
    }

    internal func isPoint(_ point: NSPoint, inButtonInView controlView: NSView) -> Bool {
        return NSPointInRect(point, iconRect(forBounds: cellFrame, in: controlView))
    }

    open override func continueTracking(last lastPoint: NSPoint, current currentPoint: NSPoint, in controlView: NSView) -> Bool {
        let oldState = inButton

        //    AJRPrintf(@"%C: %.0f >= %.0f <= %.0f\n",
        //             self,
        //             _cellFrame.origin.x + _cellFrame.size.width - 15.0,
        //             currentPoint.x,
        //             _cellFrame.origin.x + _cellFrame.size.width);

        inButton = isPoint(currentPoint, inButtonInView: controlView)
        if (inButton && !oldState) || (!inButton && oldState) {
            controlView.setNeedsDisplay(cellFrame)
        }
        return true
    }

    internal func sendButtonAction(from controlView: NSView) {
        if let buttonAction = buttonAction {
            NSApp.sendAction(buttonAction, to: buttonTarget, from: controlView)
        }
    }

    open override func stopTracking(last lastPoint: NSPoint, current stopPoint: NSPoint, in controlView: NSView, mouseIsUp flag: Bool) {
        if isPoint(stopPoint, inButtonInView: controlView) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 1)) {
                self.sendButtonAction(from: controlView)
            }
        }
        inButton = false
        controlView.needsDisplay = true
    }

    open override func hitTest(for event: NSEvent, in cellFrame: NSRect, of controlView: NSView) -> NSCell.HitResult {
        let location = controlView.convert(event.locationInWindow, from: nil)

        if NSMouseInRect(location, iconRect(forBounds: cellFrame, in: controlView), controlView.isFlipped) {
            inButton = true
            self.cellFrame = cellFrame
            return .trackableArea
        }

        return super.hitTest(for: event, in: cellFrame, of: controlView)
    }

    open override class var prefersTrackingUntilMouseUp: Bool {
        return true
    }

    open override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! AJRButtonTextFieldCell

        copy.buttonTarget = buttonTarget
        copy.buttonAction = buttonAction
        copy.inButton = false
        copy.cellFrame = .zero
        copy.image = image
        copy.alternateImage = alternateImage
        copy.highlightImage = highlightImage

        return copy
    }

}
