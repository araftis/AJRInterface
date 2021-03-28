
import Cocoa
import AJRInterface

public class WindowController : AJRCascadingWindowController, NSWindowDelegate {
 
    public override var desiredWindowSize: NSValue? {
        return NSValue(size: NSSize(width: 1224.0, height: 1000.0))
    }
    
//    public func windowDidMove(_ notification: Notification) {
//        (NSDocumentController.shared as? DocumentController)?.noteDocumentsNeedPersisting()
//    }
//    
//    public func windowDidResize(_ notification: Notification) {
//        (NSDocumentController.shared as? DocumentController)?.noteDocumentsNeedPersisting()
//    }
//    
//    public func windowDidMiniaturize(_ notification: Notification) {
//        (NSDocumentController.shared as? DocumentController)?.noteDocumentsNeedPersisting()
//    }
//
//    public func windowDidEnterFullScreen(_ notification: Notification) {
//        (NSDocumentController.shared as? DocumentController)?.noteDocumentsNeedPersisting()
//    }
//    
//    public func windowDidExitFullScreen(_ notification: Notification) {
//        (NSDocumentController.shared as? DocumentController)?.noteDocumentsNeedPersisting()
//    }
//    
//    public func windowWillClose(_ notification: Notification) {
//        (NSDocumentController.shared as? DocumentController)?.noteDocumentsNeedPersisting()
//    }

}
