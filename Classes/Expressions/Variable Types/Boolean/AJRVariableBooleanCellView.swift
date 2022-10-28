//
//  AJRVariableTypeBooleanCellView.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/26/22.
//

import AJRFoundation

open class AJRVariableBooleanCellView : AJRVariableValueTableCellView {

    @IBOutlet var checkBox : NSButton!

    open override func variableDidChangeValue(_ variable: AJRVariable) {
        if let value = variable.value as? Bool {
            checkBox.state = value ? .on : .off
        }
    }

    @IBAction func toggle(_ sender: NSButton) -> Void {
        if let objectValue = objectValue as? AJRVariable {
            objectValue.value = checkBox.state == .on
        }
    }

}
