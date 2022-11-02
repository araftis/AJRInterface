/*
 AJRInspectorSliceFile.swift
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

import Cocoa
import UniformTypeIdentifiers

@objcMembers
open class AJRInspectorSliceFile: AJRInspectorSliceField {
    
    open var urlKey : AJRInspectorKey<URL>?
    open var utisKey : AJRInspectorKey<[String]>?
    open var defaultsKey : AJRInspectorKey<String>?
    
    open var urlField : AJRButtonTextField {
        return self.baselineAnchorView as! AJRButtonTextField
    }
    
    open override var nibName: String? {
        return "AJRInspectorSliceFile"
    }
    
    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("url")
        keys.insert("utis")
        keys.insert("defaultsKey")
    }
    
    // MARK: - AJRInspectorSlice
    
    open override func buildView(from element: XMLElement) throws {
        urlKey = try AJRInspectorKey(key: "url", xmlElement: element, inspectorElement: self)
        utisKey = try AJRInspectorKey(key: "utis", xmlElement: element, inspectorElement: self)
        defaultsKey = try AJRInspectorKey(key: "defaultsKey", xmlElement: element, inspectorElement: self)

        try super.buildView(from: element)
        
        urlField.buttonTarget = self
        urlField.buttonAction = #selector(selectFile(_:))
        urlField.buttonPosition = .trailing
        urlField.setImages(withTemplate: AJRImages.image(named: "AJRFileButton", in: Bundle(for: AJRInspectorSliceFont.self)))
        
        weak var weakSelf = self
        urlKey?.addObserver {
            if let strongSelf = weakSelf {
                switch strongSelf.urlKey?.selectionType ?? .none {
                case .none:
                    strongSelf.urlField.stringValue = ""
                    strongSelf.urlField.placeholderString = strongSelf.translator["No Selection"]
                    strongSelf.urlField.isEnabled = false
                case .multiple:
                    strongSelf.urlField.stringValue = ""
                    strongSelf.urlField.placeholderString = strongSelf.translator["Multiple Selection"]
                    strongSelf.urlField.isEnabled = true
                case .single:
                    if let url = strongSelf.urlKey?.value {
                        if url.isFileURL {
                            strongSelf.urlField.stringValue = url.path
                        } else {
                            strongSelf.urlField.stringValue = url.absoluteString
                        }
                        strongSelf.urlField.placeholderString = ""
                    } else {
                        strongSelf.urlField.stringValue = ""
                        strongSelf.urlField.placeholderString = strongSelf.translator["No File"]
                    }
                    strongSelf.urlField.isEnabled = true
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction
    open func selectFile(_ sender: Any?) -> Void {
        let savePanel = NSSavePanel()
        if let url = urlKey?.value {
            savePanel.directoryURL = url.deletingLastPathComponent()
            savePanel.nameFieldStringValue = url.lastPathComponent
        } else if let key = defaultsKey?.value,
                  let url = UserDefaults.standard.url(forKey: key) {
            savePanel.directoryURL = url
        }
        if let types = utisKey?.value {
            savePanel.allowedContentTypes = types.compactMap({ string in
                return UTType(filenameExtension: string)
            })
        } else {
            savePanel.allowedContentTypes = []
        }
        savePanel.beginSheetModal(for: field.window!) { (response) in
            if response == .OK {
                self.urlKey?.value = savePanel.url
                if let key = self.defaultsKey?.value {
                    UserDefaults.standard.set(savePanel.directoryURL, forKey: key)
                }
            }
        }
    }

}
