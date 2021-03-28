
import Cocoa

class AJRInspectorSliceFont: AJRInspectorSlice {
    
    open var valueKey : AJRInspectorKey<NSFont>?
    open var enabledKey : AJRInspectorKey<Bool>?
    
    open var fontField : AJRButtonTextField {
        return self.baselineAnchorView as! AJRButtonTextField
    }
    
    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("value")
        keys.insert("enabled")
    }
    
    // MARK: - AJRInspectorSlice
    
    open override func buildView(from element: XMLElement) throws {
        valueKey = try AJRInspectorKey(key: "value", xmlElement: element, inspectorElement: self)
        enabledKey = try AJRInspectorKey(key: "enabled", xmlElement: element, inspectorElement: self, defaultValue: true)
        
        try super.buildView(from: element)
        
        fontField.buttonTarget = self
        fontField.buttonAction = #selector(showFontPanel(_:))
        fontField.buttonPosition = .trailing
        fontField.setImages(withTemplate: AJRImages.image(named: "AJRFontButton", in: Bundle(for: AJRInspectorSliceFont.self)))
        
        weak var weakSelf = self
        valueKey?.addObserver {
            if let strongSelf = weakSelf {
                switch strongSelf.valueKey?.selectionType ?? .none {
                case .none:
                    strongSelf.fontField.stringValue = ""
                    strongSelf.fontField.placeholderString = strongSelf.translator["No Selection"]
                    strongSelf.fontField.isEnabled = false
                case .multiple:
                    strongSelf.fontField.stringValue = ""
                    strongSelf.fontField.placeholderString = strongSelf.translator["Multiple Selection"]
                    strongSelf.fontField.isEnabled = true
                case .single:
                    if let font = strongSelf.valueKey?.value {
                        strongSelf.fontField.stringValue = font.displayName ?? ""
                        strongSelf.fontField.placeholderString = ""
                    } else {
                        strongSelf.fontField.stringValue = ""
                        strongSelf.fontField.placeholderString = strongSelf.translator["No Font"]
                    }
                    strongSelf.fontField.isEnabled = true
                }
            }
        }
    }

    // MARK: - Actions
    
    open func showFontPanel(_ sender: AJRButtonTextField?) -> Void {
        if let font = valueKey?.value {
            NSFontManager.shared.setSelectedFont(font, isMultiple: false)
        }
        NSFontManager.shared.target = self
        NSFontManager.shared.action = #selector(changeFont(_:))
        NSFontPanel.shared.orderFront(self)
    }
    
    open func changeFont(_ sender: Any?) -> Void {
        let manager = NSFontManager.shared
        if let baseFont = manager.selectedFont {
            valueKey?.value = manager.convert(manager.convert(baseFont), toSize: 144.0)
        }
    }
    
}
