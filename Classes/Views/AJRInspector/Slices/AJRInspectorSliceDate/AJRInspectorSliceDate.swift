/*
 AJRInspectorSliceDate.swift
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
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

import Cocoa

class AJRInspectorSliceDate: AJRInspectorSliceField {
    
    open var valueKey : AJRInspectorKey<Date>?
    open var formatKey : AJRInspectorKey<String>?
    open var dateFormatter = DateFormatter() {
        didSet {
            field?.formatter = dateFormatter
        }
    }

    open override func tearDown() {
        valueKey?.stopObserving()
        formatKey?.stopObserving()
        super.tearDown()
    }

    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("value")
        keys.insert("format")
    }
    
    // MARK: - View
    
    open override func buildView(from element: XMLElement) throws {
        valueKey = try AJRInspectorKey(key: "value", xmlElement: element, inspectorElement: self)
        formatKey = try AJRInspectorKey(key: "format", xmlElement: element, inspectorElement: self)
        
        try super.buildView(from: element)
        
        weak var weakSelf = self
        valueKey?.addObserver {
            if let strongSelf = weakSelf {
                switch strongSelf.valueKey?.selectionType ?? .none {
                case .none:
                    strongSelf.field.stringValue = ""
                    strongSelf.field.placeholderString = AJRObjectInspectorViewController.translator["No Selection"]
                    strongSelf.field.isEditable = false
                case .multiple:
                    strongSelf.field.stringValue = ""
                    strongSelf.field.placeholderString = AJRObjectInspectorViewController.translator["Multiple Selection"]
                    strongSelf.field.isEditable = true
                case .single:
                    strongSelf.field.placeholderString = ""
                    if let value = strongSelf.valueKey?.value {
                        strongSelf.field.objectValue = value
                    } else {
                        strongSelf.field.stringValue = ""
                        if let nullPlaceholder = strongSelf.nullPlaceholder?.value {
                            strongSelf.field.placeholderString = nullPlaceholder
                        } else {
                            strongSelf.field.placeholderString = ""
                        }
                    }
                    strongSelf.field.isEditable = true
                }
            }
        }
        formatKey?.addObserver {
            if let strongSelf = weakSelf {
                let newFormatter = DateFormatter()
                newFormatter.dateFormat = strongSelf.formatKey?.value ?? "yyyy-MM-dd"
                strongSelf.dateFormatter = newFormatter
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction open override func takeValue(from sender: Any?) -> Void {
        if hasEdits, let sender = sender as? NSTextField {
            if let value = sender.objectValue as? Date {
                valueKey?.value = value
            } else if let value = sender.objectValue as? String {
                var dateValue : Date? = nil
                if let value = dateFormatter.date(from: value) {
                    dateValue = value
                } else if let value = try? AJRDateFromString(value, nil) {
                    dateValue = value
                }
                if let dateValue = dateValue {
                    valueKey?.value = dateValue
                } else {
                    valueKey?.value = nil
                }
            } else {
                valueKey?.value = nil
            }
        }
    }
    
}
