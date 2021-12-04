/*
AJRInspectorViewController.swift
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

public extension NSColor.Name {
    
    static var inspectorDividerColor = NSColor.Name("inspectorDividerColor")
    
}

public extension NSUserInterfaceItemIdentifier {
    
    static var defaultInspector = NSUserInterfaceItemIdentifier("DefaultInspector")

}

extension AJRInspectorIdentifier: CustomStringConvertible {
    
    public static var noInspector = AJRInspectorIdentifier("No Inspector")
    
    public var description: String {
        return rawValue
    }

}

private struct AJRInspectorExtension {
    
    var inspectorClass : AJRObjectInspectorViewController.Type
    var identifiers : [AJRInspectorIdentifier]
    var bundle : Bundle
    var xmlName : String?
    
}

internal struct AJRContentNode: Equatable {

    var content: [AnyObject]
    var identifier: AJRInspectorContentIdentifier
    
    static func == (lhs: AJRContentNode, rhs: AJRContentNode) -> Bool {
        return lhs.identifier == rhs.identifier &&
            (lhs.content as AnyObject).isEqual(rhs.content as AnyObject)
    }
    
    internal func contains(content: [AnyObject], using identifier: AJRInspectorContentIdentifier) -> Bool {
        return self.identifier == identifier && (self.content as AnyObject).isEqual(content as AnyObject)
    }
    
}

@objcMembers
open class AJRInspectorViewController: NSViewController {
    
    @IBInspectable public var debugFrames = false

    public static var defaultMinWidth : CGFloat = 260.0
    
    @IBInspectable open var minWidth : CGFloat = defaultMinWidth
    
    @IBOutlet open var activeInspectorView : NSScrollView!
    @IBOutlet open var noSelectionView : NSView!
    @IBOutlet open var noInspectorView : NSView!
    @IBOutlet open var multipleSelectionView : NSView!

    @IBOutlet open var accessoryView : NSView?
    
    open var activeInspectors = [AJRObjectInspectorViewController]()
    
    // MARK: - Content
    
    open var arrayController = NSArrayController()
    open var content : [AnyObject] {
        get {
            return contentStack.last?.content ?? []
        }
    }
    
    internal var contentStack = [AJRContentNode]()

    open func push(content: [AnyObject], for identifier: AJRInspectorContentIdentifier = AJRInspectorContentIdentifier("any")) -> Void {
        if contentStack.last?.contains(content: content, using: identifier) ?? false {
            // The same content is being pushed, so we don't want to actually do any updating.
            return
        }
        if let index = contentStack.lastIndex(where: { (contentNode) -> Bool in
            return contentNode.identifier == identifier
        }) {
            while contentStack.count > index {
                contentStack.removeLast()
            }
        }
        contentStack.append(AJRContentNode(content: content, identifier: identifier))
        updateDisplay(withNewContent: content)
    }
    
    internal func pop(contentAt index: Int) -> Void {
        contentStack.remove(at: index)
        if let newContent = contentStack.last {
            updateDisplay(withNewContent: newContent.content)
        } else {
            updateDisplay(withNewContent: [])
        }
    }
    
    open func pop(content: [AnyObject], for identifier: AJRInspectorContentIdentifier) -> Void {
        let contentNode = AJRContentNode(content: content, identifier: identifier)
        if let index = contentStack.lastIndex(of: contentNode) {
            pop(contentAt: index)
        }
    }
    
    open func pop(contentFor identifier: AJRInspectorContentIdentifier) -> Void {
        if let index = contentStack.lastIndex(where: { (contentNode) -> Bool in
            return contentNode.identifier == identifier
        }) {
            pop(contentAt: index)
        }
    }
    
    // MARK: - Factory
    
    private static var classesForIdentifiers = [NSUserInterfaceItemIdentifier:AJRInspectorViewController.Type]()
    private static var inspectorViewControllers = [NSUserInterfaceItemIdentifier:AJRInspectorViewController]()
    
    open class var `default` : AJRInspectorViewController {
        return inspectorViewController(for: .defaultInspector)
    }
    
    open class func inspectorViewController(for identifier: NSUserInterfaceItemIdentifier) -> AJRInspectorViewController {
        var inspector = inspectorViewControllers[identifier]
        if inspector == nil {
            var inspectorClass = classesForIdentifiers[identifier]
            if inspectorClass == nil {
                inspectorClass = AJRInspectorViewController.self
            }
            inspector = inspectorClass!.init()
            inspectorViewControllers[identifier] = inspector
        }
        return inspector!
    }
    
    open class func register(class inspectorClass: AJRInspectorViewController.Type, for identifier: NSUserInterfaceItemIdentifier) -> Void {
        classesForIdentifiers[identifier] = inspectorClass
    }

    private static var inspectorExtensionsByIdentifier = [AJRInspectorIdentifier:AJRInspectorExtension]()
    
    open class func registerInspector(_ inspectorClass: AJRObjectInspectorViewController.Type, properties: [String:Any]) -> Void {
        let bundle = properties["bundle"] as? Bundle ?? Bundle.main
        let xmlName = properties["xml"] as? String

        if let rawIdentifier = properties["identifier"] as? String {
            let identifier = AJRInspectorIdentifier(rawIdentifier)
            let inspectorExtension = AJRInspectorExtension(inspectorClass: inspectorClass, identifiers: [identifier], bundle: bundle, xmlName: xmlName)
            inspectorExtensionsByIdentifier[identifier] = inspectorExtension
        } else {
            // You'd think we'd emit an error here, but if the identifier property is missing, that means that it wasn't in the XML, and the plug in manager will have already emitted a more useful message.
        }
    }

    // MARK: - Creation

    open class func createView(withLabel label: String) -> NSView {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let label = NSTextField(labelWithString: translator[label])
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular) + 8.0, weight: .semibold)
        label.textColor = NSColor.disabledControlTextColor
        view.addSubview(label)
        view.addConstraints([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        return view
    }
    
    private func completeInit() -> Void {
        noSelectionView = AJRInspectorViewController.createView(withLabel: "No Selection")
        noInspectorView = AJRInspectorViewController.createView(withLabel: "No Inspector")
        multipleSelectionView = AJRInspectorViewController.createView(withLabel: "Multiple Selection")
        activeInspectorView = NSScrollView()
        activeInspectorView.translatesAutoresizingMaskIntoConstraints = false
        activeInspectorView.borderType = .noBorder
        activeInspectorView.horizontalScroller = nil
        activeInspectorView.horizontalScrollElasticity = .none
        activeInspectorView.hasVerticalScroller = true
        activeInspectorView.scrollerStyle = .overlay
        activeInspectorView.drawsBackground = false
        activeInspectorView.backgroundColor = NSColor.clear
    }
    
    public required init() {
        super.init(nibName: "AJRInspectorViewController", bundle: Bundle(for: Self.self))
        completeInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        completeInit()
    }
    
    // MARK: - Utilities
    
    open var box : NSBox {
        return view as! NSBox
    }
    
    open func installAccessoryView(in view: NSView) -> Void {
        if let accessoryView = accessoryView,
            accessoryView.superview != view {
            accessoryView.removeFromSuperview()
            accessoryView.translatesAutoresizingMaskIntoConstraints = false
            if let view = view as? NSScrollView {
                view.addFloatingSubview(accessoryView, for: .vertical)
            } else {
                view.addSubview(accessoryView)
            }
            view.addConstraints([
                view.leadingAnchor.constraint(equalTo: accessoryView.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: accessoryView.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: accessoryView.bottomAnchor),
                ])
        }
    }
    
    open func updateDisplay(withNewContent content: [AnyObject]) -> Void {
        var view : NSView? = nil
        var newInspectors = [AJRObjectInspectorViewController]()
        
        if content.count == 0 {
            view = noSelectionView
        } else {
            var inspectors = OrderedSet<AJRInspectorIdentifier>()
            var first = true
            for object in content {
                if let object = object as? AJRInspectable {
                    if first {
                        // The first time we get inspectors, just append those inspectors
                        inspectors.append(contentsOf: object.inspectorIdentifiers)
                        first = false
                    } else {
                        // The on the subsequent inspectors, we just want to have the intersection.
                        inspectors.formIntersection(object.inspectorIdentifiers)
                    }
                }
            }
            if content.count == 0 || (inspectors.count == 1 && inspectors.first == .noInspector) {
                // There's no objects to inspect, or the content only produced one inspector identifier, and it's equal to .noInspector.
                view = noInspectorView
            } else if inspectors.count > 0 {
                // There is content, and the content produced at least one inspector in common to all the content.
                view = activeInspectorView

                let stackedView = AJRBlockDrawingView(frame: NSRect.zero, flipped: true)
                if debugFrames {
                    stackedView.xColor = NSColor.orange
                }
                stackedView.translatesAutoresizingMaskIntoConstraints = false

                var previousView : NSView? = nil
                for inspectorId in inspectors.reversed() {
                    if let inspector = inspector(for: inspectorId) {
                        let inspectorView = inspector.view
                        newInspectors.append(inspector)

                        stackedView.addSubview(inspectorView)
                        // Set up our shared constraints, first.
                        stackedView.addConstraints([
                            stackedView.leftAnchor.constraint(equalTo: inspectorView.leftAnchor),
                            inspectorView.rightAnchor.constraint(equalTo: stackedView.rightAnchor),
                        ])
                        // Basically, if we have a previous view, then the top constraint of the view is to previous view's bottomAnchor, otherwise it's to stackedView's topAnchor.
                        if let previousView = previousView {
                            stackedView.addConstraints([
                                previousView.bottomAnchor.constraint(equalTo: inspectorView.topAnchor),
                            ])
                        } else {
                            stackedView.addConstraints([
                                stackedView.topAnchor.constraint(equalTo: inspectorView.topAnchor),
                            ])
                        }

                        previousView = inspectorView
                    }
                }
                if let previousView = previousView {
                    // If previousView is no nil, then we actually generated some content for display, so make it our scroll view's document view. Handily, it's also the last view in our stack, which we'll use to set up the final, bottom anchor.
                    stackedView.addConstraints([
                        previousView.bottomAnchor.constraint(equalTo: stackedView.bottomAnchor)
                    ])
                    let clipView = activeInspectorView.contentView
                    activeInspectorView.documentView = stackedView
                    clipView.addConstraints([
                        stackedView.topAnchor.constraint(equalTo: clipView.topAnchor),
                        stackedView.leftAnchor.constraint(equalTo: clipView.leftAnchor),
                        stackedView.rightAnchor.constraint(equalTo: clipView.rightAnchor),
                    ])
                } else {
                    activeInspectorView.documentView = NSView()
                }
            } else {
                // Basically, content.count > 0 but inspectors.count == 0, in which case we have multiple, unrelated objects, so we display the multiple selection view.
                view = multipleSelectionView
            }
        }
        
        if view == nil {
            view = NSView()
        }

        for inspector in newInspectors {
            if let index = activeInspectors.firstIndex(where: { return AJREqual($0, inspector) }) {
                // We're already using this inspector, so just remove it from activeInspectors. This may seem backwards, but when we're done, the only thing left in active active inspectors will be ones we're no longer using. These can then be cleared, and we can just add everything in newInspectors to activeInspectors.
                activeInspectors.remove(at: index)
            }
        }
        // At this point, everything in in activeInspectors is no longer in use, so let's clear those out.
        for inspector in activeInspectors {
            inspector.controller = nil
        }
        // Those inspectors are now cleared, so let's remove everything and add in newInspectors
        activeInspectors.removeAll()
        activeInspectors.append(contentsOf: newInspectors)

        // Finally, now that everyone is looking at our array controller, "ping" the array controller to get everyone to update their display.
        arrayController.content = content

        // Now that the arrayController has the new content, we can assign the controller to the inspectors
        for inspector in newInspectors {
            inspector.controller = arrayController
        }
        arrayController.setSelectedObjects(content)

        if let view = view {
            box.contentView = view
            box.addConstraints([
                box.topAnchor.constraint(equalTo: view.topAnchor),
                box.leftAnchor.constraint(equalTo: view.leftAnchor),
                box.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                box.rightAnchor.constraint(equalTo: view.rightAnchor),
                ])
            installAccessoryView(in: view)
        }
    }
    
    // MARK: - Inspectors
    
    internal var inspectorsByIdentifier = [AJRInspectorIdentifier:AJRObjectInspectorViewController]()
    
    @objc(inspectorForIdentifier:)
    open func inspector(for identifier: AJRInspectorIdentifier) -> AJRObjectInspectorViewController? {
        var inspector = inspectorsByIdentifier[identifier]
        
        if inspector == nil {
            if let extensionPoint = AJRInspectorViewController.inspectorExtensionsByIdentifier[identifier] {
                inspector = extensionPoint.inspectorClass.init(parent: self, name: extensionPoint.xmlName, xmlName: extensionPoint.xmlName, bundle: extensionPoint.bundle)
                inspectorsByIdentifier[identifier] = inspector
            } else {
                AJRLog.warning("No known inspector for identifier: \(identifier)")
            }
        }
        
        return inspector
    }
    
    // MARK: - NSViewController
    
    override open func loadView() -> Void {
        let box = NSBox.init(frame: NSRect.zero)
        box.translatesAutoresizingMaskIntoConstraints = false
        
        box.title = "Inspector"
        box.titlePosition = .noTitle
        box.isTransparent = true
        
        box.addConstraints([
            box.widthAnchor.constraint(greaterThanOrEqualToConstant: minWidth),
            ])
        
        self.view = box
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // OK. So our view has loaded, which means we now need to update to our content, if we've already been given content.
        updateDisplay(withNewContent: content)
    }
    
}
