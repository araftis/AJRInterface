/*
 AJRInspectorKey.swift
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

import Foundation
import Cocoa
import AJRFoundation

public protocol AJRInspectorValue : CustomStringConvertible {
    
    static func inspectorValue(from string: String) -> Any?
    static func inspectorValue(from value: NSValue) -> Any?

    var integerValue : Int { get }
    var doubleValue : Double { get }
    
}

public protocol AJRInspectedRawEnum {

    var rawValueForKVO : Int { get }

}

public protocol AJRInspectorValueAsValue {
    
    func toValue() -> NSValue
    
}

public typealias AJRInspectorKeyObserver = () -> Void

@objcMembers
open class AJRInspectorKey<T: AJRInspectorValue> : NSObject {

    open var key : String
    open var keyPath : String?
    open var staticValue : T?
    open var defaultValue : T?
    open var inspectorElement : AJRInspectorElement?
    open var changeBlocks = [AJRInspectorKeyObserver]()
    
    public init?(key: String, xmlElement: XMLElement, inspectorElement: AJRInspectorElement, defaultValue: T? = nil) throws {
        self.key = key
        let valueString = xmlElement.attribute(forName: key)?.stringValue
        let keyPathString = xmlElement.attribute(forName: key + "KeyPath")?.stringValue

        if valueString != nil && keyPathString != nil {
            throw NSError(domain: AJRInspectorErrorDomain, message: "You can specify \"\(key)\" or \"\(key + "KeyPath")\", but not both: \(xmlElement)")
        }
        
        if let valueString = valueString {
            staticValue = T.inspectorValue(from: valueString) as? T
        } else if let keyPathString = keyPathString {
            keyPath = keyPathString
        } else if defaultValue == nil {
            // We had to value or keyPath, so we're not needed.
            return nil
        }
        self.inspectorElement = inspectorElement
        self.defaultValue = defaultValue
        super.init()
    }
    
    deinit {
        print("releasing: \(self)")
        if observing, let keyPath = keyPath {
            inspectorElement?.viewController?.removeObserver(self, forKeyPath: keyPath)
        }
    }
    
    public var value : T? {
        get {
            return value(from: inspectorElement?.viewController)
        }
        set {
            setValue(newValue, on: inspectorElement?.viewController)
        }
    }
    
    open func value(from object: AnyObject?) -> T? {
        if let value = staticValue {
            return value
        }
        if let keyPath = keyPath {
            let rawValue = object?.value(forKeyPath: keyPath)
            if let raw = rawValue as? T {
                return raw
            } else if let raw = rawValue as? String {
                return T.inspectorValue(from: raw) as? T
            } else if let raw = rawValue as? NSValue {
                return T.inspectorValue(from: raw) as? T
            } else if let raw = rawValue {
                return T.inspectorValue(from: String(describing: raw)) as? T
            }
            return defaultValue
        }
        return defaultValue
    }
    
    open func setValue(_ value: T?, on object: AnyObject?) {
        if let keyPath = keyPath {
            if let value = value as? AJRInspectorValueAsValue {
                object?.setValue(value.toValue(), forKeyPath: keyPath)
            } else {
                object?.setValue(value, forKeyPath: keyPath)
            }
        }
    }

    public var selectionType : AJRValueSelectionType {
        if let keyPath = keyPath {
            var raw : Any? = nil
            do {
                try NSObject.catchException({
                raw = self.inspectorElement?.viewController?.value(forKeyPath: keyPath)
                })
            } catch let error as NSError {
                AJRLog.warning("Error while accessing selection: \(error.localizedDescription)")
            }
            if (raw as AnyObject) === NSBindingSelectionMarker.multipleValues {
                return .multiple
            }
            return NSIsControllerMarker(raw) ? .none : .single
        }
        return .single // Because we're resolving against a "constant", or 1 object.
    }
    
    // MARK: - Observers
    
    private var observing = false
    
    open func addObserver(_ block: @escaping AJRInspectorKeyObserver) {
        changeBlocks.append(block)
        if !observing, let keyPath = keyPath {
            observing = true
            inspectorElement?.viewController?.addObserver(self, forKeyPath: keyPath, options: [.initial], context: nil)
        } else {
            block()
        }
    }
    
    open func notifyObservers() -> Void {
        for observer in changeBlocks {
            observer()
        }
    }
    
    // MARK: - Key/Value Observing
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == self.keyPath {
            notifyObservers()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - NSObject
    
    open override var description: String {
        return "<" + descriptionPrefix + ": \(key)>"
    }
    
}

public extension AJRInspectorValue {
    
    var doubleValue : Double {
        return Double(self.description) ?? 0.0
    }
    
    var integerValue : Int {
        return Int(self.description) ?? 0
    }
    
}

extension String : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        return string
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        return value.description
    }

}

extension Int : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        return Int(string)
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        return nil
    }

}

extension Double : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        return Double(string)
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        return nil
    }
    
}

extension CGFloat : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        return CGFloat(Double(string) ?? 0.0)
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        return nil
    }
    
}

extension Selector : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        return NSSelectorFromString(string)
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        return nil
    }
    
}

extension Bool : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        if string != "true" && string != "false" {
            AJRLog.error("Boolean values in XML should be \"true\" or \"false\".")
        }
        return Bool(string)
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        if let value = value as? NSNumber {
            return value.boolValue
        }
        return nil
    }

}

extension Date : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        return nil; //Date(string)
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        return nil
    }
    
}

extension NSTextAlignment : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .left:
            return "left"
        case .center:
            return "center"
        case .justified:
            return "justified"
        case .natural:
            return "natural"
        case .right:
            return "right"
        @unknown default:
            return String(describing: self)
        }
    }
    
}

extension NSTextAlignment : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        switch string {
        case "left":
            return NSTextAlignment.left
        case "right":
            return NSTextAlignment.right
        case "center":
            return NSTextAlignment.center
        case "justified":
            return NSTextAlignment.justified
        case "natural":
            return NSTextAlignment.natural
        default:
            return nil
        }
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        if let value = value as? NSNumber {
            return NSTextAlignment(rawValue: value.intValue)
        }
        return nil
    }

}

extension NSFont : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        return AJRFontFromString(string)
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        return nil
    }
    
}

extension Bundle : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        return Bundle(identifier: string)
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        return nil
    }
    
}

extension NSAttributedString : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        if string.hasPrefix("<") {
            let data = string.data(using: .utf8)
            return NSAttributedString(html: data!, documentAttributes: nil)
        } else {
            return NSAttributedString(string: string)
        }
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        return nil
    }
    
}

extension URL : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        if let url = URL(string: string) {
            return url
        // Let's see if it might be a file path
        } else if string.hasPrefix("/") {
            return URL(fileURLWithPath: string)
        }
        return nil
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        return nil
    }
    
}

extension Array : AJRInspectorValue where Element == String {
    
    public static func inspectorValue(from string: String) -> Any? {
        return string.components(separatedBy:",")
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        nil
    }
    
}

extension Unit : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        return Unit(forIdentifier: string);
    }

    public static func inspectorValue(from value: NSValue) -> Any? {
        return nil
    }

}
