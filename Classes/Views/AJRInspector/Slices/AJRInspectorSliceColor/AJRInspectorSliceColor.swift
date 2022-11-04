/*
 AJRInspectorSliceColor.swift
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
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
    
    @IBAction open func takeColor(from sender: AJRColorWell?) -> Void {
        if let colorWell = sender {
            if colorWell.displayMode == .none {
                valueKey?.value = nil
            } else {
                valueKey?.value = colorWell.color
            }
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
