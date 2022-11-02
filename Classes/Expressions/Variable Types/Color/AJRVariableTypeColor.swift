/*
 AJRVariableTypeColor.swift
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
