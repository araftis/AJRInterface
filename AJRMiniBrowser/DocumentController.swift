//
//  DocumentController.swift
//  AJRMiniBrowser
//
//  Created by AJ Raftis on 2/21/19.
//

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
