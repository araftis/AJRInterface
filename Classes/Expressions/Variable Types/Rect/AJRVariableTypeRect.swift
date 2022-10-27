//
//  AJRVariableTypeRect.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/19/22.
//

import AJRFoundation

@objcMembers
open class AJRVariableTypeRect : AJRVariableType {

    // MARK: - Conversion

    open override func createDefaultValue() -> Any? {
        return NSRect.zero
    }

    open override func value(from string: String) throws -> Any? {
        return AJRRectFromString(string)
    }

    open override func string(from value: Any) throws -> Any? {
        if let value = value as? NSRect {
            return AJRStringFromRect(value)
        }
        throw ValueConversionError.invalidInputValue("Input value isn't a rect: \(value)")
    }

}
