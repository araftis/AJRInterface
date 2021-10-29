//
//  NSView+Extensions.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/28/21.
//

import Foundation

public extension NSView {

    func enclosingView<T: NSView>(type viewType: T.Type) -> T? {
        var superview = self.superview

        while superview != nil && !(superview is T) {
            superview = superview!.superview
        }

        return superview as? T
    }

}
