
import Cocoa

/**
 Allows you to set a "forwarding" view for certain events common to searching. Basically, the search field becomes the first responder, which means it'll swallow events like performFindPanelAction:, but that's probably not what you want. You want the view that's being searched to still receive those actions.
 */
@objcMembers
open class AJRForwardingSearchField: NSSearchField {

    open var receivingView : NSView?
    
    open var escapeTarget : AnyObject?
    open var escapeAction : Selector?
    
    open func performFindPanelAction(_ sender: Any?) {
        print("\(#function)")
    }
    
}
