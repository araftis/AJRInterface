//
//  AJRVariableTypeColor.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/19/22.
//

import AJRFoundation

@objcMembers
open class AJRVariableTypeColor : AJRVariableType {

    open override func value(from string: String) throws -> Any? {
        return AJRColorFromString(string)
    }
    
}
