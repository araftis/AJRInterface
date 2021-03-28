
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

