/*
 AJRGeometryInspectorConformance.swift
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
