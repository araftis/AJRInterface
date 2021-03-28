
import Cocoa

@objcMembers
open class AJRAlternateHighlightButtonCell: NSButtonCell {
    
    @IBInspectable var tintColor = NSColor(calibratedWhite: 1.0, alpha: 0.7) {
        didSet {
            print("color now: \(tintColor)")
        }
    }
    @IBInspectable var highlightedTintColor = NSColor.selectedContentBackgroundColor
    @IBInspectable var disabledTintColor = NSColor(calibratedWhite: 1.0, alpha: 0.3)

    open func completeInit() {
        if alternateImage == nil, let image = image, image.isTemplate {
            alternateImage = image.ajr_imageTinted(with: highlightedTintColor)
        }
    }
    
    public override init(imageCell image: NSImage?) {
        super.init(imageCell: image)
        completeInit()
    }
    
    public override init(textCell string: String) {
        super.init(textCell: string)
        completeInit()
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)
        completeInit()
    }
    
    public override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        if let button = controlView as? NSButton {
            if button.isBordered {
                super.drawInterior(withFrame: cellFrame, in: controlView)
            } else {
                var color : NSColor? = nil
                
                if button.isEnabled {
                    if button.isHighlighted {
                        color = highlightedTintColor
                    } else {
                        color = tintColor
                    }
                } else {
                    color = disabledTintColor
                }
                
                if let color = color, let image = self.image {
                    let tintedImage = image.ajr_imageTinted(with: color)
                    tintedImage.draw(in: cellFrame)
                }
            }
        }
    }
    
    open override func copy(with zone: NSZone? = nil) -> Any {
        if let copy = super.copy(with: zone) as? AJRAlternateHighlightButtonCell {
            copy.tintColor = tintColor.copy(with: zone) as! NSColor
            AJRForceRetain(copy.tintColor)
            copy.highlightedTintColor = highlightedTintColor.copy(with: zone) as! NSColor
            AJRForceRetain(copy.highlightedTintColor)
            copy.disabledTintColor = disabledTintColor.copy(with: zone) as! NSColor
            AJRForceRetain(copy.disabledTintColor)
            return copy
        }
        preconditionFailure("Calling super.\(#function) didn't produce an instance of \(Self.self).")
    }

}
