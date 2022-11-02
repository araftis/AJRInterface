/*
 AJRInspectorSliceStore.swift
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

extension NSUserInterfaceItemIdentifier {
    static var variableColumn = NSUserInterfaceItemIdentifier("variableColumn")
    static var typeColumn = NSUserInterfaceItemIdentifier("typeColumn")
    static var valueColumn = NSUserInterfaceItemIdentifier("valueColumn")
}

extension AJRStore : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        preconditionFailure("AJRStore must always use keyPaths.")
    }
    
    @nonobjc
    public static func inspectorValue(from value: NSValue) -> Any? {
        preconditionFailure("AJRStore must always use keyPaths.")
    }
    
}

internal extension NSMenu {

    func menuItem(with variableType: AJRVariableType) -> NSMenuItem? {
        for menuItem in self.items {
            if let possible = menuItem.representedObject as? AJRVariableType {
                if possible === variableType {
                    return menuItem
                }
            }
        }
        return nil
    }

}

@objcMembers
open class AJRInspectorSliceStore: AJRInspectorSlice, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet open var tableView : NSTableView!
    @IBOutlet open var buttonTemplate : NSButton!

    open var usesAlternatingRowBackgroundColorsKey : AJRInspectorKey<Bool>!
    open var hasVerticalGridKey : AJRInspectorKey<Bool>!
    open var valueKeyPath : AJRInspectorKey<AJRStore>!
    open var storeObserverToken : AJRInvalidation? = nil

    open var topAnchor : NSLayoutConstraint!
    open var bottomAnchor : NSLayoutConstraint!
    
    open var addButton : NSButton?
    open var removeButton : NSButton?

    internal static func createMenu(target: AnyObject, action: Selector) -> NSMenu {
        let menu = NSMenu(title: "Variables")

        for variableType in AJRVariableType.types {
            if variableType.availableInUI {
                let menuItem = menu.addItem(withTitle: variableType.localizedDisplayName, action: action, keyEquivalent: "")
                menuItem.representedObject = variableType
                menuItem.target = target
            }
        }

        return menu
    }

    lazy open var menu : NSMenu = AJRInspectorSliceStore.createMenu(target: self, action: #selector(add(_:)))

    // MARK: - AJRInspectorSlice
    
    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("value")
        keys.insert("usesAlternatingRowBackgroundColors")
        keys.insert("hasVerticalGrid")
    }
    
    // MARK: - View
    
    open override func buildView(from element: XMLElement) throws {
        valueKeyPath = try AJRInspectorKey(key: "value", xmlElement: element, inspectorElement: self)
        usesAlternatingRowBackgroundColorsKey = try AJRInspectorKey(key: "usesAlternatingRowBackgroundColors", xmlElement: element, inspectorElement: self, defaultValue: true)
        hasVerticalGridKey = try AJRInspectorKey(key: "hasVerticalGrid", xmlElement: element, inspectorElement: self, defaultValue: true)

        try super.buildView(from: element)
        
        self.resizeColumnsToFit()
        
        weak var weakSelf = self
        usesAlternatingRowBackgroundColorsKey.addObserver {
            if let strongSelf = weakSelf {
                strongSelf.tableView.usesAlternatingRowBackgroundColors = strongSelf.usesAlternatingRowBackgroundColorsKey.value!
            }
        }
        hasVerticalGridKey.addObserver {
            if let strongSelf = weakSelf {
                if strongSelf.hasVerticalGridKey.value! {
                    strongSelf.tableView.gridStyleMask = [.solidVerticalGridLineMask]
                } else {
                    strongSelf.tableView.gridStyleMask = []
                }
            }
        }
        valueKeyPath?.addObserver {
            if let strongSelf = weakSelf {
                if let token = strongSelf.storeObserverToken {
                    AJRLog.info("token: \(token)")
                    token.invalidate()
                    strongSelf.storeObserverToken = nil
                }
                if let newStore = self.valueKeyPath?.value {
                    strongSelf.storeObserverToken = newStore.addObserver(newStore, forKeyPath: "symbols", block: { object, key, changes in
                        if let kind = changes?[.kindKey] as? Int {
                            if kind > 1 {
                                strongSelf.tableView?.reloadData()
                            }
                        }
                    })
                }
                strongSelf.tableView.reloadData()
                strongSelf.updateButtons()
            }
        }
        
        tableView.headerView = AJRInspectorTableHeader()
        if let headerView = tableView.headerView {
            var frame = headerView.frame
            frame.size.height = 21
            headerView.frame = frame
            tableView.tile()
            topAnchor.constant = headerView.frame.size.height
        }

        // Add mah buttons.
        if let scrollView = tableView.enclosingScrollView {
            let visualEffect = NSVisualEffectView(frame: NSRect(x: 0.0, y: 0.0, width: 18.0, height: 18.0))
            visualEffect.translatesAutoresizingMaskIntoConstraints = false
            visualEffect.material = .contentBackground
            let floating = AJRBlockDrawingView(frame: NSRect(x: 0.0, y: 0.0, width: 18.0, height: 18.0))
            floating.translatesAutoresizingMaskIntoConstraints = false
            floating.contentRenderer = { (context, bounds) in
                NSColor.alternatingContentBackgroundColors[1].set()
                context.fill(bounds)
                NSColor.gridColor.set()
                context.strokeLineSegments(between: [CGPoint(x: 0.0, y: bounds.size.height - 0.5), CGPoint(x: bounds.size.width, y: bounds.size.height - 0.5)])
                //AJRBezierPath(crossedRect: bounds).stroke(color: NSColor.red)
            }
            
            visualEffect.addSubview(floating)
            visualEffect.addConstraints([
                floating.leftAnchor.constraint(equalTo: visualEffect.leftAnchor),
                floating.rightAnchor.constraint(equalTo: visualEffect.rightAnchor),
                floating.topAnchor.constraint(equalTo: visualEffect.topAnchor),
                floating.bottomAnchor.constraint(equalTo: visualEffect.bottomAnchor),
                ])
            
            addButton = createButton(image: "AJRInspecrorSliceTableAdd", superview: floating, anchoredView: nil, action: #selector(popAddMenu(_:)))
            addButton?.sendAction(on: [.leftMouseDown])
            removeButton = createButton(image: "AJRInspectorSliceTableRemove", superview: floating, anchoredView: addButton, action: #selector(remove(_:)))
            
            scrollView.addFloatingSubview(visualEffect, for: .horizontal)
            if let superview = visualEffect.superview {
                scrollView.addConstraints([
                    visualEffect.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    superview.trailingAnchor.constraint(equalTo: visualEffect.trailingAnchor),
                    superview.bottomAnchor.constraint(equalTo: visualEffect.bottomAnchor),
                    visualEffect.heightAnchor.constraint(equalToConstant: 18.0),
                ])
            }
            DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + DispatchTimeInterval.milliseconds(1)) {
                self.bottomAnchor.constant = 17.0
            }
        }
    }
    
    /** Called on selection change to update the add / remove buttons. Subclasses can override if they've added additoinal buttons that might need to be updated on selection change. */
    open func updateButtons() -> Void {
        if tableView.selectedRowIndexes.count != 0 {
            removeButton?.isEnabled = true
        } else {
            removeButton?.isEnabled = false
        }
    }
    
    // MARK: - NSNibAwakening
    
    open override func awakeFromNib() -> Void {
        super.awakeFromNib()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        if let clipView = tableView.enclosingScrollView?.contentView {
            topAnchor = tableView.topAnchor.constraint(equalTo: clipView.topAnchor, constant: 0.0)
            bottomAnchor = clipView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 0.0)
            clipView.addConstraints([
                tableView.leftAnchor.constraint(equalTo: clipView.leftAnchor),
                tableView.rightAnchor.constraint(equalTo: clipView.rightAnchor),
                topAnchor,
                bottomAnchor,
                ])
            tableView.addConstraint(tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: (tableView.rowHeight + tableView.intercellSpacing.height) * 3.0))
        }
        
        if let scrollView = tableView.enclosingScrollView {
            scrollView.postsFrameChangedNotifications = true
            weak var weakSelf = self
            NotificationCenter.default.addObserver(forName: NSView.frameDidChangeNotification, object: scrollView, queue: nil) { (notification) in
                weakSelf?.resizeColumnsToFit()
            }
        }
    }

    // MARK: - NSTableViewDataSource
    
    open func numberOfRows(in tableView: NSTableView) -> Int {
        return valueKeyPath.value?.count ?? 0
    }

    internal func name(at index: Int) -> String? {
        if let store = valueKeyPath?.value {
            return store.orderedName(at: index)
        }
        return nil
    }

    internal func variable(at index: Int) -> AJRVariable? {
        if let store = valueKeyPath?.value {
            return store.orderedSymbol(at: index) as? AJRVariable
        }
        return nil
    }

    open func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let columnIndex = tableView.tableColumns.index(ofObjectIdenticalTo: tableColumn!) ?? -1
        var view : NSView? = nil

        if let variable = variable(at: row) {
            if columnIndex == 0 {
                view = tableView.makeView(withIdentifier: .variableColumn, owner: nil)
            } else if columnIndex == 1 {
                view = tableView.makeView(withIdentifier: .typeColumn, owner: nil)
            } else if columnIndex == 2 {
                let identifier = variable.variableType.editorViewIdentifer(for: tableView)
                view = tableView.makeView(withIdentifier: identifier, owner: nil)
                if view == nil {
                    AJRLog.warning("Failed to load nib for variable type: \(variable.variableType.name). Make sure you've set the Identity -> Identifier of your NSTableViewCell subclass in your xib, as that's one of the more common reasons for this to happen.")
                }
            }

            if let view = view as? NSTableCellView {
                view.objectValue = variable
            }
        }

        return view
    }
    
    open func tableViewSelectionDidChange(_ notification: Notification) {
        updateButtons()
    }

    // MARK: - Utilities
    
    internal func resizeColumnsToFit() -> Void {
    }

    internal func createButton(image name: String, superview: NSView, anchoredView: NSView?, margin: CGFloat = 0.0, action: Selector?) -> NSButton {
        let image = AJRImages.imageNamed(name, for: self) ?? NSImage(named: name)!
        let button = buttonTemplate.copy(toSubclass: NSButton.self)!
        button.image = image
        button.alternateImage = image.ajr_imageTinted(with: NSColor.selectedContentBackgroundColor)
        button.target = self
        button.action = action
        button.addConstraints([
            button.widthAnchor.constraint(equalToConstant: 16.0),
            button.heightAnchor.constraint(equalToConstant: 16.0),
            ])
        if let anchoredView = anchoredView {
            superview.addConstraints([
                button.leftAnchor.constraint(equalTo: anchoredView.rightAnchor, constant: margin),
                button.centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: 0.0),
                ])
        } else {
            superview.addConstraints([
                button.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: 1.0),
                button.centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: 0.0),
                ])
        }
        superview.addSubview(button);
        
        return button
    }

    // MARK: - Actions
    
    @IBAction open func popAddMenu(_ sender: Any?) -> Void {
        if valueKeyPath?.selectionType == .single,
           let addButton {
            let bounds = addButton.bounds
            let point = NSPoint(x: bounds.origin.x, y: bounds.maxY)
            menu.popUp(positioning: menu.items[0], at: point, in: addButton)
        }
    }
    
    @IBAction open func add(_ sender: NSMenuItem?) -> Void {
        if let variableType = sender?.representedObject as? AJRVariableType {
            if let store = valueKeyPath?.value {
                let value = variableType.createDefaultValue()
                if let variable = store.createVariable(named: variableType.name, type: variableType, value: value) {
                    AJRLog.info("added: \(variable)")
                    if let index = store.orderedIndex(for: variable) {
                        tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
                        updateButtons()
                    }
                }
            }
        }
    }

    @IBAction open func remove(_ sender: Any?) -> Void {
        if let store = valueKeyPath?.value {
            let indexes = tableView.selectedRowIndexes

            for index in indexes {
                let name = store.orderedName(at: index)
                store.removeSymbol(named: name)
            }

            if let firstIndex = indexes.first {
                if firstIndex < tableView.numberOfRows {
                    tableView.selectRowIndexes(IndexSet(integer: firstIndex), byExtendingSelection: false)
                } else if tableView.numberOfRows  > 0 {
                    tableView.selectRowIndexes(IndexSet(integer: tableView.numberOfRows - 1), byExtendingSelection: false)
                }
            }
            updateButtons()
        }
    }

}

