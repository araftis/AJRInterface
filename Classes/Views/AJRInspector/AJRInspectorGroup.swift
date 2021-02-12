//
//  AJRInspectorGroup.swift
//  AJRInterface
//
//  Created by AJ Raftis on 3/17/19.
//

import Cocoa

@objcMembers
open class AJRInspectorGroup: AJRInspectorSection {

    open var titleKey : AJRInspectorKey<String>?
    open var visualEffectView : NSVisualEffectView!
    open var titleLabel : NSTextField!
    
    // MARK: - View

    internal override var debugXColor : NSColor { return NSColor.blue }

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
        
        try super.buildView(from: element)

        if let titleKey = titleKey {
            visualEffectView = NSVisualEffectView(frame: NSRect.zero)
            visualEffectView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(visualEffectView)
            view.addConstraints([
                visualEffectView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0),
                visualEffectView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0),
                visualEffectView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
                visualEffectView.heightAnchor.constraint(greaterThanOrEqualToConstant:15.0),
            ])

            titleLabel = NSTextField(labelWithString: "Title")
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.controlSize = .mini
            updateTitleLabel()
            visualEffectView.addSubview(titleLabel)

            visualEffectView.addConstraints([
                titleLabel.leftAnchor.constraint(equalTo: visualEffectView.leftAnchor, constant: 5.0),
                titleLabel.rightAnchor.constraint(greaterThanOrEqualTo: visualEffectView.rightAnchor, constant: 5.0),
                titleLabel.topAnchor.constraint(equalTo: visualEffectView.topAnchor, constant: 3.0),
                titleLabel.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor, constant: -3.0),
                titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant:50.0),
            ])

            weak var weakSelf = self
            titleKey.addObserver {
                weakSelf?.titleLabel?.stringValue = weakSelf?.titleKey?.value ?? ""
            }
        }
    }

    // MARK: - Utilities

    open func updateTitleLabel() -> Void {
        if hasChildGroup {
            titleLabel.textColor = NSColor.headerTextColor
            titleLabel.font = NSFont.systemFont(ofSize: viewController!.fontSize + 2.0, weight: .bold)
            visualEffectView.blendingMode = .withinWindow
            visualEffectView.material = .headerView
        } else {
            titleLabel?.font = NSFont.systemFont(ofSize: viewController!.fontSize, weight: .bold)
            titleLabel?.backgroundColor = nil
            visualEffectView?.blendingMode = .withinWindow
            visualEffectView?.material = .windowBackground
        }
    }

    // MARK: - Children

    open var hasChildGroup : Bool {
        return children.any { (child) -> Bool in
            return child is AJRInspectorGroup
        } != nil
    }
    
    open override func verticalSpacing(fromView view: NSView) -> CGFloat {
        return view == titleLabel ? 2.0 : super.verticalSpacing(fromView: view)
    }
    
    open override func createChild(from element: XMLElement) throws -> AJRInspectorElement {
        if let viewController = viewController {
            switch element.name {
            case "section":
                return try AJRInspectorSection(element: element, parent: self, viewController: viewController)
            case "slice":
                return try AJRInspectorSlice.slice(from: element, parent: self, viewController: viewController)
            case "group":
                return try AJRInspectorGroup(element: element, parent: self, viewController: viewController)
            default:
                throw NSError(domain: AJRInspectorErrorDomain, message: "Invalid child in group: \(element)")
            }
        } else {
            throw NSError(domain: AJRInspectorErrorDomain, message: "viewController in nil")
        }
    }

    open override func add(child: AJRInspectorElement) {
        super.add(child: child)
        updateTitleLabel()
    }

}
