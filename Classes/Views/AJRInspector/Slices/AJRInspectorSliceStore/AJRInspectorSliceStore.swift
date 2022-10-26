//
//  AJRInspectorSliceStore.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/19/22.
//

import Cocoa

extension AJRStore : AJRInspectorValue {
    
    public static func inspectorValue(from string: String) -> Any? {
        preconditionFailure("AJRStore must always use keyPaths.")
    }
    
    @nonobjc
    public static func inspectorValue(from value: NSValue) -> Any? {
        preconditionFailure("AJRStore must always use keyPaths.")
    }
    
}

@objcMembers
open class AJRInspectorSliceStore: AJRInspectorSlice, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet open var tableView : NSTableView!
    @IBOutlet open var buttonTemplate : NSButton!

    open var usesAlternatingRowBackgroundColorsKey : AJRInspectorKey<Bool>!
    open var hasVerticalGridKey : AJRInspectorKey<Bool>!
    open var valueKeyPath : AJRInspectorKey<AJRStore>!

    open var topAnchor : NSLayoutConstraint!
    open var bottomAnchor : NSLayoutConstraint!
    
    open var addButton : NSButton?
    open var removeButton : NSButton?
    
    lazy open var menu : NSMenu = {
        let menu = NSMenu(title: "Variables")
        
        for variableType in AJRVariableType.types {
            if variableType.availableInUI {
                let menuItem = menu.addItem(withTitle: variableType.localizedDisplayName, action: #selector(add(_:)), keyEquivalent: "")
                menuItem.representedObject = variableType
                menuItem.target = self
            }
        }
        
        return menu
    }()

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
    
    open func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let columnIndex = tableView.tableColumns.index(ofObjectIdenticalTo: tableColumn!) ?? -1
        
        
        return nil
    }
    
    open func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        print("edit!")
    }
    
    open func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        if let tableColumn = tableColumn,
           let columnIndex = tableView.tableColumns.index(ofObjectIdenticalTo: tableColumn) {
            return true
        }
        return false
    }
    
    open func tableViewSelectionDidChange(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(secondsFromNow: 0.01)) { [self] in
        }
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
            AJRLog.info("add: \(variableType.name)")
        }
    }

    @IBAction open func remove(_ sender: Any?) -> Void {
        AJRLog.info("remove!")
    }
    
}
