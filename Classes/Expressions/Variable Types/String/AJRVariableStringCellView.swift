//
//  AJRVariableStringCellView.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/28/22.
//

import Foundation

import AJRFoundation

open class AJRVariableStringCellView : AJRVariableValueTableCellView, NSTextFieldDelegate {

    open override func variableDidChangeValue(_ variable: AJRVariable) {
        textField?.isEditable = true
        textField?.isSelectable = true
        if let value = variable.value {
            textField?.stringValue = String(describing: value)
        } else {
            textField?.stringValue = ""
        }
    }

    open func controlTextDidEndEditing(_ obj: Notification) {
        if let variable = objectValue as? AJRVariable {
            variable.value = textField?.stringValue ?? ""
        }
    }

}
