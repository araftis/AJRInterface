/*
 AJRInspectorSlice.swift
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

    open var nibBundle : Bundle {
        return Bundle(for: Self.self)
    }

    open var nibName : String? {
        var name = NSStringFromClass(Self.self)
        if let index = name.firstIndex(of: ".") {
            name = String(name.suffix(from: name.index(after: index)))
        }
        return name
    }

    internal var labelString : NSAttributedString {
        if let value = labelKey?.value,
           let attributedValue = (try? NSAttributedString(markdown: value))?.mutableCopy() as? NSMutableAttributedString {
            attributedValue.addAttributes([.font: NSFont.systemFont(ofSize: viewController!.fontSize)], range: attributedValue.allRange)
            return attributedValue
        }
        return NSAttributedString("")
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
            
            labelField!.attributedStringValue = labelString
        }
    }
    
    open func buildView(from element: XMLElement) throws -> Void {
        if let nibName = nibName {
            fullWidthKey = try AJRInspectorKey(key: "fullWidth", xmlElement: element, inspectorElement: self)
            
            let bundle = nibBundle
            if !bundle.loadNibNamed(nibName, owner: self, topLevelObjects: nil) {
                AJRLog.warning("Failed to load: \(nibName) from bundle: \(bundle). You might need to override nibBundle if your nib isn't located in the same framework as your slice class.")
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
                    if let strongSelf = weakSelf {
                        strongSelf.labelField?.attributedStringValue = strongSelf.labelString
                    }
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
