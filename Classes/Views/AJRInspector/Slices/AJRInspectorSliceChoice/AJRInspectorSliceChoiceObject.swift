/*
 AJRInspectorSliceChoiceObject.swift
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
import AJRFoundation

public enum AJRInspectorChoiceObjectType {
    case noSelectionPlaceholder
    case multipleSelectionPlaceholder
    case object
}

@objc public protocol AJRInspectorChoiceTitleProvider {
    var titleForInspector : String? { get }
    var imageForInspector : NSImage? { get }
}

@objcMembers
open class AJRInspectorChoiceObject : AJRInspectorChoiceVariable<Any> {
    
    open var type : AJRInspectorChoiceObjectType = .object
    
    open var objectPredicate : String!
    open var objectExpression : AJREvaluation!
    
    open var object : AnyObject?
    
    public init(object: AnyObject?, slice: AJRInspectorSlice, viewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main) throws {
        self.object = object
        try super.init(slice: slice)
    }
    
    override init(element: XMLElement, slice: AJRInspectorSlice, viewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main) throws {
        if let predicate = element.attribute(forName: "objectPredicate")?.stringValue {
            objectPredicate = predicate
            objectExpression = try AJRExpression.expression(string: objectPredicate)
            type = .object
        } else if let attribute = element.attribute(forName: "noSelection")?.stringValue?.lowercased(),
            attribute == "true" || attribute == "yes" {
            type = .noSelectionPlaceholder
        } else if let attribute = element.attribute(forName: "multipleSelection")?.stringValue?.lowercased(),
            attribute == "true" || attribute == "yes" {
            type = .multipleSelectionPlaceholder
        } else {
            throw NSError(domain: AJRInspectorErrorDomain, message: #"Choices on choice slices with "object" type must define the "objectPredicate" attribute."#)
        }
        try super.init(element: element, slice: slice, viewController: viewController, bundle: bundle)
    }
    
    override open func createMenuItem() throws -> Void {
        if !isSeparator {
            menuItem = NSMenuItem(title: resolvedTitle, action: #selector(AJRInspectorSliceChoiceObject.selectChoice(_:)), keyEquivalent: "")
            menuItem.target = slice
            menuItem.representedObject = self
            if let image = self.resolvedImage {
                menuItem.image = image
            }
        }
    }

    // MARK: - Conveniences
    
    override open var resolvedTitle : String {
        if let titleKey = titleKey {
            return titleKey.value(from: object) ?? ""
        } else {
            if let object = object as? AJRInspectorChoiceTitleProvider {
                return object.titleForInspector ?? ""
            } else if let slice = slice as? AJRInspectorSliceChoiceObject,
                      let keyPath = slice.choiceTitleKeyPath,
                      let title = keyPath.value(from: object) {
                return title
            } else if let object = object {
                return String(describing: object)
            } else {
                return ""
            }
        }
    }

    override open var resolvedImage : NSImage? {
        if let object = object as? AJRInspectorChoiceTitleProvider {
            return object.imageForInspector
        }
        return nil
    }

}


public protocol AJRInspectorContentProvider {
    
    var inspectorFilename : String? { get }
    var inspectorBundle : Bundle? { get }
    
}


@objcMembers
open class AJRInspectorSliceChoiceObject : AJRInspectorSliceChoice {
    
    open var objectsKeyPath : AJRInspectorKeyPath<[AnyObject]>!
    open var valueKeyPath : AJRInspectorKeyPath<AnyObject>!
    open var choiceTitleKeyPath : AJRInspectorKey<String>?
    open var titleWhenNilKeyPath : AJRInspectorKey<String>?
    open var choicesAreExplicit = false // If true, the choices were specified in the XML, otherwise they're expected to come from the objectsKeyPath.

    var objects : [AnyObject] = [] {
        didSet {
            if choicesAreExplicit {
                if let choices = choices as? [AJRInspectorChoiceObject] {
                    for choice in choices {
                        let expression = choice.objectExpression
                        choice.object = nil
                        for object in objects {
                            if let result = try? expression?.evaluate(with: AJREvaluationContext(rootObject: object)) as? Bool, result {
                                choice.object = object
                                break
                            }
                        }
                    }
                    displayChoice(updateSelectedMenuItem())
                }
            } else {
                var newChoices = [AJRInspectorChoiceObject]()
                for object in objects {
                    if let choice = try? AJRInspectorChoiceObject(object: object, slice: self, viewController: viewController!, bundle: bundle) {
                        if let object = object as? AJRInspectorContentProvider,
                           let filename = object.inspectorFilename {
                            do {
                                let document = try AJRInspectorContent.loadXMLDocument(for: filename, bundle: object.inspectorBundle)
                                if document.childCount == 1,
                                   let include = document.child(at: 0) as? XMLElement,
                                   include.name == "inspector-include" {
                                    // This means we're good, but we'll defer creating the content, because creating th content causes it to bind, which may not be valid with the current selection.
                                    choice.element = include
                                } else {
                                    AJRLog.error("Included document must contain one child with the name \"inspector-include\".")
                                }
                            } catch {
                                AJRLog.error("Failed to load \(filename).inspector: \(error.localizedDescription)")
                            }
                        }
                        newChoices.append(choice)
                    }
                }
                choices = newChoices
                updateMenu()
            }
        }
    }
    
    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("objects")
        keys.insert("value")
        keys.insert("choiceTitle")
        keys.insert("titleWhenNil")
    }
    
    // MARK: - Build View
    
    override open func buildView(from element: XMLElement) throws {
        objectsKeyPath = try AJRInspectorKeyPath(key: "objects", xmlElement: element, inspectorElement: self)
        valueKeyPath = try AJRInspectorKeyPath(key: "value", xmlElement: element, inspectorElement: self)
        choiceTitleKeyPath = try AJRInspectorKey(key: "choiceTitle", xmlElement: element, inspectorElement: self)
        titleWhenNilKeyPath = try AJRInspectorKey(key: "titleWhenNil", xmlElement: element, inspectorElement: self)

        if objectsKeyPath == nil {
            throw NSError(domain: AJRInspectorErrorDomain, message: "choice slices of type \"object\" must defined the \"objectsKeyPath\" attribute.")
        }
        if valueKeyPath == nil {
            throw NSError(domain: AJRInspectorErrorDomain, message: "choice slices of type \"object\" must defined the \"valueKeyPath\" attribute.")
        }

        if let children = element.children {
            for childNode in children {
                if let childNode = childNode as? XMLElement {
                    if childNode.name == "choice" {
                        choices.append(try AJRInspectorChoiceObject(element: childNode, slice: self, viewController: viewController!, bundle: bundle))
                    } else {
                        throw NSError(domain: AJRInspectorErrorDomain, message: "Only \"choice\" elements may appear as children of \"choice\" slices.")
                    }
                }
            }
            choicesAreExplicit = true
        } else {
            choicesAreExplicit = false
        }
        
        try super.buildView(from: element)

        // Make sure that if we're allowing nil, we also created the key to get nil's title.
        if allowsNilKey != nil && (allowsNilKey!.value!)  && titleWhenNilKeyPath == nil {
            throw NSError(domain: AJRInspectorErrorDomain, message: "choice slices of type \"object\" must define the \"titleWhenNil\" when \"allowsNil\" is true.")
        }

        weak var weakSelf = self
        objectsKeyPath?.addObserver {
            if let strongSelf = weakSelf {
                if let objects = strongSelf.objectsKeyPath.value {
                    strongSelf.objects = objects
                }
                strongSelf.updateDisplayedValue()
            }
        }
        valueKeyPath?.addObserver {
            weakSelf?.updateDisplayedValue()
        }
    }
    
    // MARK: - Utilities
    
    internal func updateMenu() -> Void {
        if let popUpButton = popUpButton {
            popUpButton.menu = updateMenu(menu: popUpButton.menu)
        } else if let comboBox = comboBox {
            comboBox.menu = updateMenu(menu: comboBox.menu)
        }
    }
    
    internal func updateMenu(menu: NSMenu?) -> NSMenu {
        let newMenu = menu ?? NSMenu(title: "")
        newMenu.removeAllItems()
        if allowsNilKey?.value ?? false {
            let title = titleWhenNilKeyPath?.value ?? "*nil*"
            let menuItem = newMenu.addItem(withTitle: title, action: #selector(AJRInspectorSliceChoice.selectChoice(_:)), keyEquivalent: "")
            menuItem.target = self
            menuItem.representedObject = try? AJRInspectorChoiceObject(object: nil, slice: self, viewController: self.viewController!)
        }
        for choice in choices {
            if let choice = choice as? AJRInspectorChoiceObject, choice.type == .object {
                newMenu.addItem(choice.menuItem)
            }
        }
        return newMenu
    }
    
    internal func updateDisplayedValue() -> Void {
        if popUpButton != nil {
            updatePopUpValue()
        } else if comboBox != nil {
            updateComboBoxValue()
        } else if segments != nil {
            // No effect, at least for right now.
        }
    }
    
    internal func updatePopUpValue() -> Void {
        if let popUpButton = popUpButton {
            var newChoice : AJRInspectorChoice? = nil
            popUpButton.menu = updateMenu(menu: popUpButton.menu)
            switch valueKeyPath?.selectionType ?? .none {
            case .none:
                popUpButton.isEnabled = true // Because unlike many of the other slices, when we're nil, that means our selection is nil
                popUpButton.title = AJRObjectInspectorViewController.translator["No Selection"]
                newChoice = choices.first(where: { (choice) -> Bool in
                    if let choice = choice as? AJRInspectorChoiceObject, choice.type == .noSelectionPlaceholder {
                        return true
                    }
                    return false
                })
            case .multiple:
                popUpButton.isEnabled = true
                popUpButton.title = AJRObjectInspectorViewController.translator["Multiple Selection"]
                newChoice = choices.first(where: { (choice) -> Bool in
                    if let choice = choice as? AJRInspectorChoiceObject, choice.type == .multipleSelectionPlaceholder {
                        return true
                    }
                    return false
                })
            case .single:
                newChoice = updateSelectedMenuItem()
            }
            displayChoice(newChoice)
        }
    }
    
    internal func updateSelectedMenuItem() -> AJRInspectorChoice? {
        var newChoice : AJRInspectorChoice? = nil

        if let popUpButton = popUpButton {
            var foundItem : NSMenuItem? = nil
            let value = valueKeyPath?.value

            for menuItem in popUpButton.menu?.items ?? [] {
                menuItem.state = .off
                if let choice = menuItem.representedObject as? AJRInspectorChoiceObject {
                    if AJREqual(value, choice.object) {
                        foundItem = menuItem
                        newChoice = choice
                        menuItem.state = .on
                    }
                }
            }
            if let foundItem = foundItem {
                popUpButton.select(foundItem)
            }
            popUpButton.isEnabled = true
        }
        if let comboBox = comboBox {
            let value = valueKeyPath?.value

            for menuItem in comboBox.menu?.items ?? [] {
                if let choice = menuItem.representedObject as? AJRInspectorChoiceObject {
                    if AJREqual(value, choice.object) {
                        newChoice = choice
                        break
                    }
                }
            }
        }
        
        return newChoice
    }
    
    internal func updateComboBoxValue() -> Void {
        if let comboBox = comboBox {
            var newChoice : AJRInspectorChoice? = nil
            comboBox.menu = updateMenu(menu: comboBox.menu)
            switch valueKeyPath?.selectionType ?? .none {
            case .none:
                comboBox.isEnabled = true // Because unlike many of the other slices, when we're nil, that means our selection is nil
                comboBox.stringValue = AJRObjectInspectorViewController.translator["No Selection"]
                newChoice = choices.first(where: { (choice) -> Bool in
                    if let choice = choice as? AJRInspectorChoiceObject, choice.type == .noSelectionPlaceholder {
                        return true
                    }
                    return false
                })
            case .multiple:
                comboBox.isEnabled = true
                comboBox.stringValue = AJRObjectInspectorViewController.translator["Multiple Selection"]
                newChoice = choices.first(where: { (choice) -> Bool in
                    if let choice = choice as? AJRInspectorChoiceObject, choice.type == .multipleSelectionPlaceholder {
                        return true
                    }
                    return false
                })
            case .single:
                newChoice = updateSelectedMenuItem()
                // TODO: This isn't right, and I'm not 100% sure if we can make it right, because the comboBox implies we'd have to "create" a new object if the user types something into the comboBox that isn't already part of our list. As such, comboBoxes may not be able to use the "object" variant. That being said, I'm not removing this code, because a solution might yet present itself.
                comboBox.stringValue = newChoice?.resolvedTitle ?? String(describing: valueKeyPath?.value)
            }
            displayChoice(newChoice)
        }
    }
    
    // MARK: - Actions
    
    @IBAction open override func selectChoice(_ sender: Any?) -> Void {
        if let menuItem = sender as? NSMenuItem, let choice = menuItem.representedObject as? AJRInspectorChoiceObject {
            if let activeChoice = activeChoice {
                if let choiceView = activeChoice.content?.view {
                    choiceView.removeFromSuperview()
                }
                activeChoice.content = nil
                // Make sure to set this to nil here, because otherwise will fault the view back in just to remove it.
                self.activeChoice = nil
            }
            self.valueKeyPath.value = choice.object
            // TODO: Shouldn't be necessary, because we update when we observe the above set.
            //displayChoice(choice)
        } else {
            displayChoice(nil)
        }
    }
    
}

