//
//  AJRInspectorSliceButton.swift
//  AJRInterface
//
//  Created by AJ Raftis on 3/20/19.
//

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
