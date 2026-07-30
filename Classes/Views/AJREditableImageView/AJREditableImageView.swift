//
//  AJREditableImageView.swift
//  AJRInterface
//
//  Created by AJ Raftis on 7/26/26.
//

import Cocoa

import AJRFoundation

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
            window?.invalidateCursorRects(for: self)
            updateSelectionAnimation()
        }
    }

    open var hasSelection: Bool {
        return !selectionRect.isEmpty
    }

    private enum SelectionHandle: CaseIterable {
        case bottomLeft
        case bottom
        case bottomRight
        case right
        case topRight
        case top
        case topLeft
        case left

        var movesMinimumX: Bool {
            return self == .bottomLeft || self == .left || self == .topLeft
        }

        var movesMaximumX: Bool {
            return self == .bottomRight || self == .right || self == .topRight
        }

        var movesMinimumY: Bool {
            return self == .bottomLeft || self == .bottom || self == .bottomRight
        }

        var movesMaximumY: Bool {
            return self == .topLeft || self == .top || self == .topRight
        }
    }

    private static let selectionHandleDiameter: CGFloat = 8.0
    private static let selectionHandleHitDiameter: CGFloat = 14.0

    private var selectionAnchor: NSPoint?
    private var draggedSelectionHandle: SelectionHandle?
    private var selectionRectAtStartOfDrag: NSRect?
    private var selectionAnimationTimer: Timer?
    private var selectionDashPhase: CGFloat = 0.0

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        imageAdjustments = AJRImageAdjustments()
        observerToken = imageAdjustments?.addChangeObserver { [weak self] sender, key  in
            self?.imageAdjustmentsDidChange(sender, change: key)
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        imageAdjustments = coder.decodeObject(forKey: "imageAdjustments") as? AJRImageAdjustments
        if imageAdjustments == nil {
            imageAdjustments = AJRImageAdjustments()
        }
        observerToken = imageAdjustments?.addChangeObserver { [weak self] sender, key  in
            self?.imageAdjustmentsDidChange(sender, change: key)
        }
    }

    deinit {
        selectionAnimationTimer?.invalidate()
    }

    open func clearSelection() {
        selectionAnchor = nil
        draggedSelectionHandle = nil
        selectionRectAtStartOfDrag = nil
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
        undoManager?.registerUndo(withTarget: self) { targettedSelf in
            targettedSelf.flipVertical(nil)
        }
        undoManager?.setActionName(translator["Flip Vertical"])
        self.image = image.transform(using: image.flipVerticalTransform)
    }

    @IBAction
    open func flipHorizontal(_ sender: Any?) {
        guard let image else { return }
        undoManager?.registerUndo(withTarget: self) { targettedSelf in
            targettedSelf.flipHorizontal(nil)
        }
        undoManager?.setActionName(translator["Flip Horizontal"])
        self.image = image.transform(using: image.flipHorizontalTransform)
    }

    @IBAction
    open func rotateLeft(_ sender: Any?) {
        guard let image else { return }
        undoManager?.registerUndo(withTarget: self) { targettedSelf in
            targettedSelf.rotateRight(nil)
        }
        undoManager?.setActionName(translator["Rotate Left"])
        self.image = image.transform(using: image.rotateLeftTransform)
    }

    @IBAction
    open func rotateRight(_ sender: Any?) {
        guard let image else { return }
        undoManager?.registerUndo(withTarget: self) { targettedSelf in
            targettedSelf.rotateLeft(nil)
        }
        undoManager?.setActionName(translator["Rotate Right"])
        self.image = image.transform(using: image.rotateRightTransform)
    }

    private func restore(image: NSImage?, selectionRect: NSRect, actionName: String) {
        let currentImage = self.image
        let currentSelectionRect = self.selectionRect

        undoManager?.registerUndo(withTarget: self) { imageView in
            imageView.restore(image: currentImage, selectionRect: currentSelectionRect, actionName: actionName)
        }

        self.image = image
        select(selectionRect)
        undoManager?.setActionName(translator[actionName])
    }

    @IBAction
    open func crop(_ sender: Any?) {
        guard let image, hasSelection else { return }
        restore(image: image.cropped(to: selectionRect), selectionRect: .zero, actionName: translator["Crop"])
    }

    // MARK: - Mouse Tracking

    open override func mouseDown(with event: NSEvent) {
        let viewLocation = convert(event.locationInWindow, from: nil)
        if let handle = selectionHandle(at: viewLocation) {
            draggedSelectionHandle = handle
            selectionRectAtStartOfDrag = selectionRect
            selectionAnchor = nil
            return
        }

        guard let location = imageLocation(for: event) else {
            clearSelection()
            return
        }

        draggedSelectionHandle = nil
        selectionRectAtStartOfDrag = nil
        selectionAnchor = location
        selectionRect = NSRect(origin: location, size: .zero)
    }

    open override func mouseDragged(with event: NSEvent) {
        if let draggedSelectionHandle,
           let selectionRectAtStartOfDrag,
           let location = imageLocation(for: event, clamped: true) {
            resizeSelection(
                from: selectionRectAtStartOfDrag,
                using: draggedSelectionHandle,
                to: location
            )
            return
        }

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
        guard selectionAnchor != nil || draggedSelectionHandle != nil else {
            return
        }

        mouseDragged(with: event)
        selectionAnchor = nil
        draggedSelectionHandle = nil
        selectionRectAtStartOfDrag = nil

        if selectionRect.width <= 0.0 || selectionRect.height <= 0.0 {
            clearSelection()
        }
    }

    open override func resetCursorRects() {
        super.resetCursorRects()

        if let displayedImageRect {
            addCursorRect(displayedImageRect, cursor: .crosshair)
        }

        for handle in SelectionHandle.allCases {
            if let rect = selectionHandleRect(for: handle, diameter: Self.selectionHandleHitDiameter) {
                addCursorRect(rect, cursor: .openHand)
            }
        }
    }

    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        updateSelectionAnimation()
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
        darkBand.setLineDash([4.0, 4.0], count: 2, phase: selectionDashPhase)
        NSColor.black.setStroke()
        darkBand.stroke()

        for handle in SelectionHandle.allCases {
            guard let handleRect = selectionHandleRect(
                for: handle,
                diameter: Self.selectionHandleDiameter
            ) else {
                continue
            }

            let handlePath = NSBezierPath(ovalIn: handleRect)
            NSColor.controlAccentColor.setFill()
            NSColor.white.setStroke()
            handlePath.lineWidth = 1.0
            handlePath.fill()
            handlePath.stroke()
        }
    }

    // MARK: - Selection Animation

    private func updateSelectionAnimation() {
        let shouldAnimate = hasSelection && window != nil

        if shouldAnimate && selectionAnimationTimer == nil {
            let timer = Timer(timeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
                guard let self else {
                    return
                }

                self.selectionDashPhase = (self.selectionDashPhase + 0.5)
                    .truncatingRemainder(dividingBy: 8.0)
                self.needsDisplay = true
            }
            RunLoop.main.add(timer, forMode: .common)
            selectionAnimationTimer = timer
        } else if !shouldAnimate {
            selectionAnimationTimer?.invalidate()
            selectionAnimationTimer = nil
            selectionDashPhase = 0.0
        }
    }

    // MARK: - Selection Handles

    private func resizeSelection(from originalRect: NSRect, using handle: SelectionHandle, to location: NSPoint) {
        var minimumX = originalRect.minX
        var maximumX = originalRect.maxX
        var minimumY = originalRect.minY
        var maximumY = originalRect.maxY

        if handle.movesMinimumX {
            minimumX = location.x
        } else if handle.movesMaximumX {
            maximumX = location.x
        }

        let movesMinimumY = isFlipped ? handle.movesMaximumY : handle.movesMinimumY
        let movesMaximumY = isFlipped ? handle.movesMinimumY : handle.movesMaximumY

        if movesMinimumY {
            minimumY = location.y
        } else if movesMaximumY {
            maximumY = location.y
        }

        selectionRect = NSRect(
            x: min(minimumX, maximumX),
            y: min(minimumY, maximumY),
            width: abs(maximumX - minimumX),
            height: abs(maximumY - minimumY)
        )
    }

    private func selectionHandle(at location: NSPoint) -> SelectionHandle? {
        guard hasSelection else {
            return nil
        }

        for handle in SelectionHandle.allCases {
            if selectionHandleRect(
                for: handle,
                diameter: Self.selectionHandleHitDiameter
            )?.contains(location) == true {
                return handle
            }
        }

        return nil
    }

    private func selectionHandleRect(for handle: SelectionHandle, diameter: CGFloat) -> NSRect? {
        guard hasSelection, let selectionRect = viewRect(forImageRect: selectionRect) else { return nil }

        let center: NSPoint
        switch handle {
        case .bottomLeft:
            center = NSPoint(x: selectionRect.minX, y: selectionRect.minY)
        case .bottom:
            center = NSPoint(x: selectionRect.midX, y: selectionRect.minY)
        case .bottomRight:
            center = NSPoint(x: selectionRect.maxX, y: selectionRect.minY)
        case .right:
            center = NSPoint(x: selectionRect.maxX, y: selectionRect.midY)
        case .topRight:
            center = NSPoint(x: selectionRect.maxX, y: selectionRect.maxY)
        case .top:
            center = NSPoint(x: selectionRect.midX, y: selectionRect.maxY)
        case .topLeft:
            center = NSPoint(x: selectionRect.minX, y: selectionRect.maxY)
        case .left:
            center = NSPoint(x: selectionRect.minX, y: selectionRect.midY)
        }

        return NSRect(
            x: center.x - diameter / 2.0,
            y: center.y - diameter / 2.0,
            width: diameter,
            height: diameter
        )
    }

    // MARK: - Coordinate Conversion

    private var displayedImageRect: NSRect? {
        guard let image,
              image.size.width > 0.0,
              image.size.height > 0.0,
              bounds.width > 0.0,
              bounds.height > 0.0 else {
            return nil
        }

        let widthScale = bounds.width / image.size.width
        let heightScale = bounds.height / image.size.height
        let displayedSize: NSSize

        switch imageScaling {
        case .scaleAxesIndependently:
            displayedSize = bounds.size
        case .scaleProportionallyDown:
            let scale = min(1.0, min(widthScale, heightScale))
            displayedSize = NSSize(
                width: image.size.width * scale,
                height: image.size.height * scale
            )
        case .scaleProportionallyUpOrDown:
            let scale = min(widthScale, heightScale)
            displayedSize = NSSize(
                width: image.size.width * scale,
                height: image.size.height * scale
            )
        case .scaleNone:
            displayedSize = image.size
        @unknown default:
            displayedSize = image.size
        }

        let minimumX = bounds.minX
        let centeredX = bounds.midX - displayedSize.width / 2.0
        let maximumX = bounds.maxX - displayedSize.width
        let minimumY = bounds.minY
        let centeredY = bounds.midY - displayedSize.height / 2.0
        let maximumY = bounds.maxY - displayedSize.height
        let origin: NSPoint

        switch imageAlignment {
        case .alignCenter:
            origin = NSPoint(x: centeredX, y: centeredY)
        case .alignTop:
            origin = NSPoint(x: centeredX, y: isFlipped ? minimumY : maximumY)
        case .alignTopLeft:
            origin = NSPoint(x: minimumX, y: isFlipped ? minimumY : maximumY)
        case .alignTopRight:
            origin = NSPoint(x: maximumX, y: isFlipped ? minimumY : maximumY)
        case .alignLeft:
            origin = NSPoint(x: minimumX, y: centeredY)
        case .alignBottom:
            origin = NSPoint(x: centeredX, y: isFlipped ? maximumY : minimumY)
        case .alignBottomLeft:
            origin = NSPoint(x: minimumX, y: isFlipped ? maximumY : minimumY)
        case .alignBottomRight:
            origin = NSPoint(x: maximumX, y: isFlipped ? maximumY : minimumY)
        case .alignRight:
            origin = NSPoint(x: maximumX, y: centeredY)
        @unknown default:
            origin = NSPoint(x: centeredX, y: centeredY)
        }

        return NSRect(origin: origin, size: displayedSize)
    }

    private func imageLocation(for event: NSEvent, clamped: Bool = false) -> NSPoint? {
        guard let image, let displayedImageRect else { return nil }

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
        guard let image, let displayedImageRect else { return nil }

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

    // MARK: - Image Adjustments

    private var observerToken: AJRImageAdjustments.ObserverToken?

    @objc dynamic public var imageAdjustments : AJRImageAdjustments? {
        willSet {
            if let observerToken, let imageAdjustments {
                imageAdjustments.removeChangeObserver(observerToken)
                self.observerToken = nil
            }
        }
        didSet {
            if let imageAdjustments {
                observerToken = imageAdjustments.addChangeObserver { [weak self] sender, key  in
                    self?.imageAdjustmentsDidChange(sender, change: key)
                }
            }
        }
    }

    open func imageAdjustmentsDidChange(_ imageAdjustments: AJRImageAdjustments, change: AJRImageAdjustment) {
        print("change: \(change): \(imageAdjustments.value(forKey: change))")
    }

    // MARK: - Encoding

    open override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(imageAdjustments, forKey: "imageAdjustments")
    }

}
