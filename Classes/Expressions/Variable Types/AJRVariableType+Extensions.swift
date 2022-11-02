/*
 AJRVariableType+Extensions.swift
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
            let nib = editorNib
            AJRLog.debug("\(identifier.rawValue): \(nib)")
            tableView.register(nib, forIdentifier: identifier)
        }
        return identifier
    }

}
