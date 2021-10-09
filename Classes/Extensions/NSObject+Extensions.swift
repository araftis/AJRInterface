/*
NSObject+Extensions.swift
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be
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

import AppKit

@objc
public enum AJRBindingSelectionType : Int {

    case unknown
    case none
    case single
    case multiple

}

@objc
public extension NSObject {

    @objc(selectionTypeForBinding:)
    func selectionType(for binding: NSBindingName) -> AJRBindingSelectionType {
        var type = AJRBindingSelectionType.unknown

        if let info = infoForBinding(binding),
            let object = info[.observedObject],
            let keyPath = info[.observedKeyPath] as? String {
            let raw = (object as AnyObject).value(forKeyPath: keyPath)
            if (raw as AnyObject) === NSMultipleValuesMarker {
                type = .multiple
            } else if (raw as AnyObject) === NSNoSelectionMarker {
                type = .none
            } else {
                type = .single
            }
        }

        return type
    }

}