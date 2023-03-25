/*
 AJRInspectorSliceAttributedString.swift
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

import Cocoa

fileprivate enum AJRSegmentType : Int {
    case bold
    case italics
    case underline
    case outline
    case strikethrough
    case fontPanel
    case foregroundColor
}

fileprivate enum AJRSegmentAlignmentType : Int {
    case left
    case center
    case right
    case justified
    case natural
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
    
    var selectedAlignmentControl : AJRSegmentAlignmentType? {
        return AJRSegmentAlignmentType(rawValue: self.selectedSegment)
    }
    
    func isSelected(forSegment segment: AJRSegmentAlignmentType) -> Bool {
        return isSelected(forSegment: segment.rawValue)
    }
    
    func setSelected(_ selected: Bool, forSegment segment: AJRSegmentAlignmentType) -> Void {
        setSelected(selected, forSegment: segment.rawValue)
    }
    
}

class AJRInspectorSliceAttributedString: AJRInspectorSliceField, AJRInspectorTextFieldDelegate {

    open var valueKey : AJRInspectorKey<NSAttributedString>?
    
    open var fieldEditor : NSTextView? = nil
    
    @IBOutlet open var attributeSegments : NSSegmentedControl!
    @IBOutlet open var alignmentSegments : NSSegmentedControl!

    // MARK: - View

    open override func tearDown() {
        valueKey?.stopObserving()
        attributeSegments = nil
        alignmentSegments = nil
        fieldEditor = nil
        super.tearDown()
    }

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
                    if strongSelf.field.attributedStringValue.length == 0 {
                        strongSelf.updateDisplay(for: [:])
                    } else {
                        strongSelf.updateDisplay(for: strongSelf.field.attributedStringValue.attributes(at: 0, effectiveRange: nil))
                    }
                }
                
                if strongSelf.field.isEditable {
                    strongSelf.attributeSegments.isHidden = false
                    strongSelf.alignmentSegments.isHidden = false
                } else {
                    strongSelf.attributeSegments.isHidden = true
                    strongSelf.alignmentSegments.isHidden = true
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
    
    open func toggleTrait(_ trait: NSFontTraitMask, from sender: Any?) -> Void {
        if var font = attribute(.font, in: fieldEditor) as? NSFont {
            if NSFontManager.shared.traits(of: font).contains(trait) {
                font = NSFontManager.shared.convert(font, toNotHaveTrait: trait)
                NSFontManager.shared.removeFontTrait(sender)
            } else {
                font = NSFontManager.shared.convert(font, toHaveTrait: trait)
                NSFontManager.shared.addFontTrait(sender)
            }
            setAttribute(.font, to: font, in: fieldEditor)
            updateDisplay(forEditor: fieldEditor)
            updateHeightContraint()
        }
    }
    
    @IBAction open func toggleBold(_ sender: Any?) -> Void {
        if let sender = sender as? NSSegmentedControl {
            sender.tag = 2
        }
        toggleTrait(.boldFontMask, from: sender)
    }
    
    @IBAction open func toggleItalics(_ sender: Any?) -> Void {
        if let sender = sender as? NSSegmentedControl {
            sender.tag = 1
        }
        toggleTrait(.italicFontMask, from: sender)
    }
    
    @IBAction open func toggleUnderline(_ sender: Any?) -> Void {
        if hasAttribute(.underlineStyle, in: fieldEditor) {
            setAttribute(.underlineStyle, to: nil, in: fieldEditor)
        } else {
            setAttribute(.underlineStyle, to: NSUnderlineStyle.single, in: fieldEditor)
        }
        updateDisplay(forEditor: fieldEditor)
        updateHeightContraint()
    }
    
    @IBAction open func toggleOutline(_ sender: Any?) -> Void {
        if hasAttribute(.strokeWidth, in: fieldEditor) {
            setAttribute(.strokeWidth, to: nil, in: fieldEditor)
        } else {
            setAttribute(.strokeWidth, to: 3.0, in: fieldEditor)
        }
        updateDisplay(forEditor: fieldEditor)
        updateHeightContraint()
    }
    
    @IBAction open func toggleStrikethrough(_ sender: Any?) -> Void {
        if hasAttribute(.strikethroughStyle, in: fieldEditor) {
            setAttribute(.strikethroughStyle, to: nil, in: fieldEditor)
        } else {
            setAttribute(.strikethroughStyle, to: NSUnderlineStyle.single, in: fieldEditor)
        }
        updateDisplay(forEditor: fieldEditor)
        updateHeightContraint()
    }
    
    @IBAction open func showFontPanel(_ sender: Any?) -> Void {
        attributeSegments.setSelected(false, forSegment: .fontPanel)
        if NSFontPanel.shared.isVisible {
            NSFontPanel.shared.orderOut(sender)
        } else {
            NSFontPanel.shared.orderFront(sender)
        }
    }
    
    @IBAction open func takeColor(from sender: AJRColorSwatchView?) -> Void {
        attributeSegments.setSelected(false, forSegment: .foregroundColor)
        setAttribute(.foregroundColor, to: sender?.selectedColor, in: fieldEditor)
        updateDisplay(forEditor: fieldEditor)
        valueKey?.value = field.attributedStringValue
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
        case .outline:
            toggleOutline(sender)
        case .strikethrough:
            toggleStrikethrough(sender)
        case .fontPanel:
            showFontPanel(sender)
        case .foregroundColor:
            showColors(sender)
        case .none:
            break
        }
        valueKey?.value = field.attributedStringValue
    }
    
    @IBAction open func selectAlignmentSegment(_ sender: NSSegmentedControl?) -> Void {
        let alignment : NSTextAlignment
        switch sender?.selectedAlignmentControl {
        case .left:
            alignment = .left
        case .center:
            alignment = .center
        case .right:
            alignment = .right
        case .justified:
            alignment = .justified
        case .natural:
            alignment = .natural
        case .none:
            alignment = .left
        }
        var style = (attribute(.paragraphStyle, in: fieldEditor) as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle
        if style == nil {
            style = NSMutableParagraphStyle()
        }
        style?.alignment = alignment
        setAttribute(.paragraphStyle, to: style, in: fieldEditor)
        updateDisplay(forEditor: fieldEditor)
        valueKey?.value = field.attributedStringValue
    }

    @IBAction open func selectColorFromPanel(_ sender: Any?) -> Void {
        print("sender: \(sender!)")
    }
    
    // MARK: - AJRInspectorTextFieldDelegate
    
    open func textField(_ textField: AJRInspectorTextField, selectionDidChangeInFieldEditor text: NSTextView) {
        if editableKey?.value ?? true {
            updateDisplay(forEditor: text)
        }
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
    
    open func attributes(in editor: NSTextView?) -> [NSAttributedString.Key:Any] {
        let attributes : [NSAttributedString.Key:Any]

        if let editor = editor {
            let selection = editor.selectedRange()
            
            if selection.length == 0 {
                attributes = editor.typingAttributes
            } else {
                attributes = editor.textStorage!.attributes(at: selection.location, effectiveRange: nil)
            }
        } else {
            let string = field.attributedStringValue
            attributes = string.attributes(at: 0, effectiveRange: nil)
        }
        
        return attributes
    }
    
    open func attribute(_ key: NSAttributedString.Key, in editor: NSTextView?) -> Any? {
        return attributes(in: editor)[key]
    }
    
    open func hasAttribute(_ attribute: NSAttributedString.Key, in editor: NSTextView?) -> Bool {
        return self.attribute(attribute, in: editor) != nil
    }
    
    private func attributedValue(for value: Any?) -> Any? {
        if let value = value {
            if let value = value as? NSUnderlineStyle {
                return value.rawValue
            } else {
                return value
            }
        }
        return nil
    }
    
    open func setAttribute(_ key: NSAttributedString.Key, to value: Any?, in editor: NSTextView?) -> Void {
        if let editor = editor {
            var attributes = self.attributes(in: editor)
            
            attributes[key] = attributedValue(for: value)
            
            let selection = editor.selectedRange()
            if selection.length == 0 {
                editor.typingAttributes = attributes
            } else {
                editor.textStorage!.setAttributes(attributes, range: selection)
            }
        } else {
            let string = field.attributedStringValue.mutableCopy() as! NSMutableAttributedString
            if let value = value {
                string.addAttribute(key, value: attributedValue(for: value)!, range: string.string.fullRange)
            } else {
                string.removeAttribute(key, range: string.string.fullRange)
            }
            field.attributedStringValue = string
        }
    }
    
    open func currentAttributes(hasFontTrait mask: NSFontTraitMask, in editor: NSTextView?) -> Bool {
        if let font = attribute(.font, in: editor) as? NSFont {
            let traits = NSFontManager.shared.traits(of: font)
            return traits.contains(mask)
        }
        return false
    }
    
    open func updateDisplay(forEditor editor : NSTextView?) -> Void {
        if editableKey?.value ?? true {
            updateDisplay(for: attributes(in: editor))
        }
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
        if let outline = attributes[.strokeWidth] as? Int {
            attributeSegments.setSelected(outline > 0, forSegment: .outline)
        } else {
            attributeSegments.setSelected(false, forSegment: .strikethrough)
        }
        if let strikethough = attributes[.strikethroughStyle] as? Int {
            attributeSegments.setSelected(strikethough >= 0, forSegment: .strikethrough)
        } else {
            attributeSegments.setSelected(false, forSegment: .strikethrough)
        }
        if let style = attributes[.paragraphStyle] as? NSParagraphStyle {
            switch style.alignment {
            case .left:
                alignmentSegments.setSelected(true, forSegment: .left)
            case .center:
                alignmentSegments.setSelected(true, forSegment: .center)
            case .right:
                alignmentSegments.setSelected(true, forSegment: .right)
            case .justified:
                alignmentSegments.setSelected(true, forSegment: .justified)
            case .natural:
                alignmentSegments.setSelected(true, forSegment: .natural)
            @unknown default:
                alignmentSegments.setSelected(true, forSegment: .left)
            }
        } else {
            alignmentSegments.setSelected(true, forSegment: .left)
        }
    }

}
