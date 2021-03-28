
import Foundation

import AJRInterfaceFoundation

public extension String {
    
    func size(withAttributes attributes: [NSAttributedString.Key:Any]?) -> CGSize {
        return (self as NSString).size(withAttributes: attributes)
    }

    func size(withAttributes attributes: [NSAttributedString.Key:Any], constrainedToWidth width: CGFloat) -> CGSize {
        return (self as NSString).size(withAttributes:attributes, constrainedToWidth: width)
    }
    
    func draw(at point: NSPoint, with attributes: [NSAttributedString.Key:Any], context: CGContext? = nil) -> Void {
        var possibleContext = context
        if possibleContext == nil {
            possibleContext = AJRGetCurrentContext()
        }
        if let context = possibleContext {
            NSGraphicsContext.draw(in: context) {
                (self as NSString).draw(at: point, withAttributes: attributes)
            }
        }
    }
    
    func draw(in rect: NSRect, with attributes: [NSAttributedString.Key:Any], context: CGContext? = nil) -> Void {
        var possibleContext = context
        if possibleContext == nil {
            possibleContext = AJRGetCurrentContext()
        }
        if let context = possibleContext {
            NSGraphicsContext.draw(in: context) {
                (self as NSString).draw(in: rect, withAttributes: attributes)
            }
        }
    }
    
    func replacingTypographicalSubstitutions() -> String {
        return (self as NSString).replacingTypographicalSubstitutions()
    }
    
}
