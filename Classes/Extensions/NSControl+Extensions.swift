
import Foundation

import AJRFoundation

public extension NSControl {
    
    @objc(URLValue)
    var urlValue : URL? {
        get {
            return URL(parsableString: stringValue)
        }
        set {
            stringValue = newValue?.absoluteString ?? ""
        }
    }
    
}

