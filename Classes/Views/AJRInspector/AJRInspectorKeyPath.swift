/*
AJRInspectorKeyPath.swift
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

@objcMembers
open class AJRInspectorKeyPath<T> : NSObject {
    
    open var key : String
    open var keyPath : String!
    open weak var inspectorElement : AJRInspectorElement?
    open var willChangeBlocks = [AJRInspectorKeyObserver]()
    open var didChangeBlocks = [AJRInspectorKeyObserver]()
    open var defaultValue : T?
    open var pauseCount : Int = 0
    
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
            if (raw as? NSBindingSelectionMarker) == .multipleValues {
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
        if pauseCount == 0 {
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
    }
    
    // MARK: - Pause
    
    open func pause() -> Void {
        pauseCount += 1
    }
    
    open func resume() -> Void {
        if pauseCount > 0 {
            pauseCount -= 1
        } else {
            AJRLog.warning("Trying to resume \(self) without a matched pause().")
        }
    }
    
    // MARK: - NSObject
    
    open override var description: String {
        return "<" + descriptionPrefix + ": \(key)>"
    }
    
}

