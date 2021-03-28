
import AppKit

public extension NSOutlineView {
    
    func view<T:NSView>(for item: Any, column: Int) -> T? {
        return view(forItem: item, column: column) as? T
    }
    
}
