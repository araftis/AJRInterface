//
//  AJRInspectorSliceAttributedString.swift
//  AJRInterface
//
//  Created by AJ Raftis on 7/8/19.
//

import Cocoa

fileprivate enum AJRSegmentType : Int {
    
    case bold
    case italics
    case underline
    case fontPanel
    case foregroundColor
    
}

fileprivate extension NSSegmentedControl {
    
    var selectedControl : AJRSegmentType? {
        return AJRSegmentType(rawValue: self.selectedSegment)
    }
    
    func isSelected(forSegment segment: AJRSegmentType) -> Bool {
        return isSelected(forSegment: segment.rawValue)
    }
    
    func setSelected(_ selected: Bool, forSegment segment: AJRSegmentType) -> Void {
        setSelected(selected, forSegment: segment.rawValue)
    }
    
    func setImage(_ image: NSImage?, forSegment segment: AJRSegmentType) -> Void {
        setImage(image, forSegment: segment.rawValue)
    }
    
    func setMenu(_ menu: NSMenu?, forSegment segment: AJRSegmentType) -> Void {
        setMenu(menu, forSegment: segment.rawValue)
    }
    
}

class AJRInspectorSliceAttributedString: AJRInspectorSliceField, AJRInspectorTextFieldDelegate {

    open var valueKey : AJRInspectorKey<NSAttributedString>?
    
    open var fieldEditor : NSTextView? = nil
    
    @IBOutlet open var attributeSegments : NSSegmentedControl!
    
