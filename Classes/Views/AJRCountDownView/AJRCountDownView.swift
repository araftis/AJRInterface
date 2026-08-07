/*
 AJRCountDownView.swift
 AJRInterface

 Copyright © 2026, AJ Raftis and AJRInterface authors
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
import CoreText
import QuartzCore

private final class AJRCountDownLayer: CALayer {

    @NSManaged var sweepProgress: CGFloat
    @NSManaged var pulseScale: CGFloat

    var value: Int = 0
    var lineWidth: CGFloat = 3.0
    var circleColor: CGColor = NSColor.tertiaryLabelColor.cgColor
    var selectionColor: CGColor = NSColor.selectedContentBackgroundColor.cgColor
    var textColor: CGColor = NSColor.labelColor.cgColor

    override init() {
        super.init()
        sweepProgress = 0.0
        pulseScale = 1.0
        contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
        needsDisplayOnBoundsChange = true
    }

    override init(layer: Any) {
        if let layer = layer as? AJRCountDownLayer {
            value = layer.value
            lineWidth = layer.lineWidth
            circleColor = layer.circleColor
            selectionColor = layer.selectionColor
            textColor = layer.textColor
        }

        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sweepProgress = 0.0
        pulseScale = 1.0
        needsDisplayOnBoundsChange = true
    }

    override class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(sweepProgress) || key == #keyPath(pulseScale) {
            return true
        }

        return super.needsDisplay(forKey: key)
    }

    override func draw(in context: CGContext) {
        let sweepLineWidth = lineWidth * 1.3
        let diameter = max(min(bounds.width, bounds.height) - sweepLineWidth, 0.0)

        guard diameter > 0.0 else {
            return
        }

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = diameter / 2.0

        context.saveGState()
        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)
        context.setLineWidth(lineWidth * 1.3)
        context.setLineCap(.round)
        context.setStrokeColor(circleColor)
        context.addEllipse(in: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: diameter,
            height: diameter
        ))
        context.strokePath()
        context.restoreGState()

        drawSweep(in: context, center: center, radius: radius)
        drawValue(in: context, center: center, diameter: diameter)
    }

    private func drawSweep(in context: CGContext, center: CGPoint, radius: CGFloat) {
        let progress = min(max(sweepProgress, 0.0), 1.0)

        guard progress > 0.0 else {
            return
        }

        let segmentCount = max(Int(ceil(120.0 * progress)), 1)
        let startAngle = CGFloat.pi / 2.0

        guard let baseColor = NSColor(cgColor: selectionColor)?.usingColorSpace(.deviceRGB) else {
            return
        }

        context.saveGState()
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)

        for segment in 0..<segmentCount {
            let startFraction = CGFloat(segment) / CGFloat(segmentCount)
            let endFraction = CGFloat(segment + 1) / CGFloat(segmentCount)
            let segmentStart = startAngle - (2.0 * CGFloat.pi * progress * startFraction)
            let segmentEnd = startAngle - (2.0 * CGFloat.pi * progress * endFraction)
            let alpha = baseColor.alphaComponent * endFraction

            context.setStrokeColor(baseColor.withAlphaComponent(alpha).cgColor)
            context.beginPath()
            context.addArc(
                center: center,
                radius: radius,
                startAngle: segmentStart,
                endAngle: segmentEnd,
                clockwise: true
            )
            context.strokePath()
        }

        context.restoreGState()
    }

    private func drawValue(in context: CGContext, center: CGPoint, diameter: CGFloat) {
        let fontSize = max(diameter * 0.75, 1.0)
        let systemFont = NSFont.boldSystemFont(ofSize: fontSize)
        let font = CTFontCreateWithName(systemFont.fontName as CFString, fontSize, nil)
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(kCTFontAttributeName as String): font,
            NSAttributedString.Key(kCTForegroundColorAttributeName as String): textColor,
        ]
        let string = NSAttributedString(string: String(value), attributes: attributes)
        let line = CTLineCreateWithAttributedString(string)
        let glyphBounds = CTLineGetBoundsWithOptions(line, [.useGlyphPathBounds])
        let scale = max(pulseScale, 0.0)

        context.saveGState()
        context.translateBy(x: center.x, y: center.y)
        context.scaleBy(x: scale, y: scale)
        context.textMatrix = .identity
        context.textPosition = CGPoint(x: -glyphBounds.midX, y: -glyphBounds.midY)
        CTLineDraw(line, context)
        context.restoreGState()
    }

}

/**
 A circular count-down indicator whose value pulses while a fading clock-like
 sweep travels clockwise from twelve o'clock back to twelve o'clock.
 */
@objcMembers
open class AJRCountDownView: NSControl {

    private weak var observedRowView: NSTableRowView?
    private var rowSelectionObservation: NSKeyValueObservation?
    private var rowEmphasisObservation: NSKeyValueObservation?

    @IBInspectable
    dynamic open var value: Int = 0 {
        didSet {
            guard value != oldValue else {
                return
            }

            synchronizeLayer()
            animateValueChange()
        }
    }

