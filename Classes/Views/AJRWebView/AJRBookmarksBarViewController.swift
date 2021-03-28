
import Cocoa

@objcMembers
open class AJRBookmarksBarViewController: NSTitlebarAccessoryViewController {

    public var bookmarksBar : AJRBookmarksBar {
        return self.view as! AJRBookmarksBar
    }
    
    public var target : AnyObject? {
        get {
            return bookmarksBar.target
        }
        set {
            bookmarksBar.target = newValue
        }
    }
    
    public var action : Selector? {
        get {
            return bookmarksBar.action
        }
        set {
            bookmarksBar.action = newValue
        }
    }
    
    public var bookmark : AJRBookmark? {
        didSet {
            bookmarksBar.bookmark = bookmark
        }
    }
    
    public init() {
        super.init(nibName: nil, bundle: Bundle(for: Self.self))
        self.fullScreenMinHeight = 24.0
        self.layoutAttribute = .bottom
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
