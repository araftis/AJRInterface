//
//  AJRVariableTypeGradient.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/19/22.
//

import AJRFoundation

@objcMembers
open class AJRVariableTypeGradient : AJRVariableType {

    // MARK: - Conversion

    open override func createDefaultValue() -> Any? {
        return NSGradient(colors: [NSColor.black, NSColor.white])
    }

}
