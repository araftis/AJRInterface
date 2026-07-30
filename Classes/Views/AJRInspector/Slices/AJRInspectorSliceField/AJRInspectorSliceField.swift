/*
 AJRInspectorSliceField.swift
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

@objcMembers
open class AJRInspectorSliceField: AJRInspectorSlice, NSTextFieldDelegate {
    
    @IBOutlet open var heightConstraint : NSLayoutConstraint!
    @IBOutlet open var field : NSTextField!
    
    open var editableKey : AJRInspectorKey<Bool>?
    open var selectableKey : AJRInspectorKey<Bool>?
    open var enabledKey : AJRInspectorKey<Bool>?
    open var isContinuous : AJRInspectorKey<Bool>?
    open var emptyIsNull : AJRInspectorKey<Bool>?
    open var nullPlaceholder : AJRInspectorKey<String>?
    open var alignmentKey : AJRInspectorKey<NSTextAlignment>?
    open var colorKey : AJRInspectorKey<NSColor>?
    open var backgroundColorKey : AJRInspectorKey<NSColor>?

    open var hasEdits : Bool = false
    
    open override var nibName: String? {
        return "AJRInspectorSliceField"
    }

    open override func tearDown() {
        field?.delegate = nil
        field?.target = nil
        heightConstraint = nil
        field = nil
        editableKey?.stopObserving()
        selectableKey?.stopObserving()
        enabledKey?.stopObserving()
        isContinuous?.stopObserving()
        emptyIsNull?.stopObserving()
        nullPlaceholder?.stopObserving()
        alignmentKey?.stopObserving()
        colorKey?.stopObserving()
        backgroundColorKey?.stopObserving()
        super.tearDown()
    }

    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("editable")
        keys.insert("selectable")
        keys.insert("enabled")
        keys.insert("emptyIsNull")
        keys.insert("nullPlaceholder")
        keys.insert("alignment")
        keys.insert("color")
        keys.insert("backgroundColor")
        keys.insert("continuous")
    }
    
    // MARK: - View
    
    open override func buildView(from element: XMLElement) throws {
        editableKey        = try AJRInspectorKey(key: "editable",        xmlElement: element, inspectorElement: self)
        selectableKey      = try AJRInspectorKey(key: "selectable",      xmlElement: element, inspectorElement: self)
        enabledKey         = try AJRInspectorKey(key: "enabled",         xmlElement: element, inspectorElement: self)
        emptyIsNull        = try AJRInspectorKey(key: "emptyIsNull",     xmlElement: element, inspectorElement: self)
        nullPlaceholder    = try AJRInspectorKey(key: "nullPlaceholder", xmlElement: element, inspectorElement: self)
        alignmentKey       = try AJRInspectorKey(key: "alignment",       xmlElement: element, inspectorElement: self)
        colorKey           = try AJRInspectorKey(key: "color",           xmlElement: element, inspectorElement: self)
        backgroundColorKey = try AJRInspectorKey(key: "backgroundColor", xmlElement: element, inspectorElement: self)
        isContinuous       = try AJRInspectorKey(key: "continuous",      xmlElement: element, inspectorElement: self)

        try super.buildView(from: element)
        
        editableKey?.addObserver { [weak self] in
            guard let self else { return }
                if self.editableKey?.value ?? true {
                    self.field.isEditable = true
                    self.field.isBordered = true
                    self.field.isBezeled = true
                    self.field.bezelStyle = .squareBezel
                    self.field.drawsBackground = true
                } else {
                    self.field.isEditable = false
                    self.field.lineBreakMode = NSLineBreakMode.byWordWrapping
                    self.field.maximumNumberOfLines = 0
                    self.field.isBordered = false
                    self.field.isBezeled = false
                    self.field.drawsBackground = false
                    self.field.abortEditing()
                }
            self.updateHeightContraint()
        }
        selectableKey?.addObserver { [weak self] in
            guard let self else { return }
            if self.selectableKey?.value ?? true {
                self.field.isSelectable = true
            } else {
                self.field.isSelectable = false
                self.field.abortEditing()
            }
        }
        enabledKey?.addObserver { [weak self] in
            guard let self else { return }
            if self.enabledKey?.value ?? true {
                self.field.isEnabled = true
            } else {
                self.field.isEnabled = false
                self.field.abortEditing()
            }
        }
        alignmentKey?.addObserver { [weak self] in
            guard let self else { return }
            self.field.alignment = self.alignmentKey?.value ?? .natural
        }
        colorKey?.addObserver { [weak self] in
            guard let self else { return }
            self.field.textColor = self.colorKey?.value ?? NSColor.textColor
        }
        backgroundColorKey?.addObserver { [weak self] in
            guard let self else { return }
            self.field.backgroundColor = self.backgroundColorKey?.value ?? NSColor.textBackgroundColor
        }
        isContinuous?.addObserver { [weak self] in
            guard let self else { return }
            self.field.isContinuous = self.isContinuous?.value ?? false
        }
    }
    
    // MARK: - Actions
    
    @IBAction open func takeValue(from sender: Any?) -> Void {
    }
    
    // MARK: - NSTextFieldDelegate
    
    open var desiredHeight : CGFloat {
        let heightAdjustment : CGFloat
        let widthAdjustment : CGFloat
        if editableKey?.value ?? true {
            widthAdjustment = 8.0
            heightAdjustment = 5.0
        } else {
            widthAdjustment = 0.0
            heightAdjustment = 0.0
        }
        
        let width = field.frame.size.width - widthAdjustment
        let string = field.attributedStringValue.mutableCopy() as! NSMutableAttributedString
        let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.lineHeightMultiple = 1.1 // This is a big of a magic value, and I'm not sure why getting the attributed string isn't setting this.
        string.addAttributes([.paragraphStyle:style], range: NSRange(location: 0, length: string.length))
        let size = string.ajr_sizeConstrained(toWidth: width)
        
        return size.height + heightAdjustment
    }
    
    open func updateHeightContraint() -> Void {
        //print("desired: \(desiredHeight): \(field.stringValue)")
        heightConstraint.constant = desiredHeight
    }
    
    open func controlTextDidChange(_ obj: Notification) {
        updateHeightContraint()
        hasEdits = true
    }
    
    open func controlTextDidBeginEditing(_ obj: Notification) {
        hasEdits = false
    }
    
}
