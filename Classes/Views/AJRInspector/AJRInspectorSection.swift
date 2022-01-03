/*
AJRInspectorSection.swift
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
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
open class AJRInspectorSection: AJRInspectorElement {
    
    // MARK: - Properties
    
    open var borderMarginTopKey : AJRInspectorKey<CGFloat>!
    open var borderMarginBottomKey : AJRInspectorKey<CGFloat>!
    open var borderColorTopKey : AJRInspectorKey<NSColor>?
    open var borderColorBottomKey : AJRInspectorKey<NSColor>?
    open var hiddenKey : AJRInspectorKey<Bool>?

    // MARK: - Creation
    
    public required init(element: XMLNode, parent: AJRInspectorElement?, viewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main, userInfo: [AnyHashable:Any]? = nil) throws {
        try super.init(element: element, parent: parent, viewController: viewController, bundle: bundle, userInfo: userInfo)
        if let element = element as? XMLElement {
            try buildView(from: element)
            if let children = element.children {
                for childNode in children {
                    if childNode.kind == .element, let childNode = childNode as? XMLElement {
                        add(child: try createChild(from: childNode))
                    }
                }
                if let childToAdd = self.childToAdd {
                    add(child: childToAdd)
                }
                for child in self.children {
                    child.didAddAllChildren()
                }
            }
        }
    }
    
    // MARK: - View
    
    internal var debugXColor : NSColor { return NSColor.purple }
    
    open var borderRenderer : AJRDrawingBlock? {
        if let parent = parent as? AJRInspectorSection, parent.childToAdd != nil {
            weak var weakSelf = self
            return { (context, bounds) in
                if let strongSelf = weakSelf {
                    if let color = strongSelf.borderColorTopKey?.value, !strongSelf.isFirstChild {
                        color.set()
                        NSBezierPath.strokeLine(from: NSPoint(x: bounds.minX + 7.0, y: bounds.maxY - 0.5), to: NSPoint(x: bounds.maxX - 7.0, y: bounds.maxY - 0.5));
                    }
                    if let color = strongSelf.borderColorBottomKey?.value {
                        color.set()
                        NSBezierPath.strokeLine(from: NSPoint(x: bounds.minX + 7.0, y: bounds.minY + 0.5), to: NSPoint(x: bounds.maxX - 7.0, y: bounds.minY + 0.5));
                    }
                }
            }
        }
        return nil
    }
    
    open var defaultTopMargin : CGFloat { return 6.0 }
    open var defaultBottomMargin : CGFloat { return 1.0 }
    open var topMargin : CGFloat { return borderMarginTopKey.value! }
    open var bottomMargin : CGFloat { return borderMarginBottomKey.value! }

    open func buildView(from element: XMLElement) throws -> Void {
        borderMarginTopKey = try AJRInspectorKey(key: "borderMarginTop", xmlElement: element, inspectorElement: self, defaultValue: defaultTopMargin)
        borderMarginBottomKey = try AJRInspectorKey(key: "borderMarginBottom", xmlElement: element, inspectorElement: self, defaultValue: defaultBottomMargin)
        borderColorTopKey = try AJRInspectorKey(key: "borderColorTop", xmlElement: element, inspectorElement: self, defaultValue: NSColor(named: .inspectorDividerColor, bundle:Bundle(for: Self.self)))
        borderColorBottomKey = try AJRInspectorKey(key: "borderColorBottom", xmlElement: element, inspectorElement: self)
        hiddenKey = try AJRInspectorKey(key: "hidden", xmlElement: element, inspectorElement: self, defaultValue: false)

        let view = NSStackView(frame: NSRect.zero)
        view.orientation = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 2.0
        //view.contentRenderer = borderRenderer
        self.view = view

        weak var weakSelf = self
        hiddenKey?.addObserver {
            if let strongSelf = weakSelf {
                if strongSelf.hiddenKey?.value ?? false {
                    strongSelf.view.isHidden = true
                } else {
                    strongSelf.view.isHidden = false
                }
            }
        }
    }
    
    // MARK: - Children
    
    open func verticalSpacing(fromView view: NSView) -> CGFloat {
        return 0.0
    }
    
    open func createChild(from element: XMLElement) throws -> AJRInspectorElement {
        switch element.name {
        case "slice":
            return try AJRInspectorSlice.slice(from: element, parent: self, viewController: viewController!)
        default:
            throw NSError(domain: AJRInspectorErrorDomain, message: "Invalid child in section: \(element)")
        }
    }
    
    private var childToAdd : AJRInspectorElement? = nil
    open override func add(child: AJRInspectorElement) {
        if let childToAdd = childToAdd {
            // Capture this, so that we can determine who our adjacent ancestor is, after we've added. This is easier than dealing with indexes into our children array.
            super.add(child: childToAdd)
            
            var childView : NSView? = nil
            if child !== childToAdd && child.canMergeWithElement(childToAdd) {
                childToAdd.mergeViewWithRightAdjacentSibling(child)
                childView = childToAdd.view
                super.add(child: child)
                self.childToAdd = nil
            } else {
                childView = childToAdd.view
                self.childToAdd = child
            }
            
            if let view = self.view as? NSStackView, let childView = childView {
                view.addView(childView, in: .top)
            }
        } else {
            self.childToAdd = child
        }
    }
    
}
