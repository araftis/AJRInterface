/*
 DocumentController.swift
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
import AJRFoundation
import AJRInterface

@objcMembers
open class DocumentController: NSDocumentController {

    @IBAction public func newTabbedDocument(_ sender: Any?) -> Void {
        var documentCreated = false
        if let window = NSApp.keyWindow,
            let windowController = window.delegate as? WindowController {
            if let document = try? NSDocumentController.shared.makeUntitledDocument(ofType: NSDocumentController.shared.defaultType ?? "") {
                document.makeWindowControllers()
                if let window = document.windowControllers.first?.window {
                    windowController.window?.addTabbedWindow(window, ordered: .above)
                    window.makeKeyAndOrderFront(sender)
                }
                documentCreated = true
            }
        }
        if !documentCreated {
            // There were no existing documents, so just do the normal thing.
            NSDocumentController.shared.newDocument(sender)
        }
    }
    
    internal func importSafariBookmarks(from url: URL, associatedWindow window: NSWindow?) -> Void {
        do {
            let bookmarks = try AJRBookmark.bookmark(from: url)
            
            AJRBookmark.bookmarks = bookmarks
            
            for document in documents {
                if let document = document as? Document {
                    document.bookmark = bookmarks.favorites
                }
            }
        } catch {
            let alert = NSAlert(error: error)
            if let window = window {
                alert.beginSheetModal(for: window)
            } else {
                alert.runModal()
            }
        }
    }
    
    @IBAction public func importSafariBookmarks(_ sender: Any?) -> Void {
        let openPanel = NSOpenPanel()
        var window : NSWindow? = nil
        
        if let sender = sender as? Document {
            window = sender.windowController?.window
        }
        
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["plist"]
        
        let url = AJRHomeDirectoryURL().appendingPathComponent("Library").appendingPathComponent("Safari").appendingPathComponent("Bookmarks.html")
        print("\(url)")
        
        openPanel.directoryURL = url.deletingLastPathComponent()
        openPanel.representedURL = url
        if let window = window {
            openPanel.beginSheetModal(for: window) { (response) in
                if response == .OK, let url = openPanel.url {
                    self.importSafariBookmarks(from: url, associatedWindow: window)
                }
            }
        } else {
            openPanel.begin { (response) in
                if response == .OK, let url = openPanel.url {
                    self.importSafariBookmarks(from: url, associatedWindow: nil)
                }
            }
        }
    }
    
    @IBAction public func importHTMLBookmarks(_ sender: Any?) -> Void {
    }
    
    @IBAction public func exportHTMLBookmarks(_ sender: Any?) -> Void {
    }
    
    open override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case #selector(importSafariBookmarks(_:)):
            let image = NSWorkspace.shared.icon(forFile: "/Applications/Safari.app")
            image.size = NSSize(width: 16.0, height: 16.0)
            menuItem.image = image
        default:
            break
        }
        return super.validateMenuItem(menuItem)
    }
    
}
