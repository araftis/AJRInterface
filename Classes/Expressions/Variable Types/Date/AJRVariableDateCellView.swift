//
//  AJRVariableDateCellView.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/28/22.
//

import AJRFoundation

open class AJRVariableDateCellView : AJRVariableValueTableCellView, NSTextFieldDelegate {

    open override func variableDidChangeValue(_ variable: AJRVariable) {
        let value : Date = (try? Conversion.valueAsDate(variable.value)) ?? Date.now
        textField?.isEditable = true
        textField?.isSelectable = true
        textField?.objectValue = value
    }

    open func controlTextDidEndEditing(_ obj: Notification) {
        if let variable = objectValue as? AJRVariable {
            let value = textField?.dateValue
            variable.value = value
        }
    }

}
