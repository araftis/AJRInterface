/*
 AJRInspectorSliceBoolean.swift
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
open class AJRInspectorSliceBoolean: AJRInspectorSlice {

    @IBOutlet var check : NSButton!
    
    open var valueKey : AJRInspectorKey<Bool>?
    open var enabledKey : AJRInspectorKey<Bool>?
    open var titleKey : AJRInspectorKey<String>?
    open var negateKey : AJRInspectorKey<Bool>?

    open override func tearDown() {
        check = nil
        valueKey?.stopObserving()
        enabledKey?.stopObserving()
        titleKey?.stopObserving()
        negateKey?.stopObserving()
        super.tearDown()
    }
    
    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("value")
        keys.insert("title")
        keys.insert("enabled")
        keys.insert("negate")
    }
    
    // MARK: - View
    
    open override func buildView(from element: XMLElement) throws {
        valueKey = try AJRInspectorKey(key: "value", xmlElement: element, inspectorElement: self)
        titleKey = try AJRInspectorKey(key: "title", xmlElement: element, inspectorElement: self)
        enabledKey = try AJRInspectorKey(key: "enabled", xmlElement: element, inspectorElement: self)
        negateKey = try AJRInspectorKey(key: "negate", xmlElement: element, inspectorElement: self)

        try super.buildView(from: element)
        
        valueKey?.addObserver { [weak self] in
            guard let self else { return }

            switch self.valueKey?.selectionType ?? .none {
            case .none:
                self.check.allowsMixedState = false
                self.check.state = .off
                self.check.isEnabled = false
            case .multiple:
                self.check.allowsMixedState = true
                self.check.state = .mixed
                self.check.isEnabled = self.enabledKey?.value ?? true
            case .single:
                let negate = self.shouldNegate
                self.check.allowsMixedState = false
                let value = self.valueKey?.value ?? false // Should always resolve...
                if negate {
                    self.check.state = value ? .off : .on
                } else {
                    self.check.state = value ? .on : .off
                }
                self.check.isEnabled = self.enabledKey?.value ?? true
            }
        }
        if let titleKey = titleKey {
            titleKey.addObserver { [weak self] in
                self?.check.title = self?.titleKey?.value ?? ""
            }
        } else {
            check.title = ""
        }
    }
    
    open override func canMergeWithElement(_ element: AJRInspectorElement) -> Bool {
        if element is AJRInspectorSliceBoolean {
            if self.labelKey == nil {
                return true
            }
        }
        return false
    }

    // MARK: - Conveniences
    
    open var shouldNegate : Bool {
        return negateKey?.value ?? false
    }
    
    // MARK: - Actions
    
    @IBAction func selectCheck(_ sender: NSButton?) -> Void {
        if let button = sender {
            if shouldNegate {
                valueKey?.value = button.state == .on ? false : true
            } else {
                valueKey?.value = button.state == .on ? true : false
            }
        }
    }
    
}
