/*
 AJRInspectorSliceChoice.swift
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

import AJRFoundation
import Cocoa

/**
 The class hierarchy here is a little complicated, so here it is...
 
 ```
                                                                                      +- AJRInspectorChoiceVariableTyped<T: AJRInspectorValue>
                                                                                      |
                                                   +-> AJRInspectorChoiceVariable<T> -+
                                                   |                                  |
 AJRInspectorChoice -> AJRInspectorChoiceTyped<T> -+                                  +-  AJRInspectorChoiceObject<Any>
                                                   |
                                                   +-> AJRInspectorChoiceFixed<T>
 ```
 */

@objcMembers
open class AJRInspectorChoice : NSObject {
    
    weak var slice : AJRInspectorSlice?

    open var content : AJRInspectorContent?
    open var hasContent : Bool {
        return content != nil
    }

    open var isSeparator = false // Can't change dynamically, and never really changes conditionally, so just get and set

    private var _menuItem : NSMenuItem!
    open var menuItem : NSMenuItem! {
        get {
            if _menuItem == nil {
                try? createMenuItem()
            }
            _menuItem.title = resolvedTitle
            return _menuItem
        }
        set {
            _menuItem = newValue
        }
    }

    open func createMenuItem() throws -> Void {
    }
    
    internal override init() {
    }

    public init(slice: AJRInspectorSlice) throws {
        self.slice = slice
        super.init()
    }
    
    open var resolvedTitle : String {
        return ""
    }
    
    open var resolvedImage : NSImage? {
        return nil
    }

}

@objcMembers
open class AJRInspectorChoiceTyped<T> : AJRInspectorChoice {
    
    open var resolvedValue : T? {
        return nil
    }

}

@objcMembers
open class AJRInspectorChoiceVariable<T> : AJRInspectorChoiceTyped<T> {

    var titleKey : AJRInspectorKey<String>?
    var imageKey : AJRInspectorKeyPath<NSImage>?
    var imageNameKey : AJRInspectorKey<String>?
    var imageBundleKey : AJRInspectorKey<Bundle>?

    public override init(slice: AJRInspectorSlice) throws {
        try super.init(slice: slice)
    }
    
    public init(element: XMLElement, slice: AJRInspectorSlice, viewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main) throws {
        
        try super.init(slice: slice)
        
        titleKey = try AJRInspectorKey(key: "title", xmlElement: element, inspectorElement: slice)
        imageKey = try AJRInspectorKeyPath(key: "image", xmlElement: element, inspectorElement: slice)
        imageNameKey = try AJRInspectorKey(key: "imageName", xmlElement: element, inspectorElement: slice)
        imageBundleKey = try AJRInspectorKey(key: "bundle", xmlElement: element, inspectorElement: slice)

        if let rawValue = element.attribute(forName: "separator")?.stringValue {
            if let value = Bool(rawValue), value {
                isSeparator = true
            }
            
            menuItem = NSMenuItem.separator()
        }
        
        if !isSeparator {
            try createMenuItem()
        }
        
        if let children = element.children, children.count > 0 {
            content = try AJRInspectorContent(element: element, parent: slice, viewController: viewController, bundle: bundle)
        }
    }
    
    // MARK: - Conveniences
    
    open override var resolvedTitle : String {
        return titleKey?.value ?? ""
    }
    
    open override var resolvedImage : NSImage? {
        if let imageKey = imageKey {
            return imageKey.value
        }
        if let imageName = imageNameKey?.value {
            let bundle = imageBundleKey?.value ?? Bundle.main
            return AJRImages.image(named: imageName, in: bundle)
        }
        return nil
    }
    
}

@objcMembers
open class AJRInspectorChoiceFixed<T: AJRInspectorValue> : AJRInspectorChoiceTyped<T> {
    
    open var value : T
    open var title : String
    open var image : NSImage?
    
    public init(slice: AJRInspectorSlice, title: String?, image: NSImage?, value: T) throws {
        self.title = title ?? String(describing: value)
        self.value = value
        self.image = image
        try super.init(slice: slice)
    }
    
