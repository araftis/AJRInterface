/*
AJRSnapshotView.swift
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
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

import Foundation

/**
 Creates a snapshow of the passed in view and then renders that snapshot.

 This class is useful when you need to temporarily create a static snapshot of a view to then display it in the view hierarchy. For example, you might want to animate two view swapping, and it's a lot more efficient to animate a snapshow of the views rather than animating the views drawing themseles each time.
 */
@objcMembers
open class AJRSnapshotView : NSView {

    internal var image: AJRImage
    /**
     The amount of opacity used when drawing the snapshot image. Should be in the range of [0.0..1.0].
     */
    public var opacity : CGFloat = 1.0 {
        didSet {
            needsDisplay = true
        }
    }

    /**
     Creates a new snapshot with `view`.

     This is the required initializer for the `AJRSnapshotView`. You must provide view as an input, and the view should be in a good state to be snapped shotted.
     */
    required public init(view: NSView) {
        let bounds = view.bounds
        var window = view.window
        var saveFrame = NSRect.zero

        if window == nil {
            window = NSWindow(contentRect: NSRect(x: -bounds.size.width, y: -bounds.size.height, width: bounds.size.width, height: bounds.size.height), styleMask: [.borderless], backing: .buffered, defer: false)
            saveFrame = view.frame
            window?.contentView = view
            window?.orderFront(nil)
        }
        if let bitmap = view.bitmapImageRepForCachingDisplay(in: bounds) {
            view.cacheDisplay(in: view.bounds, to: bitmap)
            image = NSImage(size: bounds.size)
            image.addRepresentation(bitmap)
        } else {
            image = NSImage(size: bounds.size)
        }
        //[[_image TIFFRepresentation] writeToFile:@"/tmp/t.tiff" atomically:YES];
        if let window = window {
            view.removeFromSuperview()
            view.frame = saveFrame
            window.orderOut(nil)
        }

        super.init(frame: view.frame)
    }

    required public init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open var isOpaque: Bool { return false }

    override open func draw(_ dirtyRect: NSRect) {
        image.draw(in: self.bounds, from: NSRect(origin: NSPoint.zero, size: image.size), operation: .sourceOver, fraction: opacity)
    }

}
