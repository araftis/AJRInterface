//
//  AJRVariableTypePoint.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/19/22.
//

import AJRFoundation

@objcMembers
open class AJRVariableTypePoint : AJRVariableType {

    // MARK: - Conversion

    open override func createDefaultValue() -> Any? {
        return NSPoint.zero
    }

    open override func value(from string: String) throws -> Any? {
        return AJRPointFromString(string)
    }

    open override func string(from value: Any) throws -> Any? {
        if let value = value as? NSPoint {
            return AJRStringFromPoint(value)
        }
        throw ValueConversionError.invalidInputValue("Input value isn't a point: \(value)")
    }

}
