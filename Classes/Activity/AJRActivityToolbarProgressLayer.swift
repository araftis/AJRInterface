/*
 AJRActivityToolbarProgressLayer.m
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

@objcMembers
open class AJRActivityToolbarProgressLayer : CALayer {

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override init() {
        super.init()
        print("init")
    }

    deinit {
        if let animationTimer {
            animationTimer.invalidate()
            self.animationTimer = nil
        }
    }

    // MARK: - Properties

    internal var _indeterminateImage : NSImage? = nil
    internal var indeterminateImage : NSImage {
        if _indeterminateImage == nil {
            let size = NSSize(width: 40.0, height: 2.0)
            _indeterminateImage = NSImage.ajr_image(with: size, scales: [1.0, 2.0], flipped: false, colorSpace: .sRGB) { scale in
                if let context = AJRGetCurrentContext() {
                    context.setFillColor(self.color)
                    context.fill([CGRect(origin: .zero, size: size)])

                    let path = AJRBezierPath()
                    path.move(to: .zero)
                    path.lineTo(x: 2.0, y: 2.0)
                    path.lineTo(x: 7.0, y: 2.0)
                    path.lineTo(x: 5.0, y: 0.0)
                    path.close()

                    context.setFillColor(CGColor(gray: 1.0, alpha: 0.75))
                    for _ in 0 ..< 5 {
                        path.fill()
                        context.translateBy(x: 10.0, y: 0.0)
                    }
                }
            }
            _indeterminateImage!.capInsets = NSEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            _indeterminateImage!.resizingMode = .tile
        }
        return _indeterminateImage!
    }

    internal var _indeterminateColor : NSColor? = nil
    internal var indeterminateColor : NSColor {
        if _indeterminateColor == nil {
            _indeterminateColor = NSColor(patternImage: indeterminateImage)
        }
        return _indeterminateColor!
    }

    // MARK: - Properties

    open var color : CGColor = NSColor.selectedContentBackgroundColor.cgColor {
        didSet {
            _indeterminateImage = nil
            _indeterminateColor = nil
        }
    }

    internal var animationTimer : Timer? = nil
    internal var animationOffset: CGFloat = 0.0

    open var isIndeterminate : Bool = false {
        willSet {
            if let animationTimer {
                animationTimer.invalidate()
                self.animationTimer = nil
            }
        }
        didSet {
            if isIndeterminate {
                animationOffset = 0.0
                weak var weakSelf = self
                animationTimer = Timer(timeInterval: 0.1, repeats: true) { timer in
                    if let strongSelf = weakSelf {
                        strongSelf.animationOffset += 2.0
                        if strongSelf.animationOffset > 30.0 {
                            strongSelf.animationOffset = 0.0
                        }
                        strongSelf.setNeedsDisplay()
                    }
                }
                RunLoop.current.add(animationTimer!, forMode: .common)
                animationTimer!.fire()
            }
            setNeedsDisplay()
        }
    }

    open var minimum: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    open var maximum: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    open var progress: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    // MARK: - CALayer

    open override func draw(in context: CGContext) {
        NSGraphicsContext.draw(in: context) {
            if let parent = self.superlayer {
                let parentBounds = parent.convert(parent.bounds, to: self)
                let path = AJRBezierPath(roundedRect: parentBounds, xRadius: 4.0, yRadius: 4.0)
                path.addClip()
            }

            if self.isIndeterminate {
                context.drawWithSavedGraphicsState {
                    var rect = self.bounds
                    rect.origin.x -= 30.0
                    rect.size.width += 60.0
                    context.translateBy(x: self.animationOffset, y: 0.0)
                    self.indeterminateImage.draw(in: rect)
                }
            } else {
                var rect = self.bounds
                let percent = self.progress / (self.maximum - self.minimum)
                rect.size.width *= percent
                context.setFillColor(self.color)
                context.fill([rect])
            }
        }
    }

}