internal extension NSTableCellView {
    
    func reloadDataSavingSelection() {
        if let tableView = enclosingView(type: NSTableView.self) {
            let selection = tableView.selectedRowIndexes
            tableView.reloadData()
            tableView.selectRowIndexes(selection, byExtendingSelection: false)
        }
    }
    
}

internal class AJRVariableTypeNameTableCellView : NSTableCellView, NSTextFieldDelegate, AJRVariableListener {

    open override var objectValue: Any? {
        willSet {
            if let variable = objectValue as? AJRVariable {
                variable.removeListener(self)
            }
        }
        didSet {
            if let variable = objectValue as? AJRVariable {
                textField?.stringValue = variable.name
                textField?.isEditable = true
                textField?.delegate = self
                variable.addListener(self)
            }
        }
    }

    open func variable(_ variable: AJRVariable, willChange change: AJRVariable.ChangeType) {
    }

    open func variable(_ variable: AJRVariable, didChange change: AJRVariable.ChangeType) {
        if change == .name,
           let variable = objectValue as? AJRVariable,
           let textField {
            textField.stringValue = variable.name
        }
    }

    @IBAction open func nameDidEdit(_ sender: NSTextField?) -> Void {
        if let textField,
           let variable = objectValue as? AJRVariable {
            let newName = textField.stringValue
            if newName.isEmpty {
                textField.stringValue = variable.name
            } else {
                if variable.name != newName {
                    variable.name = newName
                }
            }
        }
    }

