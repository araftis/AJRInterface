//
//  AJRInspectorKeyPath.swift
//  AJRInterface
//
//  Created by AJ Raftis on 4/9/19.
//

import Cocoa

@objcMembers
open class AJRInspectorKeyPath<T> : NSObject {
    
    open var key : String
    open var keyPath : String!
    open weak var inspectorElement : AJRInspectorElement?
    open var willChangeBlocks = [AJRInspectorKeyObserver]()
    open var didChangeBlocks = [AJRInspectorKeyObserver]()
    open var defaultValue : T?
    
    public init?(key: String, xmlElement: XMLElement, inspectorElement: AJRInspectorElement, defaultValue : T? = nil) throws {
        self.key = key
        self.defaultValue = defaultValue
        let keyPathString = xmlElement.attribute(forName: key + "KeyPath")?.stringValue
        
        if let keyPathString = keyPathString {
            keyPath = keyPathString
        } else if defaultValue == nil {
            return nil
        }
        
        self.inspectorElement = inspectorElement
        super.init()
    }
    
    deinit {
        if observing, let keyPath = keyPath {
            inspectorElement?.viewController?.removeObserver(self, forKeyPath: keyPath)
        }
    }
    
    public var value : T? {
        get {
            if keyPath == nil {
                return defaultValue
            }
            return inspectorElement?.viewController?.value(forKeyPath: keyPath) as? T ?? defaultValue
        }
        set {
            if let keyPath = keyPath {
                inspectorElement?.viewController?.setValue(newValue, forKeyPath: keyPath)
            }
        }
    }
    
    public var selectionType : AJRValueSelectionType {
        if let keyPath = keyPath, let raw = inspectorElement?.viewController?.value(forKeyPath: keyPath) {
            if (raw as AnyObject) === NSMultipleValuesMarker {
                return .multiple
            }
            return NSIsControllerMarker(raw) ? .none : .single
        }
        return .none
    }
    
    // MARK: - Observers
    
    private var observing = false
    
    private func postAddObserver(_ block: @escaping AJRInspectorKeyObserver) {
        if !observing, let keyPath = keyPath {
            observing = true
            inspectorElement?.viewController?.addObserver(self, forKeyPath: keyPath, options: [.initial, .prior], context: nil)
        } else {
            block()
        }
    }
    
    open func addObserver(_ block: @escaping AJRInspectorKeyObserver) {
        didChangeBlocks.append(block)
        postAddObserver(block)
    }
    
    open func addWillChangeObserver(_ block: @escaping AJRInspectorKeyObserver) {
        willChangeBlocks.append(block)
        postAddObserver(block)
    }
    
    open func notifyDidChangeObservers() -> Void {
        for observer in didChangeBlocks {
            observer()
        }
    }
    
    open func notifyWillChangeObservers() -> Void {
        for observer in willChangeBlocks {
            observer()
        }
    }
    
    // MARK: - Key/Value Observing
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == self.keyPath {
            if let isPrior = change?[.notificationIsPriorKey] as? Bool, isPrior {
                notifyWillChangeObservers()
            } else {
                notifyDidChangeObservers()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - NSObject
    
    open override var description: String {
        return "<" + descriptionPrefix + ": \(key)>"
    }
    
}

