//
//  AJRInspectorTests.swift
//  AJRInterfaceTests
//
//  Created by AJ Raftis on 3/17/19.
//

import XCTest
import AJRInterface

class AJRInspectorTests: XCTestCase, NSWindowDelegate {

    var window : NSWindow? = nil
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        _ = NSApplication.shared
    }

    func testCreation() {
        let inspector = AJRObjectInspectorViewController()
        inspector.name = "AJRTestInspector"
        inspector.bundle = Bundle(for: Self.self)
        
        inspector.loadView()
        if let content = inspector.inspectorContent {
            print("content: \(content)")
            
            window = NSWindow(contentRect: NSRect(x: 10, y: 10, width: 300, height: 200), styleMask: [.closable, .titled, .resizable], backing: .buffered, defer: false)
            window!.orderFront(self)
            window!.delegate = self
            window!.contentView = inspector.view

            NSApp.run()
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        NSApp.stop(nil)
    }

}
