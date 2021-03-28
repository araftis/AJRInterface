
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
