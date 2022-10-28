//
//  NSTextField+Extensions.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/28/22.
//

import AJRFoundation

public extension NSTextField {

    var dateValue : Date? {
        return stringValue.dateValue
    }

}