    open override func createMenuItem() throws -> Void {
        menuItem = NSMenuItem(title: resolvedTitle, action: #selector(AJRInspectorSliceChoice.selectChoice(_:)), keyEquivalent: "")
        menuItem.target = slice
        if let image = resolvedImage {
            menuItem.image = image
        }
        menuItem.representedObject = self
    }
    
    open override var resolvedTitle: String {
        return title
    }
    
    open override var resolvedValue: T? {
        return value
    }
    
    open override var resolvedImage: NSImage? {
        return image
    }
    
}

@objcMembers
open class AJRInspectorChoiceVariableTyped<T: AJRInspectorValue> : AJRInspectorChoiceVariable<T> {
    
    var valueKey : AJRInspectorKey<T>?
    
    override init(element: XMLElement, slice: AJRInspectorSlice, viewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main) throws {

        valueKey = try AJRInspectorKey(key: "value", xmlElement: element, inspectorElement: slice)

        try super.init(element: element, slice: slice, viewController: viewController, bundle: bundle)
    }
    
    override open func createMenuItem() throws -> Void {
        if !isSeparator {
            menuItem = NSMenuItem(title: resolvedTitle, action: #selector(AJRInspectorSliceChoiceTyped<T>.selectChoice(_:)), keyEquivalent: "")
            if let image = resolvedImage {
                menuItem.image = image
            }
            menuItem.target = slice
            menuItem.representedObject = self
        }
    }
    
    // MARK: - Conveniences
    
    public override var resolvedValue : T? {
        return valueKey?.value
    }
    
}

@objcMembers
private class AJRInspectorSliceChoiceTyped<T: AJRInspectorValue> : AJRInspectorSliceChoice {

    var valueKey : AJRInspectorKey<T>?
    var valuesKeyPath : AJRInspectorKeyPath<[T]>?
    
    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("value")
        keys.insert("values")
    }
    
    // MARK: - Build View
    
    override func buildView(from element: XMLElement) throws {
        valueKey = try AJRInspectorKey(key: "value", xmlElement: element, inspectorElement: self)
        valuesKeyPath = try AJRInspectorKeyPath(key: "values", xmlElement: element, inspectorElement: self)

        if let children = element.children {
            for childNode in children {
                if let childNode = childNode as? XMLElement {
                    if childNode.name == "choice" {
                        choices.append(try AJRInspectorChoiceVariableTyped<T>(element: childNode, slice: self, viewController: viewController!, bundle: bundle))
                    } else {
                        throw NSError(domain: AJRInspectorErrorDomain, message: "Only \"choice\" elements may appear as children of \"choice\" slices.")
                    }
                }
            }
        }
        
        try super.buildView(from: element)
        
        if let segments = segments {
            segments.target = self
            segments.action = #selector(selectSegment(_:))
        }

        weak var weakSelf = self
        valueKey?.addObserver {
            weakSelf?.updateValue()
        }
        valuesKeyPath?.addObserver {
            if let strongSelf = weakSelf {
                if let values = strongSelf.valuesKeyPath?.value {
                    strongSelf.choices.removeAll()
                    for value in values {
                        // Throws because some code paths can fail, but we won't hit any of those code paths.
                        strongSelf.choices.append(try! AJRInspectorChoiceFixed(slice: strongSelf, title: nil, image: nil, value: value))
                    }
                }
                strongSelf.updateValue()
            }
        }
    }
    
    // MARK: - Control Updaters
    
    internal func updateValue() -> Void {
        if popUpButton != nil {
            updatePopUpButtonValue()
        }
        if comboBox != nil {
            updateComboBoxValue()
        }
        if segments != nil {
            updateSegmentsValue()
        }
    }
    
    internal func updateMenu(menu: NSMenu?) -> NSMenu {
        let newMenu = menu ?? NSMenu(title: "")
        newMenu.removeAllItems()
        for choice in choices {
            newMenu.addItem(choice.menuItem)
            choice.menuItem.state = .off
        }
        return newMenu
    }
    
