//
//  AJRInspectorSliceColor.swift
//  AJRInspectorsTest
//
//  Created by AJ Raftis on 3/19/19.
//

import Cocoa

extension NSColor : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        return AJRColorFromString(string)
    }
    
    public var integerValue : Int { return 0 }
    public var doubleValue : Double { return 0.0 }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        return nil
    }
    
}

class AJRInspectorSliceColor: AJRInspectorSlice {
    
    @IBOutlet open var colorWell : AJRColorWell!
    open override var baseLineOffset : CGFloat { return 13.0 }
    
    open var valueKey : AJRInspectorKey<NSColor>?
    open var enabledKey : AJRInspectorKey<Bool>?

    // MARK: - Actions
    
    @IBAction open func takeColor(from sender: NSColorWell?) -> Void {
        if let colorWell = sender {
            valueKey?.value = colorWell.color
        }
    }
    
    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("value")
        keys.insert("enabled")
    }
    
    // MARK: - View
    
    open override func buildView(from element: XMLElement) throws {
        valueKey = try AJRInspectorKey(key: "value", xmlElement: element, inspectorElement: self)
        enabledKey = try AJRInspectorKey(key: "enabled", xmlElement: element, inspectorElement: self)
        
        try super.buildView(from: element)
        
        weak var weakSelf = self
        valueKey?.addObserver {
            if let strongSelf = weakSelf {
                switch strongSelf.valueKey?.selectionType ?? .none {
                case .none:
                    strongSelf.colorWell.color = NSColor.gray
                    strongSelf.colorWell.isEnabled = false
                    strongSelf.colorWell.displayMode = .none
                case .multiple:
                    strongSelf.colorWell.isEnabled = true
                    strongSelf.colorWell.displayMode = .multiple
                case .single:
                    if let value = strongSelf.valueKey?.value {
                        strongSelf.colorWell.color = value
                    }
                    strongSelf.colorWell.isEnabled = strongSelf.enabledKey?.value ?? true
                    strongSelf.colorWell.displayMode = .color
                }
            }
        }
        enabledKey?.addObserver { 
            if let strongSelf = weakSelf {
                strongSelf.colorWell.isEnabled = strongSelf.enabledKey?.value ?? true
            }
        }
    }
    
    open override func canMergeWithElement(_ element: AJRInspectorElement) -> Bool {
        if element is AJRInspectorSliceColor {
            if self.labelKey == nil {
                return true
            }
        }
        return false
    }
    
}
