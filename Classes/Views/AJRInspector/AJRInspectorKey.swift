
import Foundation
import Cocoa
import AJRFoundation

public protocol AJRInspectorValue : CustomStringConvertible {
    
    static func inspectorValue(from string: String) -> Any?
    static func inspectorValue(from value: NSValue) -> Any?

    var integerValue : Int { get }
    var doubleValue : Double { get }
    
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
            if (raw as AnyObject) === NSMultipleValuesMarker {
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
