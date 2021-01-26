//
//  AJRGeometryInspectorConformance.swift
//  AJRInterface
//
//  Created by AJ Raftis on 6/14/19.
//

import Foundation

extension CGSize : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        return CGSize(string: string)
    }
    
    public var description: String {
        return "{\(self.width), \(self.height)}"
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        return value.sizeValue
    }
    
}

extension CGPoint : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        return CGPoint(string: string)
    }
    
    public var description: String {
        return "{\(self.x), \(self.y)}"
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        return value.pointerValue
    }
    
}

extension CGRect : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        return CGRect(string: string)
    }
    
    public var description: String {
        return "{\(self.origin), \(self.size)}"
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        return value.rectValue
    }
    
}

extension AJRInset : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        return AJRInsetFromString(string)
    }
    
    public var description: String {
        return AJRStringFromInset(self)
    }

    public static func inspectorValue(from value: NSValue) -> Any? {
        let insets = value.edgeInsetsValue
        return AJRInset(top: insets.top, left: insets.left, bottom: insets.bottom, right: insets.right)
    }
    
}

extension NSEdgeInsets : AJRInspectorValue, AJRInspectorValueAsValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        let insets = AJRInsetFromString(string)
        return NSEdgeInsets(top: insets.top, left: insets.left, bottom: insets.bottom, right: insets.right)
    }
    
    public var description: String {
        return AJRStringFromInset(AJRInset(top: self.top, left: self.left, bottom: self.bottom, right: self.right))
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        return value.edgeInsetsValue
    }
    
    public func toValue() -> NSValue {
        return NSValue(edgeInsets: self)
    }

}
