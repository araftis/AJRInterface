/*
 AJRInspectorGroup.swift
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

@objcMembers
open class AJRInspectorGroup: AJRInspectorSection {

    open var titleKey : AJRInspectorKey<String>?
    open var forEachKey : AJRInspectorKeyPath<[AnyObject]>?
    /// The element used to create this group. This will be `nil` if `forEachKey` is `nil`.
    open var element : XMLElement? = nil
    open var visualEffectView : NSVisualEffectView!
    open var titleLabel : NSTextField!
    open var separatorView : AJRBlockDrawingView? = nil
    
    // MARK: - View

    open override var borderRenderer : AJRDrawingBlock? {
        weak var weakSelf = self
        return { (context, bounds) in
            if let strongSelf = weakSelf {
                if let color = strongSelf.borderColorTopKey?.value, !strongSelf.isFirstChild {
                    color.set()
                    NSBezierPath.strokeLine(from: NSPoint(x: bounds.minX, y: bounds.maxY - 0.5), to: NSPoint(x: bounds.maxX, y: bounds.maxY - 0.5));
                }
                if let color = strongSelf.borderColorBottomKey?.value {
                    color.set()
                    NSBezierPath.strokeLine(from: NSPoint(x: bounds.minX, y: bounds.minY + 0.5), to: NSPoint(x: bounds.maxX, y: bounds.minY + 0.5));
                }
            }
        }
    }

    open override var defaultTopMargin : CGFloat { return 7.0 }
    open override var defaultBottomMargin : CGFloat { return 11.0 }
    
    open var stackView : NSStackView? {
        return view as? NSStackView
    }

    open override func buildView(from element: XMLElement) throws -> Void {
        titleKey = try AJRInspectorKey(key: "title", xmlElement: element, inspectorElement: self)
        forEachKey = try AJRInspectorKeyPath(key: "forEach", xmlElement: element, inspectorElement: self)
        
        try super.buildView(from: element)
        if forEachKey != nil {
            self.element = element
        }

        weak var weakSelf = self
        if let titleKey = titleKey {
            visualEffectView = NSVisualEffectView(frame: NSRect.zero)
            visualEffectView.translatesAutoresizingMaskIntoConstraints = false

            stackView?.addView(visualEffectView, in: .top)
            view.addConstraints([
                visualEffectView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0),
                visualEffectView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0),
            ])

            titleLabel = NSTextField(labelWithString: "Title")
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.controlSize = .mini
            updateTitleLabel()
            visualEffectView.addSubview(titleLabel)
            if forEachKey != nil {
                print("titleLabel: \(visualEffectView!)")
            }

            visualEffectView.addConstraints([
                titleLabel.leftAnchor.constraint(equalTo: visualEffectView.leftAnchor, constant: 5.0),
                titleLabel.rightAnchor.constraint(greaterThanOrEqualTo: visualEffectView.rightAnchor, constant: 5.0),
                titleLabel.topAnchor.constraint(equalTo: visualEffectView.topAnchor, constant: 3.0),
                titleLabel.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor, constant: -3.0),
                titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant:50.0),
            ])

            titleKey.addObserver {
                weakSelf?.titleLabel?.stringValue = weakSelf?.titleKey?.value ?? ""
            }
            borderColorBottomKey?.addObserver {
                // We just need to make sure this updates.
                weakSelf?.separatorView?.needsDisplay = true
            }
        }
        forEachKey?.addObserver {
            if let strongSelf = weakSelf,
                let forEachKey = strongSelf.forEachKey {
                switch forEachKey.selectionType {
                case .multiple:
                    break
                case .none:
                    break;
                case .single:
                    strongSelf.updateRepeatingChildren()
                }
            }
        }
    }

    // MARK: - Utilities
    
    open func updateRepeatingChildren() -> Void {
        if let stackView {
            let skipFirst = titleKey != nil
            let arrangedViews = stackView.arrangedSubviews
            for (index, view) in arrangedViews.enumerated() {
                if skipFirst && index == 0 {
                    continue
                }
                view.removeFromSuperview()
            }
        }
        if let element,
           let allObjects = forEachKey?.value as? [[AnyObject]],
           allObjects.count > 0 {
            let objects = allObjects[0]
            for object in objects {
                // NOTE: element is basically ignored here.
                let viewController = AJRObjectInspectorViewController(parent: nil, name: nil, xmlName: nil, bundle: nil)
                let phantomParent = try? AJRInspectorElement(element: element, parent: self, viewController: viewController)
                viewController.controller?.content = [object]
                // TODO: Catch this exception and handle it gracefully.
                try? buildChildren(from: element, inspector: phantomParent)
            }
        } else {
            print("no objects")
        }
    }

    /**
     Returns the nesting level of the group within other groups. This is useful for determining how to format the title. For example, the groups at level 1 have a stronger appearance than lower groups. Currently, only two title styles are used, those at depth 1 and greater than 1.
     */
    open var groupDepth : Int {
        var element : AJRInspectorElement? = self
        var depth = 0

        while element != nil {
            if element is AJRInspectorGroup {
                depth += 1
            }
            element = element?.parent
        }

        return depth
    }

    open func updateTitleLabel() -> Void {
        // A little overkill at the moment, since we only have two depths, but I wanted to leave things open for the future.
        let depth = groupDepth

        if depth == 1 {
            titleLabel.textColor = NSColor.headerTextColor
            titleLabel.font = NSFont.systemFont(ofSize: viewController!.fontSize + 2.0, weight: .bold)
            visualEffectView.blendingMode = .withinWindow
            visualEffectView.material = .headerView
        } else if depth > 1 {
            titleLabel?.font = NSFont.systemFont(ofSize: viewController!.fontSize + 2.0, weight: .bold)
            titleLabel?.backgroundColor = nil
            titleLabel?.textColor = NSColor.headerTextColor
            visualEffectView?.blendingMode = .withinWindow
            visualEffectView?.material = .windowBackground
        }
    }

    // MARK: - Children

    open override func verticalSpacing(fromView view: NSView) -> CGFloat {
        return view == titleLabel ? 2.0 : super.verticalSpacing(fromView: view)
    }
    
    open override func createChild(from element: XMLElement, parent: AJRInspectorElement? = nil) throws -> AJRInspectorElement {
        if let viewController = viewController {
            switch element.name {
            case "section":
                return try AJRInspectorSection(element: element, parent: parent ?? self, viewController: viewController)
            case "slice":
                return try AJRInspectorSlice.slice(from: element, parent: parent ?? self, viewController: viewController)
            case "group":
                return try AJRInspectorGroup(element: element, parent: parent ?? self, viewController: viewController)
            default:
                throw NSError(domain: AJRInspectorErrorDomain, message: "Invalid child in group: \(element)")
            }
        } else {
            throw NSError(domain: AJRInspectorErrorDomain, message: "viewController in nil")
        }
    }

    open override func didAddAllChildren() {
        // TODO: Remove this debug code, once I'm sure everything is working.
//        print("title: \(groupDepth): \(titleKey?.value ?? "")")
//        if titleKey?.value == "Graphic" {
//            print("break here")
//        }
        updateTitleLabel()

        if let view = view as? NSStackView {
            let depth = groupDepth
            var addBorder = false

            // Yes, these could probably be combined into one big expression, but that'd just make it harder to read.
            if depth == 1 {
                if let parent = parent as? AJRInspectorContent {
                    addBorder = isLastChild && parent.isLastChild
                } else {
                    addBorder = !isLastChild
                }
            } else if depth > 1 {
                addBorder = !isLastChild
            }

            if addBorder && separatorView == nil {
                separatorView = AJRBlockDrawingView(frame: NSRect.zero)
                if let separatorView = separatorView {
                    separatorView.addConstraint(separatorView.heightAnchor.constraint(equalToConstant: 5.0))
                    weak var weakSelf = self
                    separatorView.contentRenderer = { (context, bounds) in
                        if let self = weakSelf {
                            // Useful for debugging: var color : NSColor? = depth == 1 ? NSColor.red : NSColor.blue
                            var color : NSColor? = self.borderColorBottomKey?.value
                            if color == nil {
                                color = NSColor.separatorColor
                            }
                            color?.set()
                            var rect = CGRect(x: bounds.minX, y: bounds.minY + bounds.height / 2.0, width: bounds.width, height: 1.0)
                            // TODO: Use margins
                            rect.origin.x += 5.0
                            rect.size.width -= 10.0
                            rect.frame()
                        }
                    }
                    view.addView(separatorView, in: .top)
                }
            } else if !addBorder, let separatorView = separatorView {
                separatorView.removeFromSuperview()
                self.separatorView = nil
            }
        }
    }

}
