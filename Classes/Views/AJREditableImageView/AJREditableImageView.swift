//
//  AJREditableImageView.swift
//  AJRInterface
//
//  Created by AJ Raftis on 7/26/26.
//

import Cocoa

@objcMembers
open class AJREditableImageView: NSImageView {

    // MARK: - Image

    open override var image: NSImage? {
        didSet {
            if image !== oldValue {
                clearSelection()
            }
        }
    }

    // MARK: - Selection

    @objc dynamic
    public private(set) var selectionRect: NSRect = .zero {
        didSet {
            needsDisplay = true
        }
    }

    open var hasSelection: Bool {
        return !selectionRect.isEmpty
    }

    private var selectionAnchor: NSPoint?

    open func clearSelection() {
        selectionAnchor = nil
        selectionRect = .zero
    }

    open func select(_ rect: NSRect) {
        guard let image else {
            clearSelection()
            return
        }

        let imageBounds = NSRect(origin: .zero, size: image.size)
        selectionRect = rect.standardized.intersection(imageBounds)
    }

    // MARK: - Actions

    @IBAction
    open func flipVertical(_ sender: Any?) {
        guard let image else { return }
        self.image = image.transform(using: image.flipVerticalTransform)
    }

    @IBAction
    open func flipHorizontal(_ sender: Any?) {
        guard let image else { return }
        self.image = image.transform(using: image.flipHorizontalTransform)
    }

    @IBAction
    open func rotateLeft(_ sender: Any?) {
        guard let image else { return }
        self.image = image.transform(using: image.rotateLeftTransform)
    }

    @IBAction
    open func rotateRight(_ sender: Any?) {
        guard let image else { return }
        self.image = image.transform(using: image.rotateRightTransform)
    }

    @IBAction
    open func crop(_ sender: Any?) {
        guard let image, hasSelection else {
            return
        }

        self.image = image.cropped(to: selectionRect)
    }

    // MARK: - Mouse Tracking

    open override func mouseDown(with event: NSEvent) {
        guard let location = imageLocation(for: event) else {
            clearSelection()
            return
        }

        selectionAnchor = location
        selectionRect = NSRect(origin: location, size: .zero)
    }

    open override func mouseDragged(with event: NSEvent) {
        guard let selectionAnchor,
              let location = imageLocation(for: event, clamped: true) else {
            return
        }

        selectionRect = NSRect(
            x: min(selectionAnchor.x, location.x),
            y: min(selectionAnchor.y, location.y),
            width: abs(location.x - selectionAnchor.x),
            height: abs(location.y - selectionAnchor.y)
        )
    }

    open override func mouseUp(with event: NSEvent) {
        guard selectionAnchor != nil else {
            return
        }

        mouseDragged(with: event)
        selectionAnchor = nil

        if selectionRect.width <= 0.0 || selectionRect.height <= 0.0 {
            clearSelection()
        }
    }

    open override func resetCursorRects() {
        super.resetCursorRects()

        if let displayedImageRect {
            addCursorRect(displayedImageRect, cursor: .crosshair)
        }
    }

    // MARK: - Drawing

    open override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard hasSelection,
              let selectionRect = viewRect(forImageRect: selectionRect) else {
            return
        }

        NSGraphicsContext.saveGraphicsState()
        defer {
            NSGraphicsContext.restoreGraphicsState()
        }

        let bandRect = selectionRect.insetBy(dx: 0.5, dy: 0.5)
        let lightBand = NSBezierPath(rect: bandRect)
        lightBand.lineWidth = 1.0
        NSColor.white.setStroke()
        lightBand.stroke()

        let darkBand = NSBezierPath(rect: bandRect)
        darkBand.lineWidth = 1.0
        darkBand.setLineDash([4.0, 4.0], count: 2, phase: 0.0)
        NSColor.black.setStroke()
        darkBand.stroke()
    }

    // MARK: - Coordinate Conversion

    private var displayedImageRect: NSRect? {
        guard image != nil,
              let imageCell = cell as? NSImageCell else {
            return nil
        }

        let rect = imageCell.imageRect(forBounds: bounds)
        return rect.isEmpty ? nil : rect
    }

    private func imageLocation(
        for event: NSEvent,
        clamped: Bool = false
    ) -> NSPoint? {
        guard let image,
              let displayedImageRect else {
            return nil
        }

        var location = convert(event.locationInWindow, from: nil)
        if clamped {
            location.x = min(max(location.x, displayedImageRect.minX), displayedImageRect.maxX)
            location.y = min(max(location.y, displayedImageRect.minY), displayedImageRect.maxY)
        } else if !displayedImageRect.contains(location) {
            return nil
        }

        let xFraction = (location.x - displayedImageRect.minX) / displayedImageRect.width
        let viewYFraction = (location.y - displayedImageRect.minY) / displayedImageRect.height
        let yFraction = isFlipped ? 1.0 - viewYFraction : viewYFraction

        return NSPoint(
            x: xFraction * image.size.width,
            y: yFraction * image.size.height
        )
    }

    private func viewRect(forImageRect imageRect: NSRect) -> NSRect? {
        guard let image,
              let displayedImageRect else {
            return nil
        }

        let xScale = displayedImageRect.width / image.size.width
        let yScale = displayedImageRect.height / image.size.height
        let viewY: CGFloat

        if isFlipped {
            viewY = displayedImageRect.maxY - imageRect.maxY * yScale
        } else {
            viewY = displayedImageRect.minY + imageRect.minY * yScale
        }

        return NSRect(
            x: displayedImageRect.minX + imageRect.minX * xScale,
            y: viewY,
            width: imageRect.width * xScale,
            height: imageRect.height * yScale
        )
    }

}
