/*
 AJRInspectorSliceButton.swift
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

class AJRInspectorSliceButton: AJRInspectorSlice {

    @IBOutlet open var button : NSButton!
    
    open var titleKey : AJRInspectorKey<String>?
    open var enabledKey : AJRInspectorKey<Bool>?
    open var actionKey : AJRInspectorKey<Selector>?
    open var targetKeyPath : String?
    
    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("action")
        keys.insert("title")
        keys.insert("enabled")
        keys.insert("target")
    }
    
    // MARK: - Generation
    
    open override func buildView(from element: XMLElement) throws {
        titleKey = try AJRInspectorKey(key: "title", xmlElement: element, inspectorElement: self)
        enabledKey = try AJRInspectorKey(key: "enabled", xmlElement: element, inspectorElement: self)
        actionKey = try AJRInspectorKey(key: "action", xmlElement: element, inspectorElement: self)
        targetKeyPath = element.attribute(forName: "targetKeyPath")?.stringValue

        try super.buildView(from: element)
        
        weak var weakSelf = self
        titleKey?.addObserver {
            weakSelf?.button.title = weakSelf?.titleKey?.value ?? ""
        }
        enabledKey?.addObserver {
            weakSelf?.button.isEnabled = weakSelf?.enabledKey?.value ?? true
        }
        actionKey?.addObserver {
            weakSelf?.button.action = weakSelf?.actionKey?.value
        }
        if let targetKeyPath = targetKeyPath {
            viewController?.addObserver(self, forKeyPath: targetKeyPath, options: [.initial], context: nil)
        } else {
            button.target = nil
        }
    }
    
    open override func canMergeWithElement(_ element: AJRInspectorElement) -> Bool {
        if element is AJRInspectorSliceButton {
            if self.labelKey == nil {
                return true
            }
        }
        return false
    }
    
    // MARK: - Key/Value Observing
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == targetKeyPath {
            button.target = viewController?.value(forKeyPath: targetKeyPath!) as AnyObject
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}
