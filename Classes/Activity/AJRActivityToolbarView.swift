/*
 AJRActivityToolbarView.m
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

public extension NSColor.Name {
    static var activityActiveText = NSColor.Name("AJRActivityActiveTextColor")
    static var activityInactiveText = NSColor.Name("AJRActivityInactiveTextColor")
    static var activitySecondaryActiveText = NSColor.Name("AJRActivitySecondaryActiveTextColor")
    static var activitySecondaryInactiveText = NSColor.Name("AJRActivitySecondaryInactiveTextColor")
}

public extension NSColor {
    static var activityActiveText = NSColor(named: .activityActiveText, bundle: AJRInterfaceBundle())!
    static var activityInactiveText = NSColor(named: .activityInactiveText, bundle: AJRInterfaceBundle())!
    static var activitySecondaryActiveText = NSColor(named: .activitySecondaryActiveText, bundle: AJRInterfaceBundle())!
    static var activitySecondaryInactiveText = NSColor(named: .activitySecondaryInactiveText, bundle: AJRInterfaceBundle())!
}

@objcMembers
open class AJRActivityToolbarView : NSView, CALayerDelegate {

    // MARK: - Properties

    open var currentActivity : AJRActivity? = nil {
        willSet {
            if let currentActivity {
                currentActivity.removeObserver(self, forKeyPath: "message")
                currentActivity.removeObserver(self, forKeyPath: "progress")
                currentActivity.removeObserver(self, forKeyPath: "progressMin")
                currentActivity.removeObserver(self, forKeyPath: "progressMax")
                currentActivity.removeObserver(self, forKeyPath: "indeterminate")
            }
        }
        didSet {
            if let currentActivity {
                currentActivity.addObserver(self, forKeyPath: "message", options: [.initial], context: nil)
                currentActivity.addObserver(self, forKeyPath: "progress", options: [.initial], context: nil)
                currentActivity.addObserver(self, forKeyPath: "progressMin", options: [.initial], context: nil)
                currentActivity.addObserver(self, forKeyPath: "progressMax", options: [.initial], context: nil)
                currentActivity.addObserver(self, forKeyPath: "indeterminate", options: [.initial], context: nil)
            }
            configureForCurrentActivity()
        }
    }
    open var activityIdentifier : AJRActivityIdentifier?

    open var idleMessage : String? {
        set {
            assert(Thread.isMainThread, "Must run on main thread.")
            activityLayer.idleMessage = newValue
        }
        get {
            return activityLayer.idleMessage
        }
    }

    open var attributedIdleMessage : NSAttributedString? {
        set {
            assert(Thread.isMainThread, "Must run on main thread.")
            activityLayer.attributedIdleMessage = newValue
        }
        get {
            return activityLayer.attributedIdleMessage
        }
    }

    open var bylineMessage : String? {
        set {
            assert(Thread.isMainThread, "Must run on main thread.")
            activityLayer.bylineMessage = newValue
        }
        get {
            return activityLayer.bylineMessage
        }
    }

    open var attributedBylineMessage : NSAttributedString? {
        set {
            assert(Thread.isMainThread, "Must run on main thread.")
            activityLayer.attributedBylineMessage = newValue
        }
        get {
            return activityLayer.attributedBylineMessage
        }
    }

    // MARK: - Creation

    internal func ajr_commonInit() {
        wantsLayer = true

        weak var weakSelf = self
        AJRActivity.addObserver { action, activity, activities in
            let isDisplayed = activity.identifier == nil || AJRAnyEquals(activity.identifier, weakSelf?.activityIdentifier)

            if isDisplayed {
                if action == .added {
                    weakSelf?.currentActivity = activity
                } else if action == .removed {
                    weakSelf?.currentActivity = nil
                }
            }
        }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        ajr_commonInit()
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        ajr_commonInit()
    }

    // MARK: - Display

    open func configureForCurrentActivity() {
        assert(Thread.isMainThread, "Must run on main thread.")
        let layer = activityLayer

        if let currentActivity {
            layer.showProgress()
            layer.message = currentActivity.message
            layer.progressMinimum = currentActivity.progressMin
            layer.progressMaximum = currentActivity.progressMax
            layer.progress = currentActivity.progress
            layer.isIndeterminate = currentActivity.isIndeterminate
        } else {
            layer.hideProgress()
            layer.message = nil
            layer.progressMinimum = 0
            layer.progressMaximum = 0
            layer.progress = 0
            layer.isIndeterminate = true
        }
        configureDisplayScale()
    }

    open func configureDisplayScale() {
        var displayScale : CGFloat = 2.0 // Assume 2.0, because that's becoming the most common.

        if let window, let screen = window.screen {
            displayScale = screen.backingScaleFactor
        }

        activityLayer.contentsScale = displayScale
    }

    // MARK: - Retype

    open var activityLayer : AJRActivityToolbarViewLayer {
        if let layer = layer as? AJRActivityToolbarViewLayer {
            return layer
        }
        preconditionFailure("The layer property of a AJRActivityToolbarView must be an AJRActivityToolbarViewLayer.")
    }

    // MARK: - NSKeyValueObserving

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let object = object as? AJRActivity, object == currentActivity {
            if keyPath == "message" {
                AJRRunAsyncOnMainThread {
                    self.activityLayer.message = object.message
                }
            } else if keyPath == "progress" {
                AJRRunAsyncOnMainThread {
                    self.activityLayer.progress = object.progress
                }
            } else if keyPath == "progressMin" {
                AJRRunAsyncOnMainThread {
                    self.activityLayer.progressMinimum = object.progressMin
                }
            } else if keyPath == "progressMax" {
                AJRRunAsyncOnMainThread {
                    self.activityLayer.progressMaximum = object.progressMax
                }
            } else if keyPath == "isIndeterminate" || keyPath == "indeterminate" {
                AJRRunAsyncOnMainThread {
                    self.activityLayer.isIndeterminate = object.isIndeterminate
                }
            }
        }
    }

    // MARK: - NSView

    open override func makeBackingLayer() -> CALayer {
        let layer = AJRActivityToolbarViewLayer()
        layer.delegate = self
        layer.setNeedsDisplay()
        return layer
    }

    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        configureDisplayScale()
    }

    open override func viewDidChangeEffectiveAppearance() {
        layer?.setNeedsDisplay()
    }

}
