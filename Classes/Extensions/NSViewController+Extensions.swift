//
//  NSViewController+Extensions.swift
//  AJRInterface
//
//  Created by AJ Raftis on 6/8/19.
//

import Cocoa

public extension NSViewController {
    
    func descendantViewController<T: NSViewController>(of viewControllerClass: T.Type) -> T? {
        return self.ajr_descendantViewController(of: viewControllerClass) as? T
    }
    
}

