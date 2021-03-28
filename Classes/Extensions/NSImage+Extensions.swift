
import Foundation

public extension NSImage {

    var basicCGImage : CGImage? {
        return cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
}