    internal func updatePopUpButtonValue() -> Void {
        if let popUpButton = popUpButton {
            var newChoice : AJRInspectorChoice? = nil
            popUpButton.menu = updateMenu(menu: popUpButton.menu)
            switch valueKey?.selectionType ?? .none {
            case .none:
                popUpButton.isEnabled = false
                popUpButton.title = AJRObjectInspectorViewController.translator["No Selection"]
            case .multiple:
                popUpButton.isEnabled = true
                popUpButton.title = AJRObjectInspectorViewController.translator["Multiple Selection"]
            case .single:
                var foundItem : NSMenuItem? = nil
                let value = valueKey?.value
                for menuItem in popUpButton.menu?.items ?? [] {
                    if let choice = menuItem.representedObject as? AJRInspectorChoiceTyped<T> {
                        if AJREqual(value, choice.resolvedValue) {
                            foundItem = menuItem
                        }
                        newChoice = choice
                    }
                }
                if let foundItem = foundItem {
                    popUpButton.select(foundItem)
                }
                popUpButton.isEnabled = true
            }
            displayChoice(newChoice)
        }
    }
    
    internal func updateComboBoxValue() -> Void {
        if let comboBox = comboBox {
            var newChoice : AJRInspectorChoice? = nil
            comboBox.menu = updateMenu(menu: comboBox.menu)
            switch valueKey?.selectionType ?? .none {
            case .none:
                comboBox.isEnabled = false
                comboBox.stringValue = AJRObjectInspectorViewController.translator["No Selection"]
            case .multiple:
                comboBox.isEnabled = true
                comboBox.stringValue = AJRObjectInspectorViewController.translator["Multiple Selection"]
            case .single:
                let value = valueKey?.value
                for menuItem in comboBox.menu?.items ?? [] {
                    if let choice = menuItem.representedObject as? AJRInspectorChoiceTyped<T>,
                        AJREqual(value, choice.resolvedValue) {
                        newChoice = choice
                        break
                    } else if let choice = menuItem.representedObject as? AJRInspectorChoice,
                        AJREqual(value, choice.resolvedTitle) {
                        newChoice = choice
                        break
                    }
                }
                comboBox.stringValue = value == nil ? "" : String(describing: value!)
                comboBox.isEnabled = true
            }
            displayChoice(newChoice)
        }
    }
    