    // MARK: - View
    
    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("value")
    }
    
    open override func buildView(from element: XMLElement) throws {
        valueKey = try AJRInspectorKey(key: "value", xmlElement: element, inspectorElement: self)
        
        try super.buildView(from: element)
        
        attributeSegments.setMenu(AJRColorSwatchMenu(self, #selector(takeColor(from:)), self, #selector(showColors(_:))), forSegment: .foregroundColor)
        
        weak var weakSelf = self
        valueKey?.addObserver {
            if let strongSelf = weakSelf {
                var changedValue = false

                switch strongSelf.valueKey?.selectionType ?? .none {
                case .none:
                    if !AJRAnyEquals(strongSelf.field.placeholderString, AJRObjectInspectorViewController.translator["No Selection"]) {
                        strongSelf.field.stringValue = ""
                        strongSelf.field.placeholderString = AJRObjectInspectorViewController.translator["No Selection"]
                        strongSelf.field.isEditable = false
                        changedValue = true
                    }
                case .multiple:
                    if !AJRAnyEquals(strongSelf.field.placeholderString, AJRObjectInspectorViewController.translator["Multiple Selection"]) {
                        strongSelf.field.stringValue = ""
                        strongSelf.field.placeholderString = AJRObjectInspectorViewController.translator["Multiple Selection"]
                        strongSelf.field.isEditable = strongSelf.editableKey?.value ?? true
                        changedValue = true
                    }
                case .single:
                    strongSelf.field.placeholderString = ""
                    if let value = strongSelf.valueKey?.value {
                        if !AJRAnyEquals(strongSelf.field.attributedStringValue, value) {
                            strongSelf.field.attributedStringValue = value
                            strongSelf.field.isEditable = strongSelf.editableKey?.value ?? true
                            changedValue = true
                        }
                    } else {
                        strongSelf.field.attributedStringValue = NSAttributedString()
                        if let nullPlaceholder = strongSelf.nullPlaceholder?.value {
                            strongSelf.field.placeholderString = nullPlaceholder
                        } else {
                            strongSelf.field.placeholderString = ""
                        }
                        strongSelf.field.isEditable = strongSelf.editableKey?.value ?? true
                        changedValue = true
                    }
                }
                
                if changedValue {
                    strongSelf.updateHeightContraint()
                    strongSelf.updateDisplay(for: strongSelf.field.attributedStringValue.attributes(at: 0, effectiveRange: nil))
                }
            }
        }
    }
    
    open override var nibName: String? {
        return "AJRInspectorSliceAttributedField"
    }
    
    // MARK: - Actions
    
    @IBAction open override func takeValue(from sender: Any?) -> Void {
        if let sender = sender as? NSTextField {
            let value = sender.attributedStringValue
            
            if value.length == 0, let emptyIsNull = emptyIsNull?.value, emptyIsNull {
                valueKey?.value = nil
            } else {
                valueKey?.value = value
            }
        }
    }
    
    @IBAction open func toggleBold(_ sender: Any?) -> Void {
        if let sender = sender as? NSSegmentedControl {
            sender.tag = 2
        }
        if let fieldEditor = fieldEditor {
            if currentAttributes(in: fieldEditor, hasFontTrait: .boldFontMask) {
                NSFontManager.shared.removeFontTrait(sender)
            } else {
                NSFontManager.shared.addFontTrait(sender)
            }
            updateDisplay(forEditor: fieldEditor)
            updateHeightContraint()
        }
    }
    
    @IBAction open func toggleItalics(_ sender: Any?) -> Void {
        if let sender = sender as? NSSegmentedControl {
            sender.tag = 1
        }
        if let fieldEditor = fieldEditor {
            if currentAttributes(in: fieldEditor, hasFontTrait: .italicFontMask) {
                NSFontManager.shared.removeFontTrait(sender)
            } else {
                NSFontManager.shared.addFontTrait(sender)
            }
            updateDisplay(forEditor: fieldEditor)
            updateHeightContraint()
        }
    }
    
    @IBAction open func toggleUnderline(_ sender: Any?) -> Void {
        if let fieldEditor = fieldEditor {
            fieldEditor.underline(sender)
        }
    }
    
    @IBAction open func showFontPanel(_ sender: Any?) -> Void {
        attributeSegments.setSelected(false, forSegment: .fontPanel)
        if NSFontPanel.shared.isVisible {
            NSFontPanel.shared.orderOut(sender)
        } else {
            NSFontPanel.shared.orderFront(sender)
        }
    }
    
    @IBAction open func takeColor(from sender: Any?) -> Void {
        attributeSegments.setSelected(false, forSegment: .foregroundColor)
        if let fieldEditor = fieldEditor {
            let color = (sender as? AJRColorSwatchView)?.selectedColor
            fieldEditor.setTextColor(color, range: fieldEditor.selectedRange())
            var typingAttributes = fieldEditor.typingAttributes
            typingAttributes[.foregroundColor] = color
            fieldEditor.typingAttributes = typingAttributes
        }
    }
    
    @IBAction open func showColors(_ sender: Any?) -> Void {
        attributeSegments.setSelected(false, forSegment: .foregroundColor)
        if NSColorPanel.shared.isVisible {
            NSColorPanel.shared.orderOut(sender)
            NSColorPanel.shared.setTarget(nil)
        } else {
            NSColorPanel.shared.orderFront(sender)
            NSColorPanel.shared.setTarget(self)
        }
    }
    
    @IBAction open func selectSegment(_ sender: NSSegmentedControl?) -> Void {
        switch sender?.selectedControl {
        case .bold:
            toggleBold(sender)
        case .italics:
            toggleItalics(sender)
        case .underline:
            toggleUnderline(sender)
        case .fontPanel:
            showFontPanel(sender)
        case .foregroundColor:
            showColors(sender)
        default:
            break
        }
    }
    
    // MARK: - AJRInspectorTextFieldDelegate
    
    open func textField(_ textField: AJRInspectorTextField, selectionDidChangeInFieldEditor text: NSTextView) {
        updateDisplay(forEditor: text)
    }
    
    open func textField(_ textField: AJRInspectorTextField, willBeginEditingInFieldEditor text: NSTextView) -> Void {
        fieldEditor = text
    }
    
    open func textField(_ textField: AJRInspectorTextField, didEndEditingInFieldEditor text: NSTextView) -> Void {
        fieldEditor = nil
    }
    
    open func textField(_ textField: AJRInspectorTextField, typingAttributesDidChangeInFieldEditor text: NSTextView) -> Void {
        updateDisplay(forEditor: text)
    }

    // MARK: - Utilities
    
    open func attributes(forEditor editor: NSTextView) -> [NSAttributedString.Key:Any] {
        let selection = editor.selectedRange()
        let attributes : [NSAttributedString.Key:Any]
        
        if selection.length == 0 {
            attributes = editor.typingAttributes
        } else {
            attributes = editor.textStorage!.attributes(at: selection.location, effectiveRange: nil)
        }
        
        return attributes
    }
    
    open func currentAttributes(in editor: NSTextView, hasFontTrait mask: NSFontTraitMask) -> Bool {
        if let font = attributes(forEditor: editor)[.font] as? NSFont {
            let traits = NSFontManager.shared.traits(of: font)
            return traits.contains(mask)
        }
        return false
    }
    
    open func updateDisplay(forEditor editor : NSTextView) -> Void {
        updateDisplay(for: attributes(forEditor: editor))
    }
    
    open func updateDisplay(for attributes: [NSAttributedString.Key:Any]) -> Void {
        if let font = attributes[.font] as? NSFont {
            let traits = NSFontManager.shared.traits(of: font)
            attributeSegments.setSelected(traits.contains(.boldFontMask), forSegment: .bold)
            attributeSegments.setSelected(traits.contains(.italicFontMask), forSegment: .italics)
        }
        attributeSegments.setSelected(attributes[.underlineStyle] != nil, forSegment: .underline)
        if let color = attributes[.foregroundColor] as? NSColor {
            let image = AJRColorSwatchImage(color, false, NSSize(width: 12.0, height: 12.0))
            attributeSegments.setImage(image, forSegment: .foregroundColor)
        }
    }

}
