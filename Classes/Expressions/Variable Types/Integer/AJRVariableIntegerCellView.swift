//
//  AJRVariableIntegerCellView.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/28/22.
//

import AJRFoundation

open class AJRVariableIntegerCellView : AJRVariableValueTableCellView, NSTextFieldDelegate {

    open override func variableDidChangeValue(_ variable: AJRVariable) {
        let value : Int = (try? Conversion.valueAsInteger(variable.value)) ?? 0
        textField?.isEditable = true
        textField?.isSelectable = true
        textField?.objectValue = value
    }

    open func controlTextDidEndEditing(_ obj: Notification) {
        if let variable = objectValue as? AJRVariable {
            let value = textField?.integerValue
            variable.value = value
        }
    }

}