    open func controlTextDidEndEditing(_ obj: Notification) {
        nameDidEdit(textField)
    }
}

@objcMembers
open class AJRVariableValueTableCellView : NSTableCellView, AJRVariableListener {

    /// Retypes `objectValue` as an `AJRVariable`.
    open var variable : AJRVariable? {
        get {
            return objectValue as? AJRVariable
        }
        set {
            objectValue = newValue
        }
    }

    open override var objectValue: Any? {
        willSet {
            variable?.removeListener(self)
        }
        didSet {
            if let variable {
                variable.addListener(self)
                variableDidChangeValue(variable)
            }
        }
    }

    open func variable(_ variable: AJRVariable, willChange change: AJRVariable.ChangeType) {
        if change == .value {
            variableWillChangeValue(variable)
        }
    }

    open func variable(_ variable: AJRVariable, didChange change: AJRVariable.ChangeType) {
        if change == .value {
            variableDidChangeValue(variable)
        }
    }

    open func variableWillChangeValue(_ variable: AJRVariable) {
    }

    open func variableDidChangeValue(_ variable: AJRVariable) {
    }

}

internal class AJRVariableTypeTableCellView : NSTableCellView, AJRVariableListener {

    @IBOutlet var typePopUpButton : NSPopUpButton!

    open override var objectValue: Any? {
        willSet {
            if let variable = objectValue as? AJRVariable {
                variable.removeListener(self)
            }
        }
        didSet {
            if let popUp = typePopUpButton,
               let variable = objectValue as? AJRVariable {
                popUp.menu = AJRInspectorSliceStore.createMenu(target: self, action: #selector(changeVariableType(_:)))
                if let item = popUp.menu?.menuItem(with: variable.variableType) {
                    popUp.select(item)
                }
                variable.addListener(self)
            }
        }
    }

    @IBAction func changeVariableType(_ sender: NSMenuItem?) -> Void {
        if let variableType = sender?.representedObject as? AJRVariableType,
           let variable = objectValue as? AJRVariable {
            variable.variableType = variableType
            // For now, we're not going to try and do any conversion here. We'll just revert to the default value.
            variable.value = variableType.createDefaultValue()
            reloadDataSavingSelection()
        }
    }

    open func variable(_ variable: AJRVariable, willChange change: AJRVariable.ChangeType) {
    }

    open func variable(_ variable: AJRVariable, didChange change: AJRVariable.ChangeType) {
        if change == .variableType,
           let variable = objectValue as? AJRVariable,
           let popUp = typePopUpButton {
            if let item = popUp.menu?.menuItem(with: variable.variableType) {
                popUp.select(item)
            }
        }
    }

}
