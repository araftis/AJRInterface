/*
 AJRStarsCell.swift
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

import AJRFoundation
import AppKit

open class AJRStarsCell : NSLevelIndicatorCell {

    // MARK: - Properties
    
    internal var tracking : Bool = false
    internal var trackingRect = NSRect.zero
    
    open var backgroundColor : NSColor?
    open var borderColor : NSColor?
    
    // MARK: - Geometry

    open func radius(forFrame cellFrame: NSRect) -> CGFloat {
        return rint(cellFrame.size.height * 0.5)
    }

    open func rect(forFrame cellFrame: NSRect) -> NSRect {
        let radius = self.radius(forFrame: cellFrame)
        
        var newFrame = cellFrame
        newFrame.size.width = (CGFloat(self.maxValue) * ((radius * 2.0) + 2.0)) + 7.0
        
        return newFrame
    }
    
    open func value(forPoint point: NSPoint) -> CGFloat {
        let radius = self.radius(forFrame: trackingRect)
        let percent = AJRClamp((point.x - 4.0) / (trackingRect.size.width - radius * 2.0), min: 0.0, max: 1.0)
        return rint((CGFloat(self.maxValue) * percent * 2.0)) / 2.0
    }

    // MARK: - NSCell / NSLevelIndicatorCell

    open override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        if let controlView = controlView as? NSLevelIndicator, levelIndicatorStyle == .rating {
            var drawFrame = cellFrame
            let whole = integerValue
            let half = Int(floatValue * 2.0) % 2 == 1
            let path = NSBezierPath()
            var center = NSPoint.zero
            var radius: CGFloat
            var radius2: CGFloat
            let max = maxValue
            var halfPoint: NSPoint
            
            self.controlView = controlView
            
            drawFrame = self.rect(forFrame: cellFrame)
            
            if isEnabled {
                if let backgroundColor = self.backgroundColor {
                    backgroundColor.set()
                    drawFrame.fill()
                }
                if let borderColor = self.borderColor {
                    borderColor.set()
                    drawFrame.frame()
                }
            }
            
            radius = self.radius(forFrame: drawFrame)
            radius2 = radius * 0.4
            center.x = drawFrame.origin.x + radius + 4.5
            center.y = NSMidY(drawFrame)
            halfPoint = center
            halfPoint.x -= ((radius * 2.0) + 2.0)
            for x in 0 ..< Int(max) {
                for degree : CGFloat in stride(from: 90.0, to: 450.0, by: 360.0 / 5.0) {
                    var point = NSPoint.zero
                    
                    if x < whole {
                        point.x = cos(degree * (CGFloat.pi / 180.0)) * radius + center.x
                        point.y = sin(degree * (CGFloat.pi / 180.0)) * radius + center.y
                        if degree == 90.0 {
                            path.move(to: point)
                        } else {
                            path.line(to: point)
                        }
                        point.x = cos((degree + 36.0) * (CGFloat.pi / 180.0)) * radius2 + center.x
                        point.y = sin((degree + 36.0) * (CGFloat.pi / 180.0)) * radius2 + center.y
                        path.line(to: point)
                        halfPoint = center
                    } else if tracking {
                        if !half || (half && x > whole) {
                            path.move(to: NSPoint(x: center.x + 1.5, y: center.y))
                            path.appendArc(withCenter: center, radius: 1.5, startAngle: 0.0, endAngle: 360.0)
                        }
                    }
                }
                path.close()
                center.x += ((radius * 2.0) + 2.0)
            }
            if half {
                path.move(to: NSPoint(x: halfPoint.x + radius + 2.0, y: halfPoint.y - (radius * 0.75)))
                path.appendString("½", font: NSFont.boldSystemFont(ofSize: radius * 2.0))
            }
            if path.elementCount > 0 {
                controlView.fillColor.set()
                path.fill()
            }
        } else {
            super.draw(withFrame: cellFrame, in: controlView)
        }
    }

    open override func trackMouse(with event: NSEvent, in cellFrame: NSRect, of controlView: NSView, untilMouseUp flag: Bool) -> Bool {
        trackingRect = rect(forFrame: cellFrame)
        trackingRect.origin.x += 4.0
        trackingRect.size.width -= 8.0
        return super.trackMouse(with: event, in: cellFrame, of: controlView, untilMouseUp: flag)
    }

    open override func startTracking(at startPoint: NSPoint, in controlView: NSView) -> Bool {
        if levelIndicatorStyle == .rating {
            doubleValue = Double(value(forPoint: startPoint))
            return true
        }
        return super.startTracking(at: startPoint, in: controlView)
    }

    open override func continueTracking(last lastPoint: NSPoint, current currentPoint: NSPoint, in controlView: NSView) -> Bool {
        tracking = true
        if levelIndicatorStyle == .rating {
            doubleValue = Double(value(forPoint: currentPoint))
            return true
        }
        return super.continueTracking(last: lastPoint, current: currentPoint, in: controlView)
    }

    open override func stopTracking(last lastPoint: NSPoint, current stopPoint: NSPoint, in controlView: NSView, mouseIsUp flag: Bool) -> Void {
        tracking = false
        if levelIndicatorStyle == .rating {
            doubleValue = Double(value(forPoint: stopPoint))
            if let action = self.action {
                NSApp.sendAction(action, to: self.target, from: controlView)
            }
        } else {
            super.stopTracking(last: lastPoint, current:stopPoint, in: controlView, mouseIsUp: flag)
        }
    }

    // MARK: - NSCoding

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = coder.decodeObject(forKey: "backgroundColor")
        borderColor = coder.decodeObject(forKey: "borderColor")
    }
    
    open override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(backgroundColor, forKey: "backgroundColor")
        coder.encode(borderColor, forKey: "borderColor")
    }

}
