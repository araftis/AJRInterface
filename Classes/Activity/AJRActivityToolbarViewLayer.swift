/*
 AJRActivityToolbarViewLayer.m
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

import AJRInterfaceFoundation

open class AJRActivityToolbarViewLayer : CALayer {

    public static var defaultIdleMessage = ProcessInfo.processInfo.processName

    // MARK: - Text Attributes

    internal var messageAttributes : [NSAttributedString.Key:Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineBreakMode = .byTruncatingHead

        return [.font: NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize(for: .small), weight: .regular),
                .foregroundColor: NSApp.isActive ? NSColor.activityActiveText : NSColor.activityInactiveText,
                .paragraphStyle: style]
    }
    internal var bylineAttributes : [NSAttributedString.Key:Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineBreakMode = .byTruncatingHead

        return [.font: NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize(for: .mini),  weight: .bold),
                .foregroundColor: NSApp.isActive ? NSColor.activitySecondaryActiveText : NSColor.activitySecondaryInactiveText,
                .paragraphStyle: style]
    }

    // MARK: - Properties

    open var messageLayer: AJRTextLayer
    open var bylineLayer: AJRTextLayer
    open var progressLayer: AJRActivityToolbarProgressLayer

    public override init() {
        messageLayer = AJRTextLayer()
        progressLayer = AJRActivityToolbarProgressLayer()
        bylineLayer = AJRTextLayer()

        super.init()

        messageLayer.borderColor = NSColor.red.withAlphaComponent(0.2).cgColor
        //messageLayer.borderWidth = 1.0
        addSublayer(messageLayer)
        attributedMessage = attributedIdleMessage

        progressLayer.borderColor = NSColor.green.withAlphaComponent(0.2).cgColor
        //progressLayer.borderWidth = 1.0]
        addSublayer(progressLayer)

        bylineLayer.borderColor = NSColor.blue.withAlphaComponent(0.2).cgColor
        //bylineLayer.borderWidth = 1.0
        addSublayer(bylineLayer)
        bylineMessage = ""

        // Don't show the progress layer, initially.
        hideProgress()

        weak var weakSelf = self
        NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: nil) { notification in
            weakSelf?.setNeedsDisplay()
        }

        NotificationCenter.default.addObserver(forName: NSApplication.didResignActiveNotification, object: nil, queue: nil) { notification in
            weakSelf?.setNeedsDisplay()
        }
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Display

    open var idleMessage: String? {
        set {
            attributedIdleMessage = newValue == nil ? nil : NSAttributedString(string: newValue!, attributes: messageAttributes)
        }
        get {
            return attributedIdleMessage?.string
        }
    }

    internal var defaultAttributedIdleMessage : NSAttributedString {
        return NSAttributedString(string: Self.defaultIdleMessage, attributes: messageAttributes)
    }
    internal var _attributedIdleMessage: NSAttributedString?
    open var attributedIdleMessage: NSAttributedString? {
        set {
            if let value = newValue {
                _attributedIdleMessage = value
            } else {
                _attributedIdleMessage = defaultAttributedIdleMessage
            }
        }
        get {
            return _attributedIdleMessage ?? defaultAttributedIdleMessage
        }
    }

    open var message : String? {
        get {
            return attributedMessage?.string
        }
        set {
            if let newValue {
                attributedMessage = NSAttributedString(string: newValue, attributes: messageAttributes)
            } else {
                attributedMessage = nil
            }
        }
    }

    public var attributedMessage: NSAttributedString? {
        get {
            return messageLayer.attributedString
        }
        set {
            var attributedMessage : NSAttributedString

            if let message = newValue {
                attributedMessage = message
            } else {
                attributedMessage = attributedIdleMessage!
            }

            messageLayer.attributedString = attributedMessage
        }
    }

    public var bylineMessage : String? {
        get {
            return attributedBylineMessage?.string
        }
        set {
            var attributedMessage : NSAttributedString

            if let message = newValue {
                attributedMessage = NSAttributedString(string: message, attributes: bylineAttributes)
            } else {
                attributedMessage = NSAttributedString(string: "", attributes: bylineAttributes)
            }

            attributedBylineMessage = attributedMessage
        }
    }

    public var attributedBylineMessage : NSAttributedString? {
        get {
            return bylineLayer.attributedString;
        }
        set {
            bylineLayer.attributedString = newValue ?? NSAttributedString(string: "", attributes: bylineAttributes)
        }
    }

    open var progressMinimum: CGFloat {
        set {
            progressLayer.minimum = newValue
        }
        get {
            return progressLayer.minimum
        }
    }

    open var progressMaximum: CGFloat {
        set {
            progressLayer.maximum = newValue
        }
        get {
            return progressLayer.maximum
        }
    }

    open var progress: CGFloat {
        set {
            progressLayer.progress = newValue
        }
        get {
            return progressLayer.progress
        }
    }

    open var isIndeterminate: Bool {
        set {
            progressLayer.isIndeterminate = newValue
        }
        get {
            return progressLayer.isIndeterminate
        }
    }

    public func showProgress() {
        progressLayer.isHidden = false
        bylineLayer.isHidden = true
    }

    public func hideProgress() {
        progressLayer.isHidden = true
        bylineLayer.isHidden = false
    }

    open override var contentsScale: CGFloat {
        didSet {
            messageLayer.contentsScale = contentsScale
            bylineLayer.contentsScale = contentsScale
            DispatchQueue.main.async {
                self.progressLayer.contentsScale = self.contentsScale
            }
        }
    }

    // MARK: - Drawing

    public static var bottomHighlightShadow : NSShadow {
        let sharedShadow = NSShadow()
        sharedShadow.shadowColor = NSColor(deviceWhite: 1.0, alpha: 0.5)
        sharedShadow.shadowOffset = NSSize(width: 0.0, height: -1.0)
        sharedShadow.shadowBlurRadius = 0.0
        return sharedShadow
    }

    public static var innerGlowShadow : NSShadow {
        let sharedShadow = NSShadow()
        sharedShadow.shadowColor = NSColor(deviceRed: 159.0 / 255.0, green: 209 / 255.0, blue:255.0 / 255.0, alpha: 0.29)
        sharedShadow.shadowBlurRadius = 12.0
        sharedShadow.shadowOffset = .zero
        return sharedShadow
    }

    public static var outerBezelGradient : NSGradient {
        return NSGradient(colors: [NSColor(deviceWhite:  95.0 / 255.0, alpha: 1.0),
                                   NSColor(deviceWhite: 146.0 / 255.0, alpha: 1.0)])!
    }

    public static var innerBezelGradient : NSGradient {
        return NSGradient(colors: [NSColor(deviceRed: 188.0 / 255.0, green:195.0 / 255.0, blue:200.0 / 255.0, alpha:1.0),
                                   NSColor(deviceRed: 201.0 / 255.0, green:211.0 / 255.0, blue:217.0 / 255.0, alpha:1.0)])!
    }

    public static var backgroundGradient : NSGradient {
        return NSGradient(colorsAndLocations:
                            (NSColor(deviceWhite: 255.0 / 255.0, alpha: 1.0), 0.0),
                          (NSColor(deviceRed: 250.0 / 255.0, green: 253.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0), 0.0307),
                          (NSColor(deviceRed: 225.0 / 255.0, green: 233.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0), 0.5),
                          (NSColor(deviceRed: 216.0 / 255.0, green: 222.0 / 255.0, blue: 227.0 / 255.0, alpha: 1.0), 0.5),
                          (NSColor(deviceRed: 213.0 / 255.0, green: 218.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0), 1.0))!
    }

    open override func draw(in ctx: CGContext) {
        NSGraphicsContext.draw(in: ctx) {
            let appearance = (self.delegate as? NSView)?.effectiveAppearance ?? NSAppearance.currentDrawing()
            appearance.performAsCurrentDrawingAppearance {
                let borderImage = NSApp.isActive ? AJRImages.viewBorderImageFocused : AJRImages.viewBorderImageUnfocused
                borderImage.draw(in: self.bounds)
            }
        }
    }

    // MARK: - CALayer - Layout

    open override func layoutSublayers() {
        let bounds = self.bounds
        var messageRect = NSRect.zero
        var progressRect = NSRect.zero
        var bylineRect = NSRect.zero

        messageRect.origin.x = bounds.origin.x + 4.0
        messageRect.size.width = bounds.size.width - 8.0
        messageRect.size.height = 15.0
        messageRect.origin.y = bounds.origin.y + bounds.size.height - messageRect.size.height - 4.0
        messageLayer.frame = messageRect

        progressRect.origin.x = 0.0
        progressRect.size.width = bounds.size.width
        progressRect.size.height = 2.0
        progressRect.origin.y = bounds.origin.y + 1.0
        progressLayer.frame = progressRect

        bylineRect.origin.x = bounds.origin.x + 4.0
        bylineRect.size.width = bounds.size.width - 8.0
        bylineRect.size.height = 13.0
        bylineRect.origin.y = 5.0
        bylineLayer.frame = bylineRect
    }

}
