//
//  AJRInspectorSliceString.swift
//  AJRInterface
//
//  Created by AJ Raftis on 3/17/19.
//

import Cocoa

@objcMembers
open class AJRInspectorSliceString: AJRInspectorSliceField {
    
    open var valueKey : AJRInspectorKey<String>?

    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("value")
    }
    
    // MARK: - View
    
    open override func buildView(from element: XMLElement) throws {
        valueKey = try AJRInspectorKey(key: "value", xmlElement: element, inspectorElement: self)

        try super.buildView(from: element)
        
        weak var weakSelf = self
        valueKey?.addObserver {
            if let strongSelf = weakSelf {
                switch strongSelf.valueKey?.selectionType ?? .none {
                case .none:
                    strongSelf.field.stringValue = ""
                    strongSelf.field.placeholderString = AJRObjectInspectorViewController.translator["No Selection"]
                    strongSelf.field.isEditable = false
                case .multiple:
                    strongSelf.field.stringValue = ""
                    strongSelf.field.placeholderString = AJRObjectInspectorViewController.translator["Multiple Selection"]
                    strongSelf.field.isEditable = strongSelf.editableKey?.value ?? true
                case .single:
                    strongSelf.field.placeholderString = ""
                    if let value = strongSelf.valueKey?.value {
                        strongSelf.field.stringValue = String(describing: value)
                    } else {
                        strongSelf.field.stringValue = ""
                        if let nullPlaceholder = strongSelf.nullPlaceholder?.value {
                            strongSelf.field.placeholderString = nullPlaceholder
                        } else {
                            strongSelf.field.placeholderString = ""
                        }
                    }
                    strongSelf.field.isEditable = strongSelf.editableKey?.value ?? true
                }
                strongSelf.updateHeightContraint()
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction open override func takeValue(from sender: Any?) -> Void {
        if hasEdits, let sender = sender as? NSTextField {
            let value = sender.stringValue
            
            if value.isEmpty, let emptyIsNull = emptyIsNull?.value, emptyIsNull {
                valueKey?.value = nil
            } else {
                valueKey?.value = value
            }
        }
    }
    
}
