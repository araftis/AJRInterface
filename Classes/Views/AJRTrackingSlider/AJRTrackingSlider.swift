//
//  AJRTrackingSlider.swift
//  AJRInterface
//
//  Created by AJ Raftis on 7/30/26.
//

import Cocoa

@objcMembers
open class AJRTrackingSlider: NSSlider {

    open var willBeginTracking: (() -> Void)?
    open var didEndTracking: (() -> Void)?

    open override func mouseDown(with event: NSEvent) {
        willBeginTracking?()
        super.mouseDown(with: event)
        didEndTracking?()
    }

    private var isTrackingKeyboardChange = false

    open override func keyDown(with event: NSEvent) {
        guard isAdjustmentKey(event) else {
            super.keyDown(with: event)
            return
        }

        if !isTrackingKeyboardChange {
            isTrackingKeyboardChange = true
            willBeginTracking?()
        }

        super.keyDown(with: event)
    }

    open override func keyUp(with event: NSEvent) {
        if isTrackingKeyboardChange && isAdjustmentKey(event) {
            isTrackingKeyboardChange = false
            didEndTracking?()
        }

        super.keyUp(with: event)
    }

    private func isAdjustmentKey(_ event: NSEvent) -> Bool {
        switch event.specialKey {
        case .leftArrow,
                .rightArrow,
                .upArrow,
                .downArrow,
                .pageUp,
                .pageDown,
                .home,
                .end:
            return true

        default:
            return false
        }
    }

}