    @IBInspectable
    open var pulseGrowthDuration: Double = 0.25

    @IBInspectable
    open var pulseSettlingDuration: Double = 0.25

    @IBInspectable
    open var sweepAnimationDuration: Double = 1.0

    @IBInspectable
    open var lineWidth: CGFloat = 3.0 {
        didSet {
            synchronizeLayer()
        }
    }

    @IBInspectable
    open override var isEnabled: Bool {
        didSet {
            synchronizeLayer()
        }
    }

    open override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    open override var intrinsicContentSize: NSSize {
        return NSSize(width: 24.0, height: 24.0)
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
        isEnabled = true
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        isEnabled = true
    }

    private func commonInit() {
        wantsLayer = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
        synchronizeLayer()
    }

    open override func makeBackingLayer() -> CALayer {
        return AJRCountDownLayer()
    }

    open override func layout() {
        super.layout()
        updateRowViewObservation()
        countDownLayer?.setNeedsDisplay()
    }

    open override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        synchronizeLayer()
    }

    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        updateRowViewObservation()
    }

    private var countDownLayer: AJRCountDownLayer? {
        return layer as? AJRCountDownLayer
    }

    private var enclosingRowView: NSTableRowView? {
        var candidate = superview

        while let view = candidate {
            if let rowView = view as? NSTableRowView {
                return rowView
            }
            candidate = view.superview
        }

        return nil
    }

    private func updateRowViewObservation() {
        let rowView = enclosingRowView

        guard observedRowView !== rowView else {
            return
        }

        rowSelectionObservation = nil
        rowEmphasisObservation = nil
        observedRowView = rowView

        rowSelectionObservation = rowView?.observe(\.isSelected, options: [.initial, .new]) {
            [weak self] _, _ in
            self?.synchronizeLayer()
        }
        rowEmphasisObservation = rowView?.observe(\.isEmphasized, options: [.initial, .new]) {
            [weak self] _, _ in
            self?.synchronizeLayer()
        }
    }

    private func synchronizeLayer() {
        guard let countDownLayer else {
            return
        }

        countDownLayer.value = value
        countDownLayer.lineWidth = lineWidth
        let usesEmphasizedSelectionColors = observedRowView?.isSelected == true && observedRowView?.isEmphasized == true
        let circleColor: NSColor = isEnabled ? .tertiaryLabelColor : .disabledControlTextColor
        let selectionColor = NSColor.selectedContentBackgroundColor
        let textColor: NSColor = isEnabled ? .labelColor : .disabledControlTextColor

        countDownLayer.circleColor = resolvedCGColor(
            foregroundColor(circleColor, forEmphasizedSelection: usesEmphasizedSelectionColors)
        )
        countDownLayer.selectionColor = resolvedCGColor(
            foregroundColor(selectionColor, forEmphasizedSelection: usesEmphasizedSelectionColors)
        )
        countDownLayer.textColor = resolvedCGColor(
            foregroundColor(textColor, forEmphasizedSelection: usesEmphasizedSelectionColors)
        )
        countDownLayer.contentsScale = window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2.0
        countDownLayer.setNeedsDisplay()
    }

    private func resolvedCGColor(_ color: NSColor) -> CGColor {
        return color.usingColorSpace(.deviceRGB)?.cgColor ?? color.cgColor
    }

    private func foregroundColor(_ color: NSColor, forEmphasizedSelection emphasized: Bool) -> NSColor {
        if !emphasized {
            return color
        }

        let resolvedColor = color.usingColorSpace(.deviceRGB) ?? color
        return NSColor.white.withAlphaComponent(resolvedColor.alphaComponent)
    }

    private func animateValueChange() {
        guard let countDownLayer else {
            return
        }

        let growthDuration = max(pulseGrowthDuration, 0.0)
        let settlingDuration = max(pulseSettlingDuration, 0.0)
        let pulseDuration = growthDuration + settlingDuration
        let sweepDuration = max(sweepAnimationDuration, 0.0)

        if pulseDuration > 0.0 {
            let pulseAnimation = CAKeyframeAnimation(keyPath: #keyPath(AJRCountDownLayer.pulseScale))
            pulseAnimation.values = [0.01, 1.25, 1.0]
            pulseAnimation.keyTimes = [
                0.0,
                NSNumber(value: growthDuration / pulseDuration),
                1.0,
            ]
            pulseAnimation.duration = pulseDuration
            pulseAnimation.timingFunctions = [
                CAMediaTimingFunction(name: .easeOut),
                CAMediaTimingFunction(name: .easeInEaseOut),
            ]
            countDownLayer.add(pulseAnimation, forKey: "AJRCountDownView.pulse")
        }

        if sweepDuration > 0.0 {
            let sweepAnimation = CABasicAnimation(keyPath: #keyPath(AJRCountDownLayer.sweepProgress))
            sweepAnimation.fromValue = 0.0
            sweepAnimation.toValue = 1.0
            sweepAnimation.duration = sweepDuration
            sweepAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
            countDownLayer.add(sweepAnimation, forKey: "AJRCountDownView.sweep")
        }
    }

}