    internal func updateSegmentsValue() -> Void {
        if let segments = segments {
            segments.segmentCount = choices.count
            
            for (index, choice) in choices.enumerated() {
                let title = choice.resolvedTitle
                if !title.isEmpty {
                    segments.setLabel(title, forSegment: index)
                }
                if let image = choice.resolvedImage {
                    segments.setImage(image, forSegment: index)
                }
                segments.setWidth(0.0, forSegment: index)
            }
            segments.sizeToFit()
            
            switch valueKey?.selectionType ?? .none {
            case .none:
                segments.isEnabled = false
            case .multiple:
                segments.isEnabled = enabledKey?.value ?? true
                for x in 0 ..< segments.segmentCount {
                    segments.setSelected(false, forSegment: x)
                }
            case .single:
                segments.isEnabled = enabledKey?.value ?? true
                if let value = valueKey?.value {
                    var foundIndex : Int? = nil
                    for (index, choice) in choices.enumerated() {
                        if let choice = choice as? AJRInspectorChoiceTyped<T> {
                            if AJREqual(value, choice.resolvedValue) {
                                foundIndex = index
                                break
                            }
                        }
                    }
                    for x in 0 ..< segments.segmentCount {
                        segments.setSelected(x == foundIndex, forSegment: x)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction open override func selectChoice(_ sender: Any?) -> Void {
        if let menuItem = sender as? NSMenuItem, let choice = menuItem.representedObject as? AJRInspectorChoiceTyped<T> {
            self.valueKey?.value = choice.resolvedValue
            displayChoice(choice)
        } else {
            displayChoice(nil)
        }
    }
    
    @IBAction open override func takeValueFrom(_ sender: NSTextField?) -> Void {
        // Only value for combox box, at least at the moment. If we introduce something else based on NSTextField, then we'll need to revisit this.
        if let comboBox = comboBox {
            self.valueKey?.value = T.inspectorValue(from: comboBox.stringValue) as? T
        }
    }
    
    @IBAction open override func selectSegment(_ sender: NSSegmentedControl) -> Void {
        let index = sender.selectedSegment
        if let choice = choices[index] as? AJRInspectorChoiceTyped<T> {
            self.valueKey?.value = choice.resolvedValue
            displayChoice(choice)
        }
    }
    
}

public enum AJRSliceChoiceStyle : Int, AJRInspectorValue {
    
    case popUp
    case segments
    case comboBox

    public static func inspectorValue(from string: String) -> Any? {
        if string == "popUp" {
            return AJRSliceChoiceStyle.popUp
        } else if string == "segments" {
            return AJRSliceChoiceStyle.segments
        } else if string == "comboBox" {
            return AJRSliceChoiceStyle.comboBox
        }
        return nil
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        return nil
    }
    
    public var description: String {
        switch self {
        case .popUp:
            return "popUp"
        case .segments:
            return "segments"
        case .comboBox:
            return "comboBox"
        }
    }

}

@objcMembers
open class AJRInspectorSliceChoice: AJRInspectorSlice {
    
    @IBOutlet var popUpButton : NSPopUpButton?
    @IBOutlet var segments : NSSegmentedControl?
    @IBOutlet var comboBox : AJRPopUpTextField?
    open var styleKey : AJRInspectorKey<AJRSliceChoiceStyle>?
    open var enabledKey : AJRInspectorKey<Bool>?
    open var allowsNilKey : AJRInspectorKey<Bool>?
    open var contentView : NSView?
    open var choices = [AJRInspectorChoice]()
    open var choicesHaveSubcontent : Bool {
        return choices.any(passing: { (object) -> Bool in
            return object.hasContent
        }) != nil
    }
    open var mergeWithRightKey : AJRInspectorKey<Bool>?

    // MARK: - Creation
    
    open override class func createSlice(from element: XMLElement, parent: AJRInspectorElement, viewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main) throws -> AJRInspectorSlice {
        let valueType = element.attribute(forName: "valueType")?.stringValue
        switch valueType {
        case "nil":
            fallthrough
        case "integer":
            return try AJRInspectorSliceChoiceTyped<Int>(element: element, parent: parent, viewController: viewController, bundle: bundle)
        case "bool":
            return try AJRInspectorSliceChoiceTyped<Bool>(element: element, parent: parent, viewController: viewController, bundle: bundle)
        case "float":
            return try AJRInspectorSliceChoiceTyped<Double>(element: element, parent: parent, viewController: viewController, bundle: bundle)
        case "string":
            return try AJRInspectorSliceChoiceTyped<String>(element: element, parent: parent, viewController: viewController, bundle: bundle)
        case "object":
            return try AJRInspectorSliceChoiceObject(element: element, parent: parent, viewController: viewController, bundle: bundle)
        default:
            if let valueType = valueType {
                throw NSError(domain: AJRInspectorErrorDomain, message: "Unknown valueType: \(valueType)")
            } else {
                throw NSError(domain: AJRInspectorErrorDomain, message: "Missing key valueType in \(element)")
            }
        }
    }

    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("style")
        keys.insert("enabled")
        keys.insert("valueType")
        keys.insert("mergeWithRight")
        keys.insert("allowsNil")
    }
    
    // MARK: - AJRInspectorSlice
    
    open var style : AJRSliceChoiceStyle {
        return styleKey?.value ?? .popUp
    }
    
    open override var nibName: String? {
        switch style {
        case .popUp:
            return "AJRInspectorSliceChoiceMenu"
        case .segments:
            return "AJRInspectorSliceChoiceSegments"
        case .comboBox:
            return "AJRInspectorSliceChoiceComboBox"
        }
    }
    
    override open func buildView(from element: XMLElement) throws {
        styleKey = try AJRInspectorKey(key: "style", xmlElement: element, inspectorElement: self, defaultValue: .popUp)
        enabledKey = try AJRInspectorKey(key: "enabled", xmlElement: element, inspectorElement: self)
        mergeWithRightKey = try AJRInspectorKey(key: "mergeWithRight", xmlElement: element, inspectorElement: self, defaultValue: false)
        allowsNilKey = try AJRInspectorKey(key: "allowsNil", xmlElement: element, inspectorElement: self, defaultValue: false)

        try super.buildView(from: element)
        
        // TODO: (Resume) OK, always doing true "works", but I only want to do it for object type choices, because the other choice types can figure this out dynamically.
        if true /*choicesHaveSubcontent*/ {
            let contentView = AJRBlockDrawingView(frame: NSRect.zero)
            contentView.translatesAutoresizingMaskIntoConstraints = false
            if viewController?.debugFrames ?? false {
                contentView.xColor = NSColor.purple
            }
            contentView.addConstraints([
                contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 5.0),
                ])
            view.addSubview(contentView);
            
            view.removeConstraint(bottomConstraint!)
            bottomConstraint = view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0.0)
            view.addConstraints([
                view.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0.0),
                view.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0.0),
                bottomConstraint!,
                ])
            if let popUpButton = popUpButton {
                view.addConstraints([
                    contentView.topAnchor.constraint(equalTo: popUpButton.bottomAnchor, constant: 4.0),
                    ])
            } else if let segments = segments {
                view.addConstraints([
                    contentView.topAnchor.constraint(equalTo: segments.bottomAnchor, constant: 4.0),
                    ])
            } else if let comboBox = comboBox {
                view.addConstraints([
                    contentView.topAnchor.constraint(equalTo: comboBox.bottomAnchor, constant: 4.0),
                    ])
            }
            self.contentView = contentView
        }
    }
    
