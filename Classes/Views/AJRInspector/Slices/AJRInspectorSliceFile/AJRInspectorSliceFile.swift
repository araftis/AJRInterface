//
//  AJRInspectorSliceFile.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/12/21.
//

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
