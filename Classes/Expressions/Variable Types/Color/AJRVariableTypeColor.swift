//
//  AJRVariableTypeColor.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/19/22.
//

import AJRFoundation

@objcMembers
open class AJRVariableTypeColor : AJRVariableType, AJRVariableObjectCreation {

    // MARK: - Conversion

    open override func createDefaultValue() -> Any? {
        return NSColor.white
    }

    open override func value(from string: String) throws -> Any? {
        return AJRColorFromString(string)
    }

    open override func string(from value: Any) throws -> Any? {
        if let value = value as? AJRColor {
            return AJRStringFromColor(value)
        }
        throw ValueConversionError.invalidInputValue("\(type(of:self)) can only convert a value of type NSColor to a string.")
    }

    // This allows access to the various colors by refering to them, in expressions, as "colors.<name>".
    open var black : AJRColor { return AJRColor.black }
    open var darkGray : AJRColor { return AJRColor.darkGray }
    open var darkGrey : AJRColor { return AJRColor.darkGray }
    open var lightGray : AJRColor { return AJRColor.lightGray }
    open var lightGrey : AJRColor { return AJRColor.lightGray }
    open var white : AJRColor { return AJRColor.white }
    open var gray : AJRColor { return AJRColor.gray }
    open var grey : AJRColor { return AJRColor.gray }
    open var red : AJRColor { return AJRColor.red }
    open var green : AJRColor { return AJRColor.green }
    open var blue : AJRColor { return AJRColor.blue }
    open var cyan : AJRColor { return AJRColor.cyan }
    open var yellow : AJRColor { return AJRColor.yellow }
    open var magenta : AJRColor { return AJRColor.magenta }
    open var orange : AJRColor { return AJRColor.orange }
    open var purple : AJRColor { return AJRColor.purple }
    open var brown : AJRColor { return AJRColor.brown }
    open var clear : AJRColor { return AJRColor.clear }

}

open class AJRVariableColorCellView : AJRVariableValueTableCellView {

    @IBOutlet open var colorWell: NSColorWell!

    open override func variableDidChangeValue(_ variable: AJRVariable) {
        if let color = variable.value as? AJRColor {
            colorWell.color = color
        }
    }

    @IBAction open func takeColorFrom(_ sender: NSColorWell) -> Void {
        if let variable = objectValue as? AJRVariable {
            variable.value = colorWell.color
        }
    }

}
