/*
AJRInspectorSliceFont.swift
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
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
