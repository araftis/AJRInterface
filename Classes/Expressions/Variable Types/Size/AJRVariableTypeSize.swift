//
//  AJRVariableTypeSize.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/19/22.
//

import AJRFoundation

@objcMembers
open class AJRVariableTypeSize : AJRVariableType {

    // MARK: - Conversion

    open override func createDefaultValue() -> Any? {
        return NSSize.zero
    }

    open override func value(from string: String) throws -> Any? {
        return AJRSizeFromString(string)
    }

    open override func string(from value: Any) throws -> Any? {
        if let value = value as? NSSize {
            return AJRStringFromSize(value)
        }
        throw ValueConversionError.invalidInputValue("Input value isn't a size: \(value)")
    }

}