    // MARK: - Choice View
    
    open var activeChoice : AJRInspectorChoice?
    
    open func displayChoice(_ choice: AJRInspectorChoice?) -> Void {
        if let activeChoice = activeChoice {
            if let choiceView = activeChoice.content?.view {
                choiceView.removeFromSuperview()
            }
        }
        activeChoice = choice
        if let activeChoice = activeChoice {
            if let choiceView = activeChoice.content?.view, let contentView = self.contentView {
                contentView.addSubview(choiceView)
                contentView.addConstraints([
                    contentView.topAnchor.constraint(equalTo: choiceView.topAnchor, constant: 0.0),
                    choiceView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0.0),
                    contentView.leftAnchor.constraint(equalTo: choiceView.leftAnchor, constant: 0.0),
                    choiceView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0.0),
                    ])
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction open func selectChoice(_ sender: Any?) -> Void {
        // Does nothing by default.
    }
    
    @IBAction open func takeValueFrom(_ sender: NSTextField?) -> Void {
        // Does nothing by default.
    }
    
    @IBAction open func selectSegment(_ sender: NSSegmentedControl) -> Void {
        // Does nothing by default.
    }

    // MARK: - Merging

    open var wantsMergeWithRight : Bool {
        if let mergeWithRightKey = mergeWithRightKey {
            return mergeWithRightKey.value ?? false
        }
        return false
    }

    open override func canMergeWithElement(_ element: AJRInspectorElement) -> Bool {
        // Basically, we can merge if we don't have a label, the previous view is a number slice, both ourself and slice have a subtitle, and slice hasn't already merged with another slice.
        if let slice = element as? AJRInspectorSliceChoice {
            if self.labelKey == nil && slice.wantsMergeWithRight {
                return true
            }
        }
        return false
    }

}
