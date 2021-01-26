//
//  AJRInspectorSlice.swift
//  AJRInterface
//
//  Created by AJ Raftis on 3/17/19.
//

import Cocoa

@objc
public enum AJRValueSelectionType : Int, CustomStringConvertible {
    case none
    case multiple
    case single
    
    public var description: String {
        switch self {
        case .none:
            return "none"
        case .multiple:
            return "multiple"
        case .single:
            return "single"
        }
    }
    
}

@objcMembers
open class AJRInspectorSlice: AJRInspectorElement {

    // MARK: - Properties
    
    open override var canBeLabeled : Bool { return true }
    @IBOutlet public var baselineAnchorView : NSView!
    open var loadedView : NSView!
    open var labelKey : AJRInspectorKey<String>?
    open var labelField : NSTextField? // Generally only set if label != nil || labelKeyPath != nil
    open var fullWidthKey : AJRInspectorKey<Bool>?
    open var baseLineOffset : CGFloat { return 0.0 }
    open var isMerged = false
    open var bottomConstraint : NSLayoutConstraint?
    
    open var isFullWidth : Bool {
        return fullWidthKey?.value ?? false && labelKey?.value == nil
    }

    open var fullWidthInset : CGFloat {
        return 7.0
    }

    open var topAnchorOffset : CGFloat {
        return 0.0
    }
    
    override open var firstKeyView: NSView {
        return baselineAnchorView
    }
    
    override open var lastKeyView: NSView {
        return baselineAnchorView
    }
    
    // MARK: - Factory
    
    private static var sliceClassesByType = [String:AJRInspectorSlice.Type]()
    
    open class func registerSlice(_ sliceClass: AJRInspectorSlice.Type, properties: [String:Any]) -> Void {
        if let type = properties["type"] as? String {
            sliceClassesByType[type] = sliceClass
        }
    }
    
    open class func slice(from element: XMLElement, parent: AJRInspectorElement, viewController: AJRObjectInspectorViewController) throws -> AJRInspectorSlice {
        // Forces the plugin manager to load
        if let type = element.attribute(forName: "type")?.stringValue {
            if let sliceClass = sliceClassesByType[type] {
                return try sliceClass.createSlice(from: element, parent: parent, viewController: viewController, bundle: Bundle(for: sliceClass))
            } else {
                throw NSError(domain: AJRInspectorErrorDomain, message: "Unknown slice type: \(type)")
            }
        } else {
            throw NSError(domain: AJRInspectorErrorDomain, message: "slice missing type attribute: \(element)")
        }
    }
    
    // MARK: - Creation
    
    open class func createSlice(from element: XMLElement, parent: AJRInspectorElement, viewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main) throws -> AJRInspectorSlice {
        return try self.init(element: element, parent: parent, viewController: viewController, bundle: bundle)
    }
    
    public required init(element: XMLNode, parent: AJRInspectorElement?, viewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main, userInfo: [AnyHashable:Any]? = nil) throws {
        try super.init(element: element, parent: parent, viewController: viewController, bundle: bundle, userInfo: userInfo)
        if let element = element as? XMLElement {
            labelKey = try AJRInspectorKey(key: "label", xmlElement: element, inspectorElement: self)
            try buildView(from: element)
        }
        
        if let element = element as? XMLElement {
            let knownKeys = self.knownKeys
            for attribute in element.attributes ?? [] {
                if var name = attribute.name {
                    var addOn = ""
                    if name.hasSuffix("KeyPath") {
                        name = String(name[name.startIndex ..< name.index(name.endIndex, offsetBy: -7)])
                        addOn = "KeyPath"
                    }
                    if !knownKeys.contains(name) {
                        var string = "Unknown attribute: \"\(name + addOn)\" in: \(element)"
                        if let url = rootElement.url {
                            string = url.lastPathComponent + ": " + string
                        }
                        AJRLog.warning(string)
                    }
                }
            }
        }
    }
    
    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("type")
        keys.insert("label")
        keys.insert("fullWidth")
    }
    
    // MARK: - View
    
    open var nibName : String? {
        var name = NSStringFromClass(Self.self)
        if let index = name.firstIndex(of: ".") {
            name = String(name.suffix(from: name.index(after: index)))
        }
        return name
    }
    
    open func addLabel(to view: NSView) -> Void {
        if labelKey != nil {
            labelField = NSTextField(labelWithString: "Label")
            labelField!.translatesAutoresizingMaskIntoConstraints = false
            labelField!.controlSize = .mini
            labelField!.font = NSFont.systemFont(ofSize: viewController!.fontSize)
            labelField!.alignment = .right
            view.addSubview(labelField!)
            view.addConstraints([
                labelField!.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 5.0),
                labelField!.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: viewController!.labelWidth - 5.0),
                labelField!.firstBaselineAnchor.constraint(equalTo: baselineAnchorView.firstBaselineAnchor, constant: baseLineOffset),
                ])
            
            labelField!.stringValue = labelKey?.value ?? ""
        }
    }
    
    open func buildView(from element: XMLElement) throws -> Void {
        if let nibName = nibName {
            fullWidthKey = try AJRInspectorKey(key: "fullWidth", xmlElement: element, inspectorElement: self)
            
            let bundle = Bundle(for: Self.self)
            if !bundle.loadNibNamed(nibName, owner: self, topLevelObjects: nil) {
                AJRLog.warning("Failed to load: \(nibName)")
            }
            self.loadedView = self.view
            if let loadedView = loadedView {
                self.view = NSView(frame: NSRect.zero)
                self.view.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(loadedView)
                if isFullWidth {
                    self.view.addConstraints([
                        loadedView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: fullWidthInset),
                        loadedView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -fullWidthInset),
                        ])
                } else {
                    self.view.addConstraints([
                        loadedView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: viewController!.labelWidth),
                        loadedView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -7.0),
                        ])
                }
                bottomConstraint = loadedView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -4.0)
                self.view.addConstraints([
                    loadedView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: topAnchorOffset),
                    bottomConstraint!,
                    view.widthAnchor.constraint(greaterThanOrEqualToConstant: viewController?.minWidth ?? AJRInspectorViewController.defaultMinWidth),
                    ])

                addLabel(to: self.view)
                weak var weakSelf = self
                labelKey?.addObserver {
                    weakSelf?.labelField?.stringValue = weakSelf?.labelKey?.value ?? ""
                }
            } else {
                AJRLog.warning("The view outlet didn't resolve on nib load. Please make sure it's connected: \(nibName)")
            }
        }
    }

    open override func mergeViewWithRightAdjacentSibling(_ sibling: AJRInspectorElement) -> Void {
        if let sibling = sibling as? AJRInspectorSlice,
            let view = view,
            let leftView = self.loadedView,
            let rightView = sibling.loadedView {
            view.subviews = []
            view.addSubview(leftView)
            view.addSubview(rightView)
            
            view.addConstraints([
                leftView.topAnchor.constraint(equalTo: view.topAnchor),
                leftView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4.0),
                leftView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: viewController!.labelWidth),
                leftView.rightAnchor.constraint(equalTo: rightView.leftAnchor, constant: -5.0),
                leftView.widthAnchor.constraint(equalTo: rightView.widthAnchor),
                rightView.topAnchor.constraint(equalTo: view.topAnchor),
                rightView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4.0),
                rightView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -7.0),
                ])
            
            addLabel(to: view)
            
            isMerged = true
            sibling.isMerged = true
        }
    }

}
