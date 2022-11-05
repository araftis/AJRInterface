//
//  AJRPaperOrientationChooser.swift
//  AJRInterface
//
//  Created by AJ Raftis on 11/4/22.
//

import Cocoa

@objcMembers
open class AJRPaperOrientationChooser: NSControl {

    public enum PaperHighlight {
        case nothing
        case portrait
        case landscape
    }

    open var debug = false

    open var paperColor = AJRColor.white
    open var highlightColor = AJRColor(calibratedWhite: 0.9, alpha: 1.0)
    open var paper = AJRPaper(forPaperId: "na-letter")! {
        didSet {
            updateStringValue()
            needsDisplay = true
        }
    }
    open var orientation : NSPrintInfo.PaperOrientation = .portrait {
        didSet {
            needsDisplay = true
            updateStringValue()
        }
    }
    lazy open var textAttributes : [NSAttributedString.Key:Any] = {
        var style = NSMutableParagraphStyle()
        style.alignment = .center
        return [
            .font : NSFont.systemFont(ofSize: NSFont.systemFontSize(for: controlSize), weight: .light),
            .foregroundColor : NSColor.black,
            .paragraphStyle : style,
        ]
    }()
    lazy open var checkAttributes : [NSAttributedString.Key:Any] = {
        var style = NSMutableParagraphStyle()
        style.alignment = .right
        return [
            .font : NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .large), weight: .heavy),
            .foregroundColor : NSColor.black,
            .paragraphStyle : style,
        ]
    }()
    open var paperHighlight : PaperHighlight = .nothing {
        didSet {
            needsDisplay = true
        }
    }
    open var units : UnitLength = UnitLength.defaultShortUnitForLocale {
        didSet {
            updateStringValue()
        }
    }
    lazy open var unitFormatter : MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        return formatter
    }()

    internal class var defaultShadow : NSShadow {
        let shadow = NSShadow()
        shadow.shadowColor = NSColor(calibratedWhite: 0.0, alpha: 0.25)
        shadow.shadowBlurRadius = 1.0
        shadow.shadowOffset = NSSize(width: 0.0, height: -1.0)
        return shadow
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        shadow = Self.defaultShadow
        controlSize = .small
        updateStringValue()
    }

    // MARK: - NSCoding

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        if shadow == nil {
            shadow = Self.defaultShadow
        }
        controlSize = .small
        updateStringValue()
    }

    open override func encode(with coder: NSCoder) {
        super.encode(with: coder)
    }

    // MARK: - NSView

    internal func updateStringValue() {
        let width = Measurement(value: paper.size.width, unit: UnitLength.points).converted(to: units)
        let height = Measurement(value: paper.size.height, unit: UnitLength.points).converted(to: units)
        let widthString = unitFormatter.string(from: width)
        let heightString = unitFormatter.string(from: height)

        if orientation == .portrait {
            stringValue = "\(widthString) x \(heightString)"
        } else {
            stringValue = "\(heightString) x \(widthString)"
        }
    }

    internal func compute(portrait portraitRect: inout NSRect,
                          landscape landscapeRect: inout NSRect,
                          enclosing: inout NSRect,
                          text: inout NSRect) {
        portraitRect = NSRect(origin: .zero, size: paper.size)
        landscapeRect = NSRect(origin: .zero, size: paper.size)

        let bounds = self.bounds
        var paperBounds = bounds;

        paperBounds.size.height -= 20.0
        paperBounds.origin.y += 20.0
        portraitRect.center(in: paperBounds, method: .fitWidthAndHeight)
        landscapeRect.center(in: paperBounds, method: .fitWidthAndHeight)
        landscapeRect.size.swapWidthAndHeight()
        portraitRect.origin.x = 0
        landscapeRect.origin.x = portraitRect.maxX + 5.0

        portraitRect = portraitRect.insetBy(dx: 5.0, dy: 5.0)
        landscapeRect = landscapeRect.insetBy(dx: 5.0, dy: 5.0)

        enclosing = portraitRect.union(landscapeRect).byCentering(in: paperBounds, method: .noFittingOrScaling)
        // The - 5.0 offsets the inset above.
        portraitRect.origin.x += enclosing.origin.x - 5.0
        landscapeRect.origin.x += enclosing.origin.x - 5.0

        text.origin.x = bounds.origin.x
        text.size.width = bounds.size.width
        text.size.height = stringValue.size(withAttributes: textAttributes).height
        text.origin.y = enclosing.origin.y - text.size.height - 10.0

        portraitRect = portraitRect.integral
        landscapeRect = landscapeRect.integral
        enclosing = enclosing.integral
        text = text.integral
    }

    open override func draw(_ dirtyRect: NSRect) {
        var portraitRect = NSRect.zero
        var landscapeRect = NSRect.zero
        var enclosing = NSRect.zero
        var text = NSRect.zero

        compute(portrait: &portraitRect, landscape: &landscapeRect, enclosing: &enclosing, text: &text)

        AJRGetCurrentContext()?.drawWithSavedGraphicsState {
            shadow?.set()

            if paperHighlight == .portrait {
                (isEnabled ? highlightColor : NSColor.windowBackgroundColor).set()
            } else {
                (isEnabled ? paperColor : NSColor.windowBackgroundColor).set()
            }
            portraitRect.fill()

            if paperHighlight == .landscape {
                (isEnabled ? highlightColor : NSColor.windowBackgroundColor).set()
            } else {
                (isEnabled ? paperColor : NSColor.windowBackgroundColor).set()
            }
            landscapeRect.fill()
        }

        NSColor(calibratedWhite: 0.0, alpha: 0.15).set()
        NSBezierPath.defaultLineWidth = 0.5
        NSBezierPath.stroke(portraitRect.insetBy(dx: 0.25, dy: 0.25))
        NSBezierPath.stroke(landscapeRect.insetBy(dx: 0.25, dy: 0.25))
        NSBezierPath.defaultLineWidth = 1.0

        var checkRect = NSRect.zero
        if orientation == .portrait {
            checkRect = portraitRect
        } else if orientation == .landscape {
            checkRect = landscapeRect
        }
        let attributes = checkAttributes
        let string = "✓"
        checkRect = checkRect.insetBy(dx: 5.0, dy: 5.0)
        checkRect.size.height = string.size(withAttributes: attributes).height
        string.draw(in: checkRect, with: attributes)

        if debug {
            NSColor.red.set()
            portraitRect.frame()
            landscapeRect.frame()

            NSColor.purple.set()
            enclosing.frame()

            NSColor.blue.set()
            bounds.insetBy(dx: 0.5, dy: 0.5).frame()

            NSColor.green.set()
            text.frame()

            NSColor.cyan.set()
            checkRect.frame()
        }

        stringValue.draw(in: text, with: textAttributes)

        super.draw(dirtyRect)
    }

    internal func computeHighlight(from event: NSEvent) -> PaperHighlight {
        var text = NSRect.zero
        var portrait = NSRect.zero
        var landscape = NSRect.zero
        var enclosing = NSRect.zero

        compute(portrait: &portrait, landscape: &landscape, enclosing: &enclosing, text: &text)

        let location = event.ajr_location(in: self)

        if NSMouseInRect(location, portrait, false) {
            return .portrait
        }
        if NSMouseInRect(location, landscape, false) {
            return .landscape
        }

        return .nothing
    }

    open override func mouseDown(with event: NSEvent) {
        paperHighlight = computeHighlight(from: event)
    }

    open override func mouseDragged(with event: NSEvent) {
        paperHighlight = computeHighlight(from: event)
    }

    open override func mouseUp(with event: NSEvent) {
        paperHighlight = .nothing
        let inside = computeHighlight(from: event)
        var sendAction = false
        if inside == .portrait && orientation != .portrait {
            orientation = .portrait
            sendAction = true
        }
        if inside == .landscape && orientation != .landscape {
            orientation = .landscape
            sendAction = true
        }
        if sendAction, let action {
            NSApp.sendAction(action, to: target, from: self)
        }
    }
    
}
