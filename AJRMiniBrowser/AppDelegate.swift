/*
 AppDelegate.swift
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

