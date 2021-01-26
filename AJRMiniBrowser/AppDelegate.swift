//
//  AppDelegate.swift
//  AJRMiniBrowser
//
//  Created by AJ Raftis on 2/20/19.
//

import Cocoa

@NSApplicationMain
open class AppDelegate: NSObject, NSApplicationDelegate {
    
//    internal var applicationHasStarted = false

    open func applicationWillFinishLaunching(_ notification: Notification) {
        _ = DocumentController()
    }

    open func applicationDidFinishLaunching(_ aNotification: Notification) {
//        applicationHasStarted = true
    }

    open func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

//    open func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
//        // On startup, when asked to open an untitled file, open the last opened
//        // file instead
//        if !applicationHasStarted {
//            // Get the recent documents
//            if let documentController = NSDocumentController.shared as? DocumentController {
//                var windowToTakeFullScreen : NSWindow? = nil
//
//                for documentState in documentController.getPersistedDocumentStates() {
//                    let document = Document(state: documentState)
//                    document.makeWindowControllers()
//                    documentController.addDocument(document)
//
//                    if documentState.windowState.frame != NSRect.zero {
//                        document.windowController?.window?.setFrame(documentState.windowState.frame, display: false)
//                    }
//                    if documentState.windowState.isKey {
//                        document.windowController?.window?.makeKeyAndOrderFront(nil)
//                    } else {
//                        document.windowController?.window?.orderFront(nil)
//                    }
//                    if documentState.windowState.isMiniaturized {
//                        document.windowController?.window?.miniaturize(nil)
//                    }
//                    if documentState.windowState.isFullScreen {
//                        windowToTakeFullScreen = document.windowController?.window
//                    }
//                }
//
//                if let windowToTakeFullScreen = windowToTakeFullScreen {
//                    windowToTakeFullScreen.zoom(self)
//                }
//
//                return false
//            }
//        }
//
//        return true
//    }

}

