//
//  AJRVariableTypeBezierPath.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/19/22.
//

import AJRFoundation

@objcMembers
open class AJRVariableTypeBezierPath : AJRVariableType {

    open override func createDefaultValue() -> Any? {
        return AJRBezierPath()
    }


}
