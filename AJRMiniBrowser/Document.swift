/*
 Document.swift
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
import AJRInterface

open class Document: NSDocument {

    override init() {
        super.init()
    }
    
    override open class var autosavesInPlace: Bool {
        return true
    }
    
    public var bookmarksBarController : AJRBookmarksBarViewController?
    
    public var bookmark : AJRBookmark? {
        get {
            return bookmarksBarController?.bookmark
        }
        set {
            bookmarksBarController?.bookmark = newValue
        }
    }
    
    public var windowController : WindowController? {
        for windowController in self.windowControllers {
            if windowController is WindowController {
                return windowController as? WindowController
            }
        }
        return nil;
    }
    
    public var viewController : ViewController? {
        if let windowController = windowController {
            return windowController.contentViewController as? ViewController
        }
        return nil
    }

    override open func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)
        
        bookmarksBarController = AJRBookmarksBarViewController()
        bookmarksBarController?.target = self
        bookmarksBarController?.action = #selector(goToBookmark(_:))
        if let bookmarks = AJRBookmark.bookmarks {
            bookmarksBarController?.bookmark = bookmarks.favorites
        }
        windowController.window?.addTitlebarAccessoryViewController(bookmarksBarController!)
    }
    
    override open func write(to url: URL, ofType typeName: String) throws {
        // We don't actually have any "document"60.
    }
    
    override open func read(from url: URL, ofType typeName: String) throws {
        // We don't actually have any "document".
    }

    open override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        viewController?.webView.encodeRestorableState(with: coder)
    }
    
    open override func restoreState(with coder: NSCoder) {
        super.restoreState(with: coder)
        viewController?.webView.restoreState(with: coder, andNavigate: true)
    }
    
    @IBAction public func goToBookmark(_ sender: Any?) -> Void {
        if sender is NSMenuItem {
            viewController?.takeURLFrom(sender)
        } else if let bookmarksBar = sender as? AJRBookmarksBar {
            if let bookmark = bookmarksBar.selectedBookmark,
                let url = bookmark.url,
                url.absoluteString == "app://import/safari" {
                (NSDocumentController.shared as? DocumentController)?.importSafariBookmarks(self)
            } else {
                viewController?.takeURLFrom(sender)
            }
        }
    }
    
    open override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(AJRGoToBookmarkProtocol.goToBookmark(_:)) {
            if let url = menuItem.representedObject as? URL {
                menuItem.image = AJRWebView.favoriteIcon(for: url) ?? AJRWebView.defaultFavoriteIcon
            }
        }
        return true
    }

}

