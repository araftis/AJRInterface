
import Cocoa

@objcMembers
open class AJRInspectorSliceTableScrollView: NSScrollView {

    // Our tables always grow to fit their content, so we don't want them to scroll. As such, this scroll view captures the scroll events and just passes the event to it's superview.
    open override func scrollWheel(with event: NSEvent) {
        self.superview?.scrollWheel(with: event)
    }
    
}

@objcMembers
open class AJRInspectorTableView : NSTableView {

}
