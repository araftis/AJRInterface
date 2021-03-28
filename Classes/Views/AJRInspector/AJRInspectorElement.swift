
import Cocoa

@objcMembers
open class AJRInspectorElement: NSObject {
    
    open var userInfo : [AnyHashable:Any]?
    open weak var parent : AJRInspectorElement?
    open var children = [AJRInspectorElement]()
    open var canBeLabeled : Bool { return false }
    open var bundle : Bundle
    
    open var firstKeyView : NSView {
        if children.count > 0 {
            return children.first!.firstKeyView
        }
        return view
    }
    
    open var lastKeyView : NSView {
        if children.count > 0 {
            return children.last!.lastKeyView
        }
        return view
    }
    
    open var rootElement : AJRInspectorElement {
        var parent = self
        while parent.parent != nil {
            parent = parent.parent!
        }
        return parent
    }
    
    open var url : URL? {
        return nil
    }
    
    open func populateKnownKeys(_ keys: inout Set<String>) -> Void {
    }
    
    open lazy var knownKeys : Set<String> = {
        var keys = Set<String>()
        populateKnownKeys(&keys)
        return keys
    }()
    
    open weak var viewController : AJRObjectInspectorViewController?
    
    @IBOutlet open var view : NSView!
    
    public required init(element: XMLNode, parent: AJRInspectorElement?, viewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main, userInfo: [AnyHashable:Any]? = nil) throws {
        self.parent = parent
        self.viewController = viewController
        self.bundle = bundle
        self.userInfo = userInfo
    }
    
    // MARK: - View Generation
    
    /**
     Checks to see if the receivers contents can be merged into `slice`'s content. The default implementation simply returns `false`.
     
     - parameter slice: The slice to examine to see if the receive can merge into it.
     */
    open func canMergeWithElement(_ element: AJRInspectorElement) -> Bool {
        return false
    }
    
    open func mergeViewWithRightAdjacentSibling(_ sibling: AJRInspectorElement) -> Void {
    }
    
    // MARK: - Children
    
    public var numberOfChildren : Int { return children.count }
    
    public func child(at index: Int) -> AJRInspectorElement {
        return children[index]
    }
    
    public var firstChild : AJRInspectorElement? {
        return children.first
    }
    
    public var lastChild : AJRInspectorElement? {
        return children.last
    }
    
    public func add(child: AJRInspectorElement) -> Void {
        children.append(child)
        if children.count >= 2 {
            let secondToLast = children[children.count - 2]
            let last = children[children.count - 1]

            //print("chaining \(secondToLast) to \(last)")

            secondToLast.lastKeyView.nextKeyView = last.firstKeyView
        }
    }
    
    public var isFirstChild : Bool {
        if let parent = self.parent {
            return parent.firstChild === self
        }
        return false
    }
    
}
