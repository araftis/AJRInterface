/*
 AJRBookmarksBar.swift
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
import AJRInterfaceFoundation

@objc
public enum AJRBookmarkLayerState : Int {
    case normal
    case highlighted
    case pressed
}

@objcMembers
open class AJRBookmarkLayer : CALayer {
    
    // MARK: - Visual State
    
    open class var activeBackgroundColor : NSColor { return NSColor.clear }
    open class var highlightedBackgroundColor : NSColor { return NSColor(deviceWhite: 0.695, alpha: 1.0) }
    open class var activeForegroundColor : NSColor { return NSColor.black }
    open class var inactiveForegroundColor : NSColor { return NSColor(deviceWhite: 0.5, alpha: 1.0) }
    open class var highlightedForegroundColor : NSColor { return NSColor.white }
    open class var highlightedInactiveForegroundColor : NSColor { return NSColor(deviceWhite: 0.200, alpha: 1.0) }
    open class var highlightedInactiveBackgroundColor : NSColor { return NSColor(deviceWhite: 0.820, alpha: 1.0) }
    open class var pressedForegroundColor : NSColor { return NSColor.white }
    open class var pressedBackgroundColor : NSColor { return NSColor(deviceWhite: 0.439, alpha: 1.0)}

    open class var pullDownImage : NSImage {
        return AJRImages.imageNamed("AJRPullDown", forClass: self)!
    }
    public static var highlightedPullDownImage : NSImage = {
        return AJRImages.imageNamed("AJRPullDown", forClass: AJRBookmarkLayer.self)!.ajr_imageTinted(with: highlightedForegroundColor)
    }()
    public static var highlightedInactivePullDownImage : NSImage = {
        return AJRImages.imageNamed("AJRPullDown", forClass: AJRBookmarkLayer.self)!.ajr_imageTinted(with: highlightedInactiveForegroundColor)
    }()
    public static var inactivePullDownImage : NSImage = {
        return AJRImages.imageNamed("AJRPullDown", forClass: AJRBookmarkLayer.self)!.ajr_imageTinted(with: inactiveForegroundColor)
    }()

    // MARK: - Properties
    
    open var font : NSFont! {
        didSet {
            titleLayer.font = font
            titleLayer.fontSize = font.pointSize
            setNeedsLayout()
        }
    }
    
    internal var titleSize : NSSize = NSSize.zero
    
    open var bookmark : AJRBookmark? {
        didSet {
            if let bookmark = bookmark {
                titleSize = bookmark.title.size(withAttributes: [.font:font!])
                titleLayer.string = bookmark.title
            } else {
                titleSize = NSSize.zero
                titleLayer.string = ""
            }
            setNeedsLayout()
        }
    }
    
    open var titleLayer : CATextLayer!
    open var pullDownLayer : CALayer!
    
    open var hasPulldown : Bool {
        if let bookmark = bookmark {
            return bookmark.children.count > 0
        }
        return false
    }
    
    open var state : AJRBookmarkLayerState = .normal { didSet { updateDisplay() } }
    
    // MARK: - Creation

    internal func ajr_completeInit() {
        titleLayer = CATextLayer()
        titleLayer.foregroundColor = CGColor.black
        titleLayer.contentsScale = contentsScale
        
        pullDownLayer = CALayer()
        pullDownLayer.contents = Self.pullDownImage
        pullDownLayer.contentsScale = contentsScale
        font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small), weight: .medium)
        
        cornerRadius = 4.0
        
        addSublayer(titleLayer)
        addSublayer(pullDownLayer)
    }
    
    public override init() {
        super.init()
        ajr_completeInit()
    }
    
    public override init(layer: Any) {
        if let layer = layer as? AJRBookmarkLayer {
            self.titleLayer = CATextLayer(layer: layer.titleLayer!)
            self.pullDownLayer = CALayer(layer: layer.pullDownLayer!)
            self.state = layer.state
        }
        super.init(layer: layer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CALayer
    
    open override var contentsScale: CGFloat {
        didSet {
            titleLayer.contentsScale = contentsScale
            pullDownLayer.contentsScale = contentsScale
        }
    }
    
    open override func preferredFrameSize() -> CGSize {
        let padding : CGFloat = hasPulldown ? 10.0 : 8.0
        var size = CGSize(width: ceil(titleSize.width), height: 23.0)
        
        size.width += 2.0 * padding
        if hasPulldown {
            size.width += 4.0
            size.width += Self.pullDownImage.size.width
        }
        
        return size
    }
    
    open override func layoutSublayers() {
        var titleFrame = NSRect.zero
        titleFrame.origin.x = hasPulldown ? 10.0 : 8.0
        titleFrame.origin.y = (bounds.size.height - titleSize.height) / 2.0
        titleFrame.size.width = titleSize.width
        titleFrame.size.height = titleSize.height
        titleLayer.frame = titleFrame
        
        if hasPulldown {
            pullDownLayer.isHidden = false
            let image = Self.pullDownImage
            var pullDownFrame = NSRect.zero
            pullDownFrame.origin.x = 10.0 + titleSize.width + 4.0
            pullDownFrame.origin.y = (bounds.size.height - image.size.height) / 2.0
            pullDownFrame.size.width = image.size.width
            pullDownFrame.size.height = image.size.height
            pullDownLayer.frame = pullDownFrame
        } else {
            pullDownLayer.isHidden = true
        }
    }
    
    open func updateDisplay() -> Void {
        CATransaction.executeBlockWithoutAnimations {
            let active = NSApp.isActive && ((self.delegate as? NSView)?.window?.isKeyWindow ?? true)
            switch state {
            case .normal:
                titleLayer.foregroundColor = active ? type(of: self).activeForegroundColor.cgColor : type(of: self).inactiveForegroundColor.cgColor
                backgroundColor = type(of: self).activeBackgroundColor.cgColor
                pullDownLayer.contents = active ? type(of: self).pullDownImage : type(of: self).inactivePullDownImage
            case .highlighted:
                titleLayer.foregroundColor = active ? type(of: self).highlightedForegroundColor.cgColor : type(of: self).highlightedInactiveForegroundColor.cgColor
                backgroundColor = active ? type(of: self).highlightedBackgroundColor.cgColor : type(of: self).highlightedInactiveBackgroundColor.cgColor
                pullDownLayer.contents = active ? type(of: self).highlightedPullDownImage : type(of: self).highlightedInactivePullDownImage
            case .pressed:
                titleLayer.foregroundColor = type(of: self).pressedForegroundColor.cgColor
                backgroundColor = type(of: self).pressedBackgroundColor.cgColor
                pullDownLayer.contents = type(of: self).highlightedPullDownImage
            }
        }
    }
    
}

typealias AJRBookmarkBarInfo = (layer: AJRBookmarkLayer, trackingArea: NSTrackingArea?, bookmark: AJRBookmark)

@objcMembers
open class AJRBookmarksBar: NSView, NSMenuDelegate {

    // MARK: - Visual State
    
    public class var activeBorderColor : NSColor { return NSColor(deviceWhite: 0.715, alpha: 1.0) }
    public class var inactiveBorderColor : NSColor { return NSColor(deviceWhite: 0.875, alpha: 1.0) }
    public static var activeOverflowImage : NSImage = {
        return AJRImages.imageNamed("AJRBookmarksOverflow", forClass: AJRBookmarksBar.self)!.ajr_imageTinted(with: AJRBookmarkLayer.activeForegroundColor)
    }()
    public static var inactiveOverflowImage : NSImage = {
        return AJRImages.imageNamed("AJRBookmarksOverflow", forClass: AJRBookmarksBar.self)!.ajr_imageTinted(with: AJRBookmarkLayer.inactiveForegroundColor)
    }()

    internal static var buttonGap : CGFloat = 0.0
    internal static var overflowGap : CGFloat = 5.0

    // MARK: - Properties
    
    internal var buttons = [AJRBookmarkBarInfo]()
    internal var borderLayer : CALayer!
    internal var overflowLayer : CALayer!
    internal var overflowIndex : Int? = nil
    internal var overflowMenu : NSMenu? = nil
    
    public var bookmark : AJRBookmark? = nil { didSet { createLayers() } }
    public var font : NSFont!
    public var target : AnyObject? = nil
    public var action : Selector? = #selector(AJRGoToBookmarkProtocol.goToBookmark(_:))
    private var _selectedBookmark : AJRBookmark?
    public var selectedBookmark : AJRBookmark? { return _selectedBookmark }

    // MARK: - Creation
    
    internal func ajr_completeInit() -> Void {
        self.wantsLayer = true
        self.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        self.borderLayer = CALayer()
        self.borderLayer.backgroundColor = Self.inactiveBorderColor.cgColor
        self.overflowLayer = CALayer()
        self.overflowLayer.frame = NSRect(x: 0.0, y: 0.0, width: 13.0, height: 9.0)
        self.overflowLayer.contents = Self.inactiveOverflowImage
        
        self.layer?.addSublayer(borderLayer)
        self.layer?.addSublayer(overflowLayer)
        
        self.createLayers()
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.ajr_completeInit()
    }
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.ajr_completeInit()
    }
    
    // MARK: - Layout
    
    internal func bookmarkLayer(for bookmark: AJRBookmark) -> AJRBookmarkLayer {
        let bookmarkLayer = AJRBookmarkLayer()
        
        bookmarkLayer.bookmark = bookmark
        bookmarkLayer.frame = NSRect(x: 0.0, y: 4.0, width: bookmarkLayer.preferredFrameSize().width, height: bounds.size.height - 8.0)
        bookmarkLayer.contentsScale = 2.0

        return bookmarkLayer
    }
    
    @discardableResult
    internal func createButton(for bookmark: AJRBookmark) -> AJRBookmarkBarInfo {
        let button : AJRBookmarkBarInfo = (layer: bookmarkLayer(for: bookmark), trackingArea: nil, bookmark: bookmark)
        self.layer?.addSublayer(button.layer)
        buttons.append(button)
        return button
    }
    
    public func createLayers() -> Void {
        for button in buttons {
            button.layer.removeFromSuperlayer()
        }
        
        buttons.removeAll()
        
        if let bookmark = bookmark {
            for child in bookmark.children {
                createButton(for: child)
            }
        }
        
        if bookmark == nil || bookmark?.children.count == 0 {
            createButton(for: AJRBookmarkLeaf(title: "Import Safari Bookmarks...", url: URL(string: "app://import/safari")!))
        }
        
        needsLayout = true
    }
    
    public override func layout() {
        CATransaction.executeBlockWithoutAnimations {
            var x : CGFloat = 5.0
            let overflowSize = AJRBookmarksBar.activeOverflowImage.size
            
            overflowIndex = nil
            for index in 0 ..< buttons.count {
                var button = buttons[index]
                if overflowIndex != nil {
                    button.layer.isHidden = true
                } else {
                    let buttonLayer = button.layer
                    let preferredSize = NSSize(width: buttonLayer.preferredFrameSize().width, height: bounds.size.height - 8.0)
                    
                    if index == buttons.count - 1 {
                        // See if the final button will fit.
                        if x + preferredSize.width + AJRBookmarksBar.overflowGap > bounds.size.width - 5.0 {
                            // We're gunna overflow
                            overflowIndex = index
                            buttonLayer.isHidden = true
                        }
                    }
                    
                    if x + preferredSize.width + overflowSize.width + AJRBookmarksBar.overflowGap > bounds.size.width - 5.0 {
                        // The button + the room for the overflow button won't fit, so this button represents the first in the overflow
                        overflowIndex = index
                        buttonLayer.isHidden = true
                    }
                    
                    if overflowIndex == nil {
                        buttonLayer.isHidden = false
                        buttonLayer.frame = NSRect(x: x, y: 4.0, width: preferredSize.width, height: preferredSize.height)
                        buttonLayer.contentsScale = 2.0
                        x += buttonLayer.frame.size.width + AJRBookmarksBar.buttonGap
                        if let trackingArea = button.trackingArea {
                            removeTrackingArea(trackingArea)
                        }
                        button.trackingArea = NSTrackingArea(rect: buttonLayer.frame, options: [.activeAlways, .mouseEnteredAndExited], owner: self, userInfo: ["layer":button.layer])
                        addTrackingArea(button.trackingArea!)
                    }
                }
                buttons[index] = button
            }
            
            if globalTrackingArea != nil {
                self.removeTrackingArea(globalTrackingArea!)
                globalTrackingArea = nil
            }
            globalTrackingArea = NSTrackingArea(rect: bounds, options: [.activeAlways, .mouseEnteredAndExited, .mouseMoved], owner: self, userInfo:nil)
            self.addTrackingArea(globalTrackingArea!)
            
            if overflowIndex != nil {
                var rect = NSRect(x: 0.0, y: 0.0, width: overflowSize.width, height: overflowSize.height)
                rect.origin.x = bounds.maxX - (5.0 + rect.size.width)
                rect.origin.y = round((bounds.size.height - rect.size.height) / 2.0)
                overflowLayer.frame = rect
                overflowLayer.isHidden = false
                overflowMenu = nil // Make this rebuild
            } else {
                overflowLayer.isHidden = true
                overflowMenu = nil
            }
            
            var borderRect = NSRect.zero
            borderRect.origin.x = 0.0
            borderRect.origin.y = bounds.size.height - 1.0
            borderRect.size.width = bounds.size.width
            borderRect.size.height = 1.0
            borderLayer.frame = borderRect
        }
    }
    
    internal func rectForButton(at index: Int) -> NSRect {
        return buttons[index].layer.frame
    }
    
    public func button(for point: NSPoint) -> AJRBookmarkLayer? {
        for button in buttons {
            if NSMouseInRect(point, button.layer.frame, false) && !button.layer.isHidden {
                return button.layer
            }
        }
        return nil
    }
    
    public func buildOverflowMenu() -> NSMenu? {
        if overflowMenu == nil,
            let overflowIndex = overflowIndex {
            overflowMenu = NSMenu(title: "Overflow")
            for index in overflowIndex ..< buttons.count {
                if let menuItem = buttons[index].bookmark.menuItem() {
                    overflowMenu?.addItem(menuItem)
                }
            }
        }
        return overflowMenu
    }
    
    // MARK: - Responder
    
    private var mouseDidDrag = false
    private var mouseInButton : AJRBookmarkLayer? = nil
    private var lastMouseInButton : AJRBookmarkLayer? = nil
    private var poppedMenu : NSMenu? = nil
    private var suppressNextPop = false
    private var overflowWasPopped = false
    private var globalTrackingArea : NSTrackingArea? = nil
    
    public override func mouseEntered(with event: NSEvent) {
        if let trackingArea = event.trackingArea {
            if  let userInfo = trackingArea.userInfo,
                let layer = userInfo["layer"] as? AJRBookmarkLayer {
                for button in buttons {
                    if button.layer === layer {
                        layer.state = .highlighted
                    } else {
                        button.layer.state = .normal
                    }
                }
            } else {
                for button in buttons {
                    button.layer.state = .normal
                }
                overflowWasPopped = false
                suppressNextPop = false
            }
            // Always reset, because we re-entered the button bar.
            lastMouseInButton = nil
        }
    }
    
    public override func mouseExited(with event: NSEvent) {
        if let trackingArea = event.trackingArea {
            if let userInfo = trackingArea.userInfo,
                let layer = userInfo["layer"] as? AJRBookmarkLayer {
                layer.state = .normal
            } else {
                for button in buttons {
                    button.layer.state = .normal
                }
                overflowWasPopped = false
                suppressNextPop = false
            }
        }
    }
    
    public override func mouseMoved(with event: NSEvent) {
        let location = event.ajr_location(in: self)
        for button in buttons {
            if !NSMouseInRect(location, button.layer.frame, false) {
                if button.layer.state != .normal {
                    button.layer.state = .normal
                }
            }
        }
    }
    
    public override func mouseDown(with event: NSEvent) {
        mouseDidDrag = false
        mouseInButton = button(for: event.ajr_location(in: self))
        //print("mouseInButton: \(mouseInButton), lastMouseInButton: \(lastMouseInButton)")
        if mouseInButton === lastMouseInButton {
            lastMouseInButton = nil
            mouseInButton?.state = .highlighted // Since we're in the button, we're effectively moused in but that, but that may not be known, because we temporarily removed the tracking rects while the menu was popped.
            mouseInButton = nil
        }
        
        if mouseInButton == nil
            && !overflowLayer.isHidden
            && NSMouseInRect(event.ajr_location(in: self), overflowLayer.frame, false),
            let menu = buildOverflowMenu() {
            if !overflowWasPopped {
                var location = overflowLayer.frame.origin
                location.x += 3.0
                location.y -= 8.0
                menu.popUp(positioning: menu.items.first!, at: location, in: self)
                overflowWasPopped = true
            } else {
                overflowWasPopped = false
            }
        } else {
            overflowWasPopped = false
        }
    }
    
    public override func mouseDragged(with event: NSEvent) {
        mouseDidDrag = true
    }
    
    public override func mouseUp(with event: NSEvent) {
        if !mouseDidDrag, let mouseInButton = mouseInButton {
            if let bookmark = mouseInButton.bookmark {
                if bookmark.type == .leaf {
                    sendAction(using: bookmark)
                } else if bookmark.type == .list {
                    mouseInButton.state = .pressed
                    poppedMenu = mouseInButton.bookmark?.menu(target: self, action: #selector(forwardAction(_:)))
                    if let menu = poppedMenu {
                        var location = mouseInButton.frame.origin
                        location.x += 3.0
                        location.y -= 8.0
                        for trackingArea in trackingAreas {
                            if trackingArea.userInfo != nil {
                                removeTrackingArea(trackingArea)
                            }
                        }
                        menu.popUp(positioning: menu.items.first, at: location, in: self)
                        layout() // Force a re-creation of the tracking areas.
                        if let location = NSApp.currentEvent?.ajr_location(in: self),
                            let button = button(for: location),
                            button === mouseInButton {
                            mouseInButton.state = .highlighted
                            lastMouseInButton = nil
                        } else {
                            mouseInButton.state = .normal
                            lastMouseInButton = mouseInButton
                        }
                        poppedMenu = nil
                    }
                }
            }
        } else {
            lastMouseInButton = nil
        }
        mouseDidDrag = false
        mouseInButton = nil
    }

    // MARK: - Actions
    
    @IBAction internal func forwardAction(_ sender: Any?) -> Void {
        if let menuItem = sender as? NSMenuItem,
            let bookmark = menuItem.representedObject as? AJRBookmark {
            sendAction(using: bookmark)
        }
    }
    
    internal func sendAction(using bookmark: AJRBookmark) -> Void {
        if let action = action {
            _selectedBookmark = bookmark
            NSApp.sendAction(action, to: target, from: self)
            _selectedBookmark = nil
        }
    }
    
    // MARK: - Visual State
    
    public func updateDisplay() -> Void {
        CATransaction.executeBlockWithoutAnimations {
            let active = NSApp.isActive && (window?.isKeyWindow ?? true)
            for button in buttons {
                button.layer.updateDisplay()
            }
            borderLayer.backgroundColor = active ? type(of: self).activeBorderColor.cgColor : type(of: self).inactiveBorderColor.cgColor
            overflowLayer.contents = active ? type(of: self).activeOverflowImage : type(of: self).inactiveOverflowImage
        }
    }
    
    // MARK: - NSView
    
    public override func viewDidMoveToWindow() {
        NotificationCenter.default.removeObserver(self)
        weak var weakSelf = self
        NotificationCenter.default.addObserver(forName: NSWindow.didBecomeKeyNotification, object: window, queue: nil, using: { (notification) in
            if let strongSelf = weakSelf {
                strongSelf.updateDisplay()
            }
        })
        NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification, object: window, queue: nil, using: { (notification) in
            if let strongSelf = weakSelf {
                strongSelf.updateDisplay()
            }
        })
    }
    
}
