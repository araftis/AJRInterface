//
//  AJRVariableTypeFont.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/19/22.
//

import AJRFoundation

@objcMembers
open class AJRVariableTypeFont : AJRVariableType {

    // MARK: - Conversion

    open override func createDefaultValue() -> Any? {
        return NSFont.userFont(ofSize: NSFont.systemFontSize(for: .regular))
    }

    open override func value(from string: String) throws -> Any? {
        return AJRFontFromString(string)
    }

    open override func string(from value: Any) throws -> Any? {
        if let value = value as? NSFont {
            return AJRStringFromFont(value)
        }
        throw ValueConversionError.invalidInputValue("Input value isn't a font: \(value)")
    }

}
