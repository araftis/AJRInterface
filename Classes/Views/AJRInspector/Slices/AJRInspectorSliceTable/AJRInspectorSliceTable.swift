/*
AJRInspectorSliceTable.swift
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

public extension NSUserInterfaceItemIdentifier {
    
    static var inspectorColumnBasicCell = NSUserInterfaceItemIdentifier("AJRInspectorColumnBasicCell")
    static var inspectorColumnBooleanCell = NSUserInterfaceItemIdentifier("AJRInspectorColumnBooleanCell")

}

@objcMembers
open class AJRBooleanTableCellView : NSTableCellView {
    
    @IBOutlet var checkBox : NSButton!
    
    open var alignmentConstraints = [NSLayoutConstraint]()
    
    open func completeInit() -> Void {
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        completeInit()
    }
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        completeInit()
    }
    
    override open func awakeFromNib() {
        updateAlignmentConstraints()
    }
    
    open func updateAlignmentConstraints() -> Void {
        for constraint in alignmentConstraints {
            self.removeConstraint(constraint)
        }
        switch alignment {
        case .right:
            alignmentConstraints = [
                self.leadingAnchor.constraint(greaterThanOrEqualTo: checkBox.leadingAnchor, constant: 2.0),
                checkBox.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 2.0),
            ]
        case .center:
            alignmentConstraints = [
                //self.leadingAnchor.constraint(greaterThanOrEqualTo: checkBox.leadingAnchor, constant: 2.0),
                //checkBox.trailingAnchor.constraint(greaterThanOrEqualTo: self.trailingAnchor, constant: 2.0),
                self.centerXAnchor.constraint(equalTo: checkBox.centerXAnchor),
            ]
        case .left:
            fallthrough
        default:
            alignmentConstraints = [
                self.leadingAnchor.constraint(equalTo: checkBox.leadingAnchor, constant: 2.0),
                checkBox.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 2.0),
            ]
        }
        self.addConstraints(alignmentConstraints)
    }
    
    public var alignment : NSTextAlignment = .left {
        didSet {
            updateAlignmentConstraints()
        }
    }
    
}

@objcMembers
open class AJRInspectorSliceTable: AJRInspectorSlice, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet open var tableView : NSTableView!
    @IBOutlet open var buttonTemplate : NSButton!

    open var dataSourceKeyPath : AJRInspectorKeyPath<NSTableViewDataSource>?
    open var delegateKeyPath : AJRInspectorKeyPath<NSTableViewDelegate>?
    open var actionTargetKey : AJRInspectorKeyPath<[AnyObject]>!
    open var addActionKey : AJRInspectorKey<Selector>?
    open var removeActionKey : AJRInspectorKey<Selector>?
    open var addMenuKeyPath : AJRInspectorKeyPath<NSMenu>?
    open var hasTitlesKey : AJRInspectorKey<Bool>?
    open var valuesKeyPath : AJRInspectorKeyPath<[AnyObject]>?
    open var usesAlternatingRowBackgroundColorsKey : AJRInspectorKey<Bool>!
    open var hasVerticalGridKey : AJRInspectorKey<Bool>!
    open var selectedRowIndexesKeyPath : AJRInspectorKeyPath<IndexSet>?
    open var selectedObjectsKeyPath : AJRInspectorKeyPath<[AnyObject]>?
    open var selectedObjectKeyPath : AJRInspectorKeyPath<AnyObject>?

    open var topAnchor : NSLayoutConstraint!
    open var bottomAnchor : NSLayoutConstraint!
    open var values = [AnyObject]()
    
    open var addButton : NSButton?
    open var removeButton : NSButton?
    
    open override var fullWidthInset : CGFloat {
        return -1.0
    }
    
    open var hasActionButtons : Bool {
        return addActionKey != nil || removeActionKey != nil || addMenuKeyPath != nil
    }

    open var columns = [AJRInspectorTableColumn]()

    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("dataSource")
        keys.insert("delegate")
        keys.insert("values")
        keys.insert("hasTitles")
        keys.insert("usesAlternatingRowBackgroundColors")
        keys.insert("hasVerticalGrid")
        keys.insert("actionTarget")
        keys.insert("addAction")
        keys.insert("removeAction")
        keys.insert("addMenu")
        keys.insert("selectedRowIndexes")
        keys.insert("selectedObjects")
        keys.insert("selectedObject")
    }
    
    // MARK: - View
    
    open override func buildView(from element: XMLElement) throws {
        dataSourceKeyPath = try AJRInspectorKeyPath(key: "dataSource", xmlElement: element, inspectorElement: self)
        delegateKeyPath = try AJRInspectorKeyPath(key: "delegate", xmlElement: element, inspectorElement: self)
        valuesKeyPath = try AJRInspectorKeyPath(key: "values", xmlElement: element, inspectorElement: self)
        hasTitlesKey = try AJRInspectorKey(key: "hasTitles", xmlElement: element, inspectorElement: self)
        usesAlternatingRowBackgroundColorsKey = try AJRInspectorKey(key: "usesAlternatingRowBackgroundColors", xmlElement: element, inspectorElement: self, defaultValue: true)
        hasVerticalGridKey = try AJRInspectorKey(key: "hasVerticalGrid", xmlElement: element, inspectorElement: self, defaultValue: true)
        actionTargetKey = try AJRInspectorKeyPath(key: "actionTarget", xmlElement: element, inspectorElement: self, defaultValue: [])
        addActionKey = try AJRInspectorKey(key: "addAction", xmlElement: element, inspectorElement: self)
        removeActionKey = try AJRInspectorKey(key: "removeAction", xmlElement: element, inspectorElement: self)
        addMenuKeyPath = try AJRInspectorKeyPath(key: "addMenu", xmlElement: element, inspectorElement: self)
        selectedRowIndexesKeyPath = try AJRInspectorKeyPath(key: "selectedRowIndexes", xmlElement: element, inspectorElement: self)
        selectedObjectsKeyPath = try AJRInspectorKeyPath(key: "selectedObjects", xmlElement: element, inspectorElement: self)
        selectedObjectKeyPath = try AJRInspectorKeyPath(key: "selectedObject", xmlElement: element, inspectorElement: self)

        for child in element.children ?? [] {
            if child.kind == .comment {
                // Ignore comments
                continue
            }
            if child.name == "column" {
                columns.append(try AJRInspectorTableColumn.create(from: child as! XMLElement, parent: self, viewController: viewController!, bundle: bundle))
            } else {
                throw NSError(domain: AJRInspectorErrorDomain, message: #"Only "column" elements may appear within "table" elements, found: \(child.name)"#)
            }
        }
        
        if columns.count == 0 {
            throw NSError(domain: AJRInspectorErrorDomain, message: "Table slices must define at least one column.")
        }

        try super.buildView(from: element)
        
        for column in tableView.tableColumns {
            tableView.removeTableColumn(column)
        }
        for column in columns {
            tableView.addTableColumn(column.tableColumn)
        }
        
        self.resizeColumnsToFit()
        
        weak var weakSelf = self
        dataSourceKeyPath?.addObserver {
            if let strongSelf = weakSelf {
                if let dataSource = strongSelf.dataSourceKeyPath?.value {
                    strongSelf.tableView.dataSource = dataSource
                } else {
                    strongSelf.tableView.dataSource = self
                }
            }
        }
        delegateKeyPath?.addObserver {
            if let strongSelf = weakSelf {
                if let delegate = strongSelf.delegateKeyPath?.value {
                    strongSelf.tableView.delegate = delegate
                } else {
                    strongSelf.tableView.delegate = self
                }
            }
        }
        hasTitlesKey?.addObserver {
            if let strongSelf = weakSelf {
                if strongSelf.hasTitlesKey?.value ?? true {
                    strongSelf.tableView.headerView = NSTableHeaderView()
                    strongSelf.tableView.tile()
                    strongSelf.topAnchor.constant = strongSelf.tableView.headerView?.frame.size.height ?? 0.0
                } else {
                    strongSelf.tableView.headerView = nil
                    strongSelf.topAnchor.constant = 0.0
                }
            }
        }
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
        if hasTitlesKey == nil {
            topAnchor.constant = tableView.headerView?.frame.size.height ?? 0.0
        }
        valuesKeyPath?.addObserver {
            if let strongSelf = weakSelf {
                if strongSelf.valuesKeyPath?.selectionType == .single {
                    strongSelf.values = strongSelf.valuesKeyPath?.value ?? []
                } else {
                    strongSelf.values = []
                }
                strongSelf.tableView.reloadData()
                strongSelf.updateButtons()
                strongSelf.updateSelection()
            }
        }
        selectedRowIndexesKeyPath?.addObserver {
            if let strongSelf = weakSelf {
                var selection : IndexSet? = nil
                if strongSelf.valuesKeyPath?.selectionType == .single {
                    selection = strongSelf.selectedRowIndexesKeyPath?.value
                } else {
                    selection = IndexSet()
                }
                if let selection = selection {
                    strongSelf.tableView.selectRowIndexes(selection, byExtendingSelection: false)
                }
            }
        }
        selectedObjectKeyPath?.addObserver {
            weakSelf?.updateSelection()
        }
        selectedObjectsKeyPath?.addObserver {
            if let strongSelf = weakSelf {
                var selection = IndexSet()
                if let selectedObjects = strongSelf.selectedObjectsKeyPath?.value {
                    selection =  strongSelf.values.indexes(ofObjectsIdenticalTo: selectedObjects)
                }
                strongSelf.tableView.selectRowIndexes(selection, byExtendingSelection: false)
            }
        }
        addMenuKeyPath?.addObserver {
            if let strongSelf = weakSelf {
                switch strongSelf.addMenuKeyPath?.selectionType {
                case .none?:
                    strongSelf.addButton?.isEnabled = false
                case .multiple:
                    strongSelf.addButton?.isEnabled = false
                case .single:
                    strongSelf.addButton?.isEnabled = true
                default:
                    strongSelf.addButton?.isEnabled = false
                }
            }
        }
        if hasActionButtons {
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
                }
                
                visualEffect.addSubview(floating)
                visualEffect.addConstraints([
                    floating.leftAnchor.constraint(equalTo: visualEffect.leftAnchor),
                    floating.rightAnchor.constraint(equalTo: visualEffect.rightAnchor),
                    floating.topAnchor.constraint(equalTo: visualEffect.topAnchor),
                    floating.bottomAnchor.constraint(equalTo: visualEffect.bottomAnchor),
                    ])
                
                var previousButton : NSButton?
                if addMenuKeyPath != nil {
                    previousButton = createButton(image: "AJRInspecrorSliceTableAdd", superview: floating, anchoredView: previousButton, action: #selector(popAddMenu(_:)))
                    previousButton?.sendAction(on: [.leftMouseDown])
                    addButton = previousButton
                } else if addActionKey?.value != nil {
                    previousButton = createButton(image: "AJRInspecrorSliceTableAdd", superview: floating, anchoredView: previousButton, action: #selector(add(_:)))
                    addButton = previousButton
                }
                if removeActionKey?.value != nil {
                    previousButton = createButton(image: "AJRInspectorSliceTableRemove", superview: floating, anchoredView: previousButton, action: #selector(remove(_:)))
                    removeButton = previousButton
                }
                
                scrollView.addFloatingSubview(visualEffect, for: .horizontal)
                scrollView.addConstraints([
                    visualEffect.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                    scrollView.trailingAnchor.constraint(equalTo: visualEffect.trailingAnchor),
                    scrollView.bottomAnchor.constraint(equalTo: visualEffect.bottomAnchor),
                    visualEffect.heightAnchor.constraint(equalToConstant: 18.0),
                    ])
                DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + DispatchTimeInterval.milliseconds(1), execute:{
                    self.bottomAnchor.constant = 17.0
                })
            }
            
        }
    }
    
    // MARK: - Utilities

    // There's a bit of a race condition where the selection won't be selected if the notification for the selection changing happens before the notification for the values changings. As such, we call this from both locations (values and selection change) to make sure the selection is correct.
    open func updateSelection() -> Void {
        var selection = IndexSet()
        if let selectedObject = selectedObjectKeyPath?.value {
            if let index = values.index(ofObjectIdenticalTo: selectedObject) {
                selection = IndexSet(integer: index)
            }
        }
        tableView.selectRowIndexes(selection, byExtendingSelection: false)
    }

    /** Called on selection change to update the add / remove buttons. Subclasses can override if they've added additoinal buttons that might need to be updated on selection change. */
    open func updateButtons() -> Void {
        if tableView.selectedRowIndexes.count != 0 {
            removeButton?.isEnabled = true
        } else {
            removeButton?.isEnabled = false
        }
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

    open func resizeColumnsToFit() -> Void {
        // Be careful here, we might get called before our xib is loaded.
        if let tableView = tableView {
            let spacing = tableView.intercellSpacing.width
            var resizableColumns = [AJRInspectorTableColumn]()
            let tableWidth = tableView.enclosingScrollView!.documentVisibleRect.size.width
            var totalWidth : CGFloat = 0.0
            
            for column in columns {
                if !column.hasWidth {
                    resizableColumns.append(column)
                    column.tableColumn.width = column.width
                } else {
                    totalWidth += column.width + spacing
                    column.tableColumn.width = column.width
                }
            }
            
            if totalWidth < tableWidth && resizableColumns.count > 0 {
                let availableWidth = tableWidth - totalWidth
                let doledWidth = floor(availableWidth / CGFloat(resizableColumns.count))
                var remainder = availableWidth - doledWidth * CGFloat(resizableColumns.count)
                
                for column in resizableColumns {
                    column.tableColumn.width = doledWidth + (remainder > 0 ? 1.0 : 0.0) - spacing
                    if remainder > 0 {
                        remainder -= 1.0
                    }
                }
            }
            tableView.tile()
        }
    }
    
    open var objects : [AnyObject] {
        return actionTargetKey.value!
    }
    
    // MARK: - Editing
    
    open func edit(column: AJRInspectorTableColumn, object: AnyObject) -> Void {
        if let columnIndex = tableView.tableColumns.index(ofObjectIdenticalTo: column.tableColumn),
            let rowIndex = values.index(ofObjectIdenticalTo: object) {
            print("edit: \(columnIndex) / \(rowIndex)")
            tableView.editColumn(columnIndex, row: rowIndex, with: nil, select: true)
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
        return values.count
    }
    
    open func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let columnIndex = tableView.tableColumns.index(ofObjectIdenticalTo: tableColumn!) ?? -1
        
        if columnIndex >= 0 {
            return columns[columnIndex].tableView(tableView, viewForColumn: columnIndex, row: row, object: values[row])
        }
        
        return nil
    }
    
    open func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        print("edit!")
    }
    
    open func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        if let tableColumn = tableColumn,
           let columnIndex = tableView.tableColumns.index(ofObjectIdenticalTo: tableColumn) {
            if let editableKey = columns[columnIndex].editableKey {
                return editableKey.value ?? false
            }
        }
        return false
    }
    
    open func tableViewSelectionDidChange(_ notification: Notification) {
        updateButtons()
        let indexes = tableView.selectedRowIndexes
        selectedRowIndexesKeyPath?.value = indexes
        if let selectedObjectKeyPath = selectedObjectKeyPath {
            selectedObjectKeyPath.value = indexes.count == 1 ? values[indexes.first!] : nil
        }
        if let selectedObjectsKeyPath = selectedObjectsKeyPath {
            let objects = values[indexes]
            selectedObjectsKeyPath.value = objects
        }
    }

    // MARK: - Actions
    
    @IBAction open func add(_ sender: Any?) -> Void {
        if let action = addActionKey?.value {
            var hasEdited = false // Used to make sure we only edit the "first" object.
            for object in objects {
                if let newObject = (object.perform(action))?.takeRetainedValue() {
                    if !hasEdited {
                        for column in columns {
                            if column.editOnAdd {
                                hasEdited = true
                                edit(column: column, object: newObject as AnyObject)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction open func popAddMenu(_ sender: Any?) -> Void {
        if addMenuKeyPath?.selectionType == .single,
            let menu = addMenuKeyPath?.value,
            menu.items.count > 0,
            let addButton = addButton {
            let bounds = addButton.bounds
            let point = NSPoint(x: bounds.origin.x, y: bounds.maxY)
            menu.popUp(positioning: menu.items[0], at: point, in: addButton)
        }
    }
    
    @IBAction open func remove(_ sender: Any?) -> Void {
        if let action = removeActionKey?.value {
            if let index = tableView.selectedRowIndexes.first {
                let selectedObject = values[index]
                for object in objects {
                    // This is a nasty hack, but ARC / Swift is becoming confused with this invocation causing an extra release to the object. At some point in the future, this could potentially cause a memory leak.
                    AJRForceRetain(selectedObject)
                    _ = object.perform(action, with: selectedObject)
                }
            }
        }
    }
    
}
