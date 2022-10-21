//
//  AJRColorFunctions.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/20/22.
//

import Cocoa

@objcMembers
open class AJRColorFunction: AJRFunction {

    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
        if context.argumentCount < 1 {
            throw AJRFunctionError.invalidArgumentCount("color(...) must have at least one argument")
        }
        if let arguments = context.arguments {
            let first = arguments[0]
            AJRLog.info("arg: \(first)")
        }

        return NSNull()
    }

}
