/*
 AJRInspectorContent.swift
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
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

public let AJRInspectorErrorDomain = "AJRInspectorErrorDomain";

public typealias AJRInspectorXMLReadCallback = (_ url: URL) -> Void

@objcMembers
open class AJRInspectorContent: AJRInspectorElement {

    // MARK: - Properties
    
    private var xmlReadCallback : AJRInspectorXMLReadCallback? {
        return userInfo?["xmlReadCallbackKey"] as? AJRInspectorXMLReadCallback
    }
    
    private var _url : URL?
    
    // MARK: - Creation

    public init?(url: URL, inspectorViewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main, xmlReadCallback: AJRInspectorXMLReadCallback? = nil) throws {
        let document = try XMLDocument(contentsOf: url, options: [])
        var userInfo : [AnyHashable:Any]? = nil
        if let xmlReadCallback = xmlReadCallback {
            userInfo = ["xmlReadCallbackKey":xmlReadCallback]
        }
        _url = url
        try super.init(element: document, parent: nil, viewController: inspectorViewController, bundle: bundle, userInfo: userInfo)
        try completeInit(document: document)
        self.xmlReadCallback?(url)
    }
    
    public required init(element: XMLNode, parent: AJRInspectorElement?, viewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main, userInfo: [AnyHashable:Any]? = nil) throws {
        try super.init(element: element, parent: parent, viewController: viewController, bundle: bundle, userInfo: userInfo)
        try completeInit(document: element)
    }
    
    open func completeInit(document: XMLNode) throws -> Void {
        try resolveIncludes(in: document)
        
        if viewController?.debugFrames ?? false {
            let view = AJRFlippedXView(frame: NSRect(x: 0, y: 0, width: viewController?.minWidth ?? AJRInspectorViewController.defaultMinWidth, height: 0))
            view.color = NSColor.red
            view.clear = true
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view = view
        } else {
            let view = AJRFlippedView(frame: NSRect(x: 0, y: 0, width: viewController?.minWidth ?? AJRInspectorViewController.defaultMinWidth, height: 0))
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view = view
        }

        var possibleChildren : [XMLNode]? = nil
        if let documentChildren = document.children,
            let firstChild = documentChildren.first,
            firstChild.name == "inspector",
            let children = firstChild.children {
            possibleChildren = children
        }
        
        if possibleChildren == nil {
            possibleChildren = document.children
        }
        
        if let children = possibleChildren {
            for childNode in children {
                if let childNode = childNode as? XMLElement {
                    if childNode.name == "group" {
                        add(child: try AJRInspectorGroup(element: childNode, parent: self, viewController: viewController!))
                    } else if childNode.name == "section" {
                        add(child: try AJRInspectorSection(element: childNode, parent: self, viewController: viewController!))
                    } else if childNode.name == "slice" {
                        add(child: try AJRInspectorSlice.slice(from: childNode, parent: self, viewController: viewController!))
                    } else {
                        throw NSError(domain: AJRInspectorErrorDomain, message: "All top level inspector elements must be \"group\", \"section\", or \"sliver\" elements")
                    }
                } else if childNode.kind == .comment {
                    // Just ignore comments.
                } else {
                    throw NSError(domain: AJRInspectorErrorDomain, message: "All top level inspector elements must be XML elements.")
                }
            }
        }
        if let childToAdd = self.childToAdd {
            add(child: childToAdd)
        }
        if let view = self.view, let lastChildView = lastChild?.view {
            view.addConstraints([
                lastChildView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
                ])
        }
    }
    
    open override var url : URL? {
        return _url
    }
    
    // MARK: - Children
    
    private var childToAdd : AJRInspectorElement? = nil
    open override func add(child: AJRInspectorElement) {
        if let childToAdd = childToAdd {
            // Capture this, so that we can determine who our adjacent ancestor is, after we've added. This is easier than dealing with indexes into our children array.
            let lastView = view.subviews.last
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
            
            if let view = self.view, let childView = childView {
                view.addSubview(childView)
                view.addConstraints([
                    childView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
                    childView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
                    ])
                if let lastView = lastView {
                    view.addConstraints([
                        childView.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 0.0),
                        ])
                } else {
                    view.addConstraints([
                        childView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
                        ])
                }
            }
        } else {
            self.childToAdd = child
        }
    }
    
    // MARK: - Includes
    
    open class func loadXMLDocument(for file: String?, bundleID: String?, callback: AJRInspectorXMLReadCallback? = nil) throws -> XMLDocument {
        var bundle : Bundle? = nil
        
        if let bundleID = bundleID {
            if let foundBundle = Bundle(identifier: bundleID) {
                bundle = foundBundle
            } else {
                throw NSError(domain: AJRInspectorErrorDomain, message: "No bundle with identifier: \(bundleID)")
            }
        }
        
        return try loadXMLDocument(for: file, bundle: bundle, callback: callback)
    }
    
    open class func loadXMLDocument(for file: String?, bundle bundleIn: Bundle?, callback: AJRInspectorXMLReadCallback? = nil) throws -> XMLDocument {
        let bundle = bundleIn ?? Bundle(for: self)
        
        if let file = file {
            if let xmlURL = bundle.url(forResource: file, withExtension: "inspector") {
                let document = try XMLDocument(contentsOf: xmlURL, options: [])
                callback?(xmlURL)
                return document
            } else {
                throw NSError(domain: AJRInspectorErrorDomain, message: "Failed to find inspector include with name: \(file).inspector.")
            }
        } else {
            throw NSError(domain: AJRInspectorErrorDomain, message: "Include elements must define a \"file\" attribute.")
        }
    }
    
    open func resolveIncludes(in node: XMLNode) throws -> Void {
        var children = node.children ?? []
        var index = 0
        while index < children.count {
            let child = children[index]
            if child.name == "include", let child = child as? XMLElement {
                let file = child.attribute(forName: "file")?.stringValue
                let bundleID = child.attribute(forName: "bundle")?.stringValue
                let bundle : Bundle
                
                if let bundleID = bundleID {
                    if let foundBundle = Bundle(identifier: bundleID) {
                        bundle = foundBundle
                    } else {
                        throw NSError(domain: AJRInspectorErrorDomain, message: "No bundle with identifier: \(bundleID)")
                    }
                } else {
                    bundle = self.bundle
                }
                
                let document = try AJRInspectorContent.loadXMLDocument(for: file, bundle: bundle, callback: xmlReadCallback)
                var includeNode : XMLNode? = nil
                for documentChild in document.children ?? [] {
                    if documentChild.name == "inspector-include" {
                        if includeNode == nil {
                            includeNode = documentChild
                        } else {
                            throw NSError(domain: AJRInspectorErrorDomain, message: "The included inspector document must have one and only one \"inspector-include\" node at the top level.")
                        }
                    }
                }
                if let includeNode = includeNode as? XMLElement, let parent = child.parent as? XMLElement {
                    parent.removeChild(at: index)
                    if let includeChildren = includeNode.children {
                        for childToRemove in includeChildren {
                            includeNode.removeChild(childToRemove)
                        }
                        parent.insertChildren(includeChildren, at: index)
                    }
                    children = parent.children!
                    
                    // We continue, because we don't want to increment index, since we want to now process the child(ren) we just added.
                    continue
                } else {
                    throw NSError(domain: AJRInspectorErrorDomain, message: "The included inspector document must have one \"inspector-include\" node at the top level.")
                }
            } else {
                try resolveIncludes(in: child)
            }
            index += 1
        }
    }
    
}
