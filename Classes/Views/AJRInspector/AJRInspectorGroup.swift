/*
 AJRInspectorGroup.swift
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
open class AJRInspectorGroup: AJRInspectorSection {

    open var titleKey : AJRInspectorKey<String>?
    /// Defines the key for controlling whether or not we're collapsed. If set, `expandedKey` may not be set.
    open var collapsedKey : AJRInspectorKey<Bool>?
    /// Defines the key for controlling whether or not we're expanded. If set, `collapsedKey` may not be set.
    open var expandedKey : AJRInspectorKey<Bool>?
    open var visualEffectView : NSVisualEffectView!
    open var titleLabel : NSTextField!
    open var collapseStateButton : NSButton? = nil
    open var separatorView : NSView? = nil

    open var isCollapsed : Bool {
        get {
            if let collapsedKey {
                return collapsedKey.value ?? false
            }
            if let expandedKey {
                return !(expandedKey.value ?? false)
            }
            return false
        }
        set {
            if let collapsedKey {
                collapsedKey.value = newValue
            }
            if let expandedKey {
                expandedKey.value = !newValue
            }
        }
    }

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
    
    open override func buildView(from element: XMLElement) throws -> Void {
        titleKey = try AJRInspectorKey(key: "title", xmlElement: element, inspectorElement: self)
        collapsedKey = try AJRInspectorKey(key: "collapsed", xmlElement: element, inspectorElement: self)
        expandedKey = try AJRInspectorKey(key: "expanded", xmlElement: element, inspectorElement: self)

        if collapsedKey != nil && expandedKey != nil {
            throw NSError(domain: AJRInspectorErrorDomain, message: "You may only define the 'expanded' or 'collapsed' key, but not both.")
        }

        try super.buildView(from: element)

        weak var weakSelf = self
        if let titleKey = titleKey {
            visualEffectView = NSVisualEffectView(frame: NSRect.zero)
            visualEffectView.translatesAutoresizingMaskIntoConstraints = false

            stackView?.insertView(visualEffectView, at: 0, in: .top)
            view.addConstraints([
                visualEffectView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0),
                visualEffectView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0),
            ])

            titleLabel = NSTextField(labelWithString: "Title")
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.controlSize = .mini
            updateTitleLabel()
            visualEffectView.addSubview(titleLabel)

            if expandedKey != nil || collapsedKey != nil {
                collapseStateButton = NSButton(checkboxWithTitle: "", target: self, action: #selector(toggleCollapseState(_:)))
                collapseStateButton?.translatesAutoresizingMaskIntoConstraints = false
                collapseStateButton!.controlSize = .small
                visualEffectView.addSubview(collapseStateButton!)
            }

            visualEffectView.addConstraints([
                titleLabel.leftAnchor.constraint(equalTo: visualEffectView.leftAnchor, constant: 5.0),
                titleLabel.rightAnchor.constraint(greaterThanOrEqualTo: visualEffectView.rightAnchor, constant: 5.0),
                titleLabel.topAnchor.constraint(equalTo: visualEffectView.topAnchor, constant: 3.0),
                titleLabel.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor, constant: -3.0),
                titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant:50.0),
            ])
            if let collapseStateButton {
                visualEffectView.addConstraints([
                    visualEffectView.rightAnchor.constraint(equalTo: collapseStateButton.rightAnchor, constant: 5.0),
                    titleLabel.firstBaselineAnchor.constraint(equalTo: collapseStateButton.firstBaselineAnchor),
                    //titleLabel.rightAnchor.constraint(greaterThanOrEqualTo: collapseStateButton.leftAnchor, constant: 10.0),
                    //titleLabel.rightAnchor.constraint(greaterThanOrEqualTo: visualEffectView.rightAnchor, constant: 5.0),
                ])
            } else {
                // We don't have a collapse button, so set our contraint to the container view.
                visualEffectView.addConstraints([
                    titleLabel.rightAnchor.constraint(greaterThanOrEqualTo: visualEffectView.rightAnchor, constant: 5.0),
                ])
            }

            titleKey.addObserver {
                weakSelf?.titleLabel?.stringValue = weakSelf?.titleKey?.value ?? ""
            }
            borderColorBottomKey?.addObserver {
                // We just need to make sure this updates.
                weakSelf?.separatorView?.needsDisplay = true
            }
        }
        collapsedKey?.addObserver {
            weakSelf?.updateCollapsedState()
        }
        expandedKey?.addObserver {
            weakSelf?.updateCollapsedState()
        }
    }

    // MARK: - Utilities

    // We have to override this meathod, because we don't want to remove our title, if we have one.
    open override func removeRepeatingChildren() -> Void {
        if let stackView {
            if titleKey != nil {
                for (index, view) in stackView.arrangedSubviews.enumerated() {
                    if index > 0 {
                        view.removeFromSuperview()
                    }
                }
            } else {
                super.removeRepeatingChildren()
            }
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

    open func updateCollapsedState() -> Void {
        let state = isCollapsed
        collapseStateButton?.state = state ? .off : .on
        contentStackView?.isHidden = state
    }

    // MARK: - Children

    open override func verticalSpacing(fromView view: NSView) -> CGFloat {
        return view == titleLabel ? 2.0 : super.verticalSpacing(fromView: view)
    }
    
    open override func createChild(from element: XMLElement, parent: AJRInspectorElement? = nil) throws -> AJRInspectorElement {
        let parentToAssign = parent ?? self
        if let viewController = parentToAssign.viewController {
            switch element.name {
            case "section":
                return try AJRInspectorSection(element: element, parent: parentToAssign, viewController: viewController)
            case "slice":
                return try AJRInspectorSlice.slice(from: element, parent: parentToAssign, viewController: viewController)
            case "group":
                return try AJRInspectorGroup(element: element, parent: parentToAssign, viewController: viewController)
            default:
                throw NSError(domain: AJRInspectorErrorDomain, message: "Invalid child in group: \(element)")
            }
        } else {
            throw NSError(domain: AJRInspectorErrorDomain, message: "viewController in nil")
        }
    }

    open override func createSeparatorView() -> NSView? {
        let separatorView = AJRBlockDrawingView(frame: NSRect.zero)
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
        return separatorView
    }

    open override func didAddAllChildren() {
        updateTitleLabel()

        if contentStackView != nil {
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
                separatorView = createSeparatorView()
                if let separatorView {
                    stackView?.addView(separatorView, in: .top)
                }
            } else if !addBorder, let separatorView = separatorView {
                separatorView.removeFromSuperview()
                self.separatorView = nil
            }
        }
    }

    // MARK: - Actions

    @IBAction open func toggleCollapseState(_ sender: NSButton?) -> Void {
        if let sender {
            isCollapsed = sender.state == .off
        }
    }

}
