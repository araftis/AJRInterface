
import Cocoa

public extension NSViewController {
    
    func descendantViewController<T: NSViewController>(of viewControllerClass: T.Type) -> T? {
        return self.ajr_descendantViewController(of: viewControllerClass) as? T
    }
    
}

