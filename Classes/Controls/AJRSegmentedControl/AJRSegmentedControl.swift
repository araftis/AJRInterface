/*
 AJRSegmentedControl.swift
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
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
open class AJRSegmentedControl: NSSegmentedControl {
    
    // MARK: - Properties
    
    open var highlightedSegments = IndexSet()
    open var pressedSegments = IndexSet()
    open var popTimer : Timer? = nil
    open var mouseDownPoint : NSPoint? = nil

    // MARK: - Creation
    
    internal func completeInit() {
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        completeInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        completeInit()
    }
    
    // MARK: - Highlighting
    
    open func isHighlighted(forSegment segment: Int) -> Bool {
        return highlightedSegments.contains(segment)
    }
    
    open func setHighlighted(_ highlighted: Bool, forSegment segment: Int) -> Void {
        if highlightedSegments.contains(segment) != highlighted {
            if highlighted {
                highlightedSegments.insert(segment)
            } else {
                highlightedSegments.remove(segment)
            }
            if let cell = cell as? AJRSegmentedCell {
                setNeedsDisplay(cell.rect(forSegment: segment, inFrame: bounds))
            }
        }
    }
    
    open func isPressed(forSegment segment: Int) -> Bool {
        return pressedSegments.contains(segment)
    }
    
    open func setPressed(_ pressed: Bool, forSegment segment: Int) -> Void {
        if pressedSegments.contains(segment) != pressed {
            if pressed {
                pressedSegments.insert(segment)
            } else {
                pressedSegments.remove(segment)
            }
            if let cell = cell as? AJRSegmentedCell {
                setNeedsDisplay(cell.rect(forSegment: segment, inFrame: bounds))
            }
        }
    }
    
    // MARK: - NSView
    
    open override func updateTrackingAreas() -> Void {
        for area in trackingAreas {
            removeTrackingArea(area)
        }
        
        addTrackingArea(NSTrackingArea(rect: bounds, options: [.activeAlways, .mouseEnteredAndExited, .mouseMoved], owner: self, userInfo: nil))
    }

    internal func enumerateSegments(location: NSPoint, using block: (_ segment: Int, _ rect: NSRect, _ mouseInSegment: Bool) -> Void) {
        if let cell = cell as? AJRSegmentedCell {
            for segment in 0..<segmentCount {
                let rect = cell.rect(forSegment: segment, inFrame: bounds)
                block(segment, rect, NSMouseInRect(location, rect, isFlipped))
            }
        }
    }
    
    open override func mouseDown(with event: NSEvent) {
        mouseDownPoint = event.ajr_location(in: self)
        enumerateSegments(location: mouseDownPoint!) { (segment, cellFrame, mouseInSegment) in
            setPressed(mouseInSegment, forSegment: segment)
            setHighlighted(false, forSegment: segment)
            if mouseInSegment && menu(forSegment: segment) != nil {
                popTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: { (timer) in
                    if let menu = self.menu(forSegment: segment) {
                        var point = cellFrame.origin
                        point.y = cellFrame.size.height + 1.0
                        menu.popUp(positioning: menu.items.first, at: point, in: self)
                    }
                })
            }
        }
    }
    
    open override func mouseDragged(with event: NSEvent) {
        let currentPoint = event.ajr_location(in: self)

        if let popTimer = popTimer {
            if let mouseDownPoint = mouseDownPoint, AJRDistanceBetweenPoints(mouseDownPoint, currentPoint) > 1.0 {
                popTimer.invalidate()
                self.popTimer = nil
            }
        }
        enumerateSegments(location: currentPoint) { (segment, cellFrame, value) in
            setPressed(value, forSegment: segment)
            setHighlighted(false, forSegment: segment)
        }
    }
    
    open override func mouseMoved(with event: NSEvent) {
        enumerateSegments(location: event.ajr_location(in: self)) { (segment, cellFrame, value) in
            setHighlighted(value, forSegment: segment)
        }
    }
    
    open override func mouseExited(with event: NSEvent) {
        for segment in 0..<segmentCount {
            setHighlighted(false, forSegment: segment)
            setPressed(false, forSegment: segment)
        }
    }
    
    open override func mouseUp(with event: NSEvent) {
        if let popTimer = popTimer {
            popTimer.invalidate()
        }
        for segment in 0..<segmentCount {
            setPressed(false, forSegment: segment)
            setHighlighted(false, forSegment: segment)
        }
        enumerateSegments(location: event.ajr_location(in: self)) { (segment, cellFrame, mouseInSegment) in
            if mouseInSegment {
                self.setSelected(!self.isSelected(forSegment: segment), forSegment: segment)
                if let action = self.action {
                    NSApp.sendAction(action, to: self.target, from: self)
                }
            }
        }
    }
    
}
