
import AppKit

@objc
public extension NSAppearance {
    
    @objc var isDarkMode : Bool {
        switch self.name {
        case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
            return true
        default:
            return false
        }
    }
    
}
