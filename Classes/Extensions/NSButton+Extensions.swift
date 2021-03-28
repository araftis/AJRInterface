
import Foundation

public extension NSButton {

    class func createImageButton(size: CGSize?, image: NSImage, target: Any?, action: Selector?) -> NSButton {
        let button = NSButton(image: image, target: target, action: action)
        button.alternateImage = button.image?.ajr_imageTinted(with: NSColor.selectedContentBackgroundColor)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setButtonType(.momentaryChange)
        button.bezelStyle = .smallSquare
        button.isBordered = false
        if let size = size {
            button.addConstraints([
                button.widthAnchor.constraint(equalToConstant: size.width),
                button.heightAnchor.constraint(equalToConstant: size.height),
                ])
        }
        
        return button
    }

}
