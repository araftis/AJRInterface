//
//  AJRVariableTypeBooleanCellView.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/26/22.
//

import Foundation

open class AJRVariableBooleanCellView : NSTableCellView {

    @IBOutlet var checkBox : NSButton!

    override open var objectValue: Any? {
        didSet {
            if let objectValue = objectValue as? AJRVariable,
               let value = objectValue.value as? Bool {
                    checkBox.state = value ? .on : .off
            }
        }
    }

    @IBAction func toggle(_ sender: NSButton) -> Void {
        if let objectValue = objectValue as? AJRVariable {
            objectValue.value = checkBox.state == .on
        }
    }

}
