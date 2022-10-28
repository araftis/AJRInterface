//
//  AJRVariableFloatingPointCellView.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/28/22.
//

import Foundation

import AJRFoundation

open class AJRVariableFloatingPointCellView : AJRVariableValueTableCellView, NSTextFieldDelegate {

    open override func variableDidChangeValue(_ variable: AJRVariable) {
        let value : Double = (try? Conversion.valueAsFloatingPoint(variable.value)) ?? 0.0
        textField?.isEditable = true
        textField?.isSelectable = true
        textField?.objectValue = value
    }

    open func controlTextDidEndEditing(_ obj: Notification) {
        if let variable = objectValue as? AJRVariable {
            let value = textField?.floatValue
            variable.value = value
        }
    }

}
