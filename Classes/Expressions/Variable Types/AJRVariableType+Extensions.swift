//
//  AJRVariableType+Extensions.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/26/22.
//

import Foundation

public extension NSUserInterfaceItemIdentifier {
    static let defaultEditor = NSUserInterfaceItemIdentifier("defaultEditor")
}

public extension AJRVariableType {

    var editorIdentifier : NSUserInterfaceItemIdentifier {
        return NSUserInterfaceItemIdentifier("\(name)Editor")
    }

    func loadNib(named name: String, bundle: Bundle?) throws -> NSNib? {
        var nib : NSNib? = nil
        try NSObject.catchException {
            nib = NSNib(nibNamed: name, bundle: bundle)
        }
        return nib
    }

    var editorNib : NSNib {
        // Try to load the nib from the variable type's own bundle.
        if let nib = try? loadNib(named: AJRStringFromClassSansModule(Self.self), bundle: Bundle(for: Self.self)) {
            return nib
        }
        // If that doesn't work, try loading it from AJRInterface. This is a good bet, because we have to extend the variable types defined in AJRFoundation in AJRInterface. Other, custom types should work with the above.
        if let nib = try? loadNib(named: AJRStringFromClassSansModule(Self.self), bundle: Bundle(identifier: "com.ajr.framework.AJRInterface")) {
            return nib
        }
        // If all else failed, just return a "default" as a place holder.
        return NSNib(nibNamed: "AJRVariableType", bundle: Bundle(identifier: "com.ajr.framework.AJRInterface"))!
    }

    func editorViewIdentifer(for tableView: NSTableView) -> NSUserInterfaceItemIdentifier {
        let identifier = editorIdentifier
        if tableView.registeredNibsByIdentifier?[identifier] == nil {
            tableView.register(editorNib, forIdentifier: identifier)
        }
        return identifier
    }

}
