/*
AJRInspectorTableColumn.swift
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

import AJRFoundation
import Cocoa

private extension NSView {
    
    var enclosingTableCellView : NSTableCellView? {
        var view : NSView? = self
        while view != nil {
            if let view = view as? NSTableCellView {
                return view
            }
            view = view?.superview
        }
        return nil
    }
    
}

@objcMembers
open class AJRInspectorTableColumn: NSObject {
    
    open var typeKey : AJRInspectorKey<String>! // Will always be present and valid, so we don't need to worry about nil
    open var titleKey : AJRInspectorKey<String>?
    open var titleAlignmentKey : AJRInspectorKey<NSTextAlignment>?
    open var editableKey : AJRInspectorKey<Bool>?
    open var alignmentKey : AJRInspectorKey<NSTextAlignment>!
    open var widthKey : AJRInspectorKey<CGFloat>?
    open var editOnAddKey : AJRInspectorKey<Bool>!
    open var fontKey : AJRInspectorKey<NSFont>!
    
    open var type : String { return typeKey.value! }
    open var width : CGFloat { return widthKey?.value ?? 72.0 }
    open var hasWidth : Bool { return widthKey != nil }
    open var editOnAdd : Bool { return editOnAddKey.value! }
    
    open var tableColumn = NSTableColumn()
    open var parent : AJRInspectorSliceTable
    
    open var font : NSFont {
        if let font = fontKey?.value {
            return font
        }
        return NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small), weight: .regular)
    }

    open class func create(from element: XMLElement, parent: AJRInspectorElement, viewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main) throws -> AJRInspectorTableColumn {
        switch element.attribute(forName: "type")?.stringValue {
        case nil:
            throw NSError(domain: AJRInspectorErrorDomain, message: #"colum elements must specify a "type" attribute"#)
        case "integer":
            return try AJRInspectorTableColumnInteger(element: element, parent: parent, viewController: viewController, bundle: bundle)
        case "float":
            return try AJRInspectorTableColumnFloat(element: element, parent: parent, viewController: viewController, bundle: bundle)
        case "time":
            return try AJRInspectorTableColumnTimeInterval(element: element, parent: parent, viewController: viewController, bundle: bundle)
        case "string":
            return try AJRInspectorTableColumnString(element: element, parent: parent, viewController: viewController, bundle: bundle)
        case "boolean":
            return try AJRInspectorTableColumnBoolean(element: element, parent: parent, viewController: viewController, bundle: bundle)
        default:
            throw NSError(domain: AJRInspectorErrorDomain, message: #"Unknown type "type" in column: \(element.attribute(forName: "type")?.stringValue!)"#)
        }
    }
    
    public init(element: XMLNode, parent: AJRInspectorElement, viewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main) throws {
        if let parent = parent as? AJRInspectorSliceTable {
            self.parent = parent
        } else {
            throw NSError(domain: AJRInspectorErrorDomain, message: "The parent of an inspector table column must be a table slice.")
        }
        super.init()
    }
    
    open func tableView(_ tableView: NSTableView, viewForColumn column: Int, row: Int, object: AnyObject) -> NSView? {
        return nil
    }
    
}

@objcMembers
open class AJRInspectorTableColumnTyped<T: AJRInspectorValue> : AJRInspectorTableColumn {
    
    open var valueKey : AJRInspectorKey<T>?
    
    public override init(element: XMLNode, parent: AJRInspectorElement, viewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main) throws {
        try super.init(element: element, parent: parent, viewController: viewController, bundle: bundle)
        
        if let element = element as? XMLElement {
            typeKey = try AJRInspectorKey(key: "type", xmlElement: element, inspectorElement: parent)
            titleKey = try AJRInspectorKey(key: "title", xmlElement: element, inspectorElement: parent)
            titleAlignmentKey = try AJRInspectorKey(key: "titleAlignment", xmlElement: element, inspectorElement: parent)
            editableKey = try AJRInspectorKey(key: "editable", xmlElement: element, inspectorElement: parent)
            alignmentKey = try AJRInspectorKey(key: "alignment", xmlElement: element, inspectorElement: parent, defaultValue: .left)
            widthKey = try AJRInspectorKey(key: "width", xmlElement: element, inspectorElement: parent)
            valueKey = try AJRInspectorKey(key: "value", xmlElement: element, inspectorElement: parent)
            editOnAddKey = try AJRInspectorKey(key: "editOnAdd", xmlElement: element, inspectorElement: parent, defaultValue: false)
            fontKey = try AJRInspectorKey(key: "font", xmlElement: element, inspectorElement: parent)
            
            weak var weakSelf = self
            titleKey?.addObserver {
                if let strongSelf = weakSelf {
                    strongSelf.tableColumn.title = strongSelf.titleKey?.value ?? ""
                }
            }
            titleAlignmentKey?.addObserver {
                if let strongSelf = weakSelf {
                    strongSelf.tableColumn.headerCell.alignment = strongSelf.titleAlignmentKey?.value ?? .natural
                }
            }
            widthKey?.addObserver {
                if let strongSelf = weakSelf {
                    strongSelf.tableColumn.width = strongSelf.widthKey?.value ?? 72.0
                    strongSelf.parent.resizeColumnsToFit()
                }
            }
            
            self.parent.resizeColumnsToFit()
        }
    }
}

@objcMembers
open class AJRInspectorTableColumnFieldBased<T: AJRInspectorValue> : AJRInspectorTableColumnTyped<T> {
    
    open var formatter : Formatter? { return nil }
    
    open var objectsToTableView = NSMapTable<AnyObject, NSTableCellView>(keyOptions: [.weakMemory,.objectPointerPersonality], valueOptions: [.weakMemory, .objectPointerPersonality])

    deinit {
        if let keyPath = valueKey?.keyPath {
            for key in objectsToTableView.keyEnumerator() {
                (key as AnyObject).removeObserver(self, forKeyPath: keyPath)
            }
        }
    }
    
    open override func tableView(_ tableView: NSTableView, viewForColumn column: Int, row: Int, object: AnyObject) -> NSView? {
        let view : NSTableCellView = tableView.makeView(withIdentifier: .inspectorColumnBasicCell, owner: nil) as! NSTableCellView
        
        if let textField = view.textField {
            textField.stringValue = "\(column):\(row)"
            textField.alignment = alignmentKey.value!
            textField.isEditable = editableKey?.value ?? false
            textField.formatter = formatter
            textField.font = font
            if textField.isEditable {
                textField.target = self
                textField.action = #selector(takeValue(from:))
            }
            if let objectValue = view.objectValue, let keyPath = valueKey?.keyPath {
                //Swift.print("\(objectValue) remove observer")
                (objectValue as AnyObject).removeObserver(self, forKeyPath: keyPath)
                objectsToTableView.removeObject(forKey: objectValue as AnyObject)
            }
            view.objectValue = object
            if let keyPath = valueKey?.keyPath {
                //Swift.print("\(object) add observer for \(keyPath)")
                object.addObserver(self, forKeyPath: keyPath, options: [], context: nil)
                objectsToTableView.setObject(view, forKey: object)
            }

            updateDisplayedValue(from: object, in: view)
        }
        
        return view
    }
    
    @IBAction open func takeValue(from sender: Any?) -> Void {
        if let sender = sender as? NSView, let object = sender.enclosingTableCellView?.objectValue {
            setValue(from: sender, on: object as AnyObject)
        }
    }
    
    open func setValue(from sender: Any?, on object: AnyObject) -> Void {
        print("The value was editing, but the subclass didn't do anything about it.")
    }
    
    open func updateDisplayedValue(from object: AnyObject, in view: NSTableCellView) -> Void {
        print("value changed, but the subclass didn't do anything about it.")
    }
    
    // MARK: - NSKeyValueObserver
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, keyPath == valueKey?.keyPath {
            if let view = objectsToTableView.object(forKey: object as AnyObject) {
                updateDisplayedValue(from: object as AnyObject, in: view)
            }
        }
    }

}

@objcMembers
open class AJRInspectorTableColumnString : AJRInspectorTableColumnFieldBased<String> {
    
    override open func setValue(from sender: Any?, on object: AnyObject) -> Void {
        if let sender = sender as? NSTextField {
            valueKey?.setValue(sender.stringValue, on: object)
        }
    }
    
    override open func updateDisplayedValue(from object: AnyObject, in view: NSTableCellView) {
        if let valueKey = valueKey {
            if let value = valueKey.value(from: object) {
                view.textField?.stringValue = value
            } else {
                view.textField?.stringValue = ""
            }
        } else {
            // The object is its own value
            view.textField?.stringValue = String(describing: object)
        }
    }
    
}

@objcMembers
open class AJRInspectorTableColumnInteger : AJRInspectorTableColumnFieldBased<Int> {
    
    override open func setValue(from sender: Any?, on object: AnyObject) -> Void {
        if let sender = sender as? NSTextField {
            valueKey?.setValue(sender.integerValue, on: object)
        }
    }
    
    override open func updateDisplayedValue(from object: AnyObject, in view: NSTableCellView) {
        if let value = valueKey?.value(from: object) {
            view.textField?.integerValue = value
        } else {
            view.textField?.integerValue = 0
        }
    }
    
}

@objcMembers
open class AJRInspectorTableColumnFloat : AJRInspectorTableColumnFieldBased<Double> {
    
    override open func setValue(from sender: Any?, on object: AnyObject) -> Void {
        if let sender = sender as? NSTextField {
            valueKey?.setValue(sender.doubleValue, on: object)
        }
    }
    
    override open func updateDisplayedValue(from object: AnyObject, in view: NSTableCellView) {
        if let value = valueKey?.value(from: object) {
            view.textField?.doubleValue = value
        } else {
            view.textField?.doubleValue = 0
        }
    }
    
}

@objcMembers
open class AJRInspectorTableColumnTimeInterval : AJRInspectorTableColumnFieldBased<TimeInterval> {
    
    override open var formatter: Formatter? {
        return AJRTimeIntervalFormatter.shared
    }
    
    override open func setValue(from sender: Any?, on object: AnyObject) -> Void {
        if let sender = sender as? NSTextField {
            valueKey?.setValue(sender.objectValue as? TimeInterval, on: object)
        }
    }
    
    override open func updateDisplayedValue(from object: AnyObject, in view: NSTableCellView) {
        if let value = valueKey?.value(from: object) {
            view.textField?.objectValue = value
        } else {
            view.textField?.objectValue = 0
        }
    }
    
    override open var font : NSFont {
        return NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize(for: .small), weight: .regular)
    }
    
}

@objcMembers
open class AJRInspectorTableColumnBoolean : AJRInspectorTableColumnTyped<Bool> {
    
    open var labelKey : AJRInspectorKey<String>?
    
    public override init(element: XMLNode, parent: AJRInspectorElement, viewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main) throws {
        try super.init(element: element, parent: parent, viewController: viewController, bundle: bundle)
        if let element = element as? XMLElement {
            labelKey = try AJRInspectorKey(key: "label", xmlElement: element, inspectorElement: parent)
        }
    }
    
    open override func tableView(_ tableView: NSTableView, viewForColumn column: Int, row: Int, object: AnyObject) -> NSView? {
        let view = tableView.makeView(withIdentifier: .inspectorColumnBooleanCell, owner: nil) as! AJRBooleanTableCellView
        
        //view.checkBox.title = "\(column):\(row)"
        
        view.objectValue = object
        view.alignment = alignmentKey.value!
        if let title = labelKey?.value {
            view.checkBox.title = title
            view.checkBox.imagePosition = .imageLeft
        } else {
            view.checkBox.title = ""
            view.checkBox.imagePosition = .imageOnly
        }
        if let value = valueKey?.value(from: object) {
            view.checkBox.state = value ? .on : .off
        }
        view.checkBox.target = self
        view.checkBox.action = #selector(selectCheck(_:))
        
        return view
    }
    
    @IBAction open func selectCheck(_ sender: NSButton?) -> Void {
        if let view = sender?.superview as? AJRBooleanTableCellView, let object = view.objectValue as AnyObject? {
            valueKey?.setValue(sender?.state == .on ? true : false, on: object)
        }
    }
    
}
