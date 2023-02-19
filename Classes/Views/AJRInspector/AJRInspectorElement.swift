/*
 AJRInspectorElement.swift
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

    @IBOutlet open var view : NSView! {
        didSet {
            if view == nil {
                tearDown()
            }
        }
    }

    /**
     Called when the view is set to `nil`, which flags that the element should try to tear down any potentially circular references.

     When tearing down the element, two things are important. First, you should break connections to IB objects. Theoretically this shouldn't be necessary, but it seems like IB objects often get left around with strong references, so nilling out these objects, prevents that.

     Secondly, you should remove yourself from any notifications that're creating, especially during the build view method. You don't necessarily have to `nil` out your key properties, but you must at least call `stopObserving()` on them.

     After `tearDown()` has been called, your slice should no longer be useable, unless `buildView()` is called again. As such, you shouldn't completely year yourself down, but rather leave yourself in a state where you can be rebuilt.

     Note that you outlet to view will be `nil` at the time this method is called, and you should call `super.tearDown()`.
     */
    open func tearDown() -> Void {
        NotificationCenter.default.removeObserver(self)
    }
    
    public required init(element: XMLNode, parent: AJRInspectorElement?, viewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main, userInfo: [AnyHashable:Any]? = nil) throws {
        self.parent = parent
        self.viewController = viewController
        self.bundle = bundle
        self.userInfo = userInfo
    }
    
    deinit {
        print("\(type(of:self)).deinit")
        // We need to force this to collect immediately, rather than waiting.
        children.removeAll()
    }
    
    // MARK: - View Generation
    
    /**
     Checks to see if the receivers contents can be merged into `slice`'s content. The default implementation simply returns `false`.
     
     - parameter element: The slice to examine to see if the receive can merge into it.
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
        child.didAddToParent()
    }

    open var siblings : [AJRInspectorElement] {
        if let parent = parent {
            return parent.children
        }

        if let c = viewController?.inspectorViewController {
            return c.activeInspectors.compactMap { $0.inspectorContent }
        }

        return [self]
    }

    /**
     Returns `true` if the receiver is the first child of its parent.
     */
    open var isFirstChild : Bool {
//        if let parent = parent {
//            return parent.firstChild === self
//        }
//        return false
        return siblings.first === self
    }

    /**
     Returns `true` if the receiver is the last child of its parent.
     */
    open var isLastChild : Bool {
        return siblings.last === self
    }

    /**
     The default implementation does nothing, but this is called when your object is added to a parent. This potentially allows you to do some setup which could be dependent on your parent and at least some of your siblings. Note that when this is called siblings already added will be available to your object, but not sublings that will follow.
     */
    public func didAddToParent() -> Void {
    }

    /**
     For objects in a section (or group), this will be called when the group has initialized and added all children. This is potentially useful for doing some final initialization that might be depended on your element's position within its parent.
     */
    public func didAddAllChildren() -> Void {
    }

}
