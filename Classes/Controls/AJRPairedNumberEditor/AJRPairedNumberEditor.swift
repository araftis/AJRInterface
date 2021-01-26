//
//  AJRPairedNumberEditor.swift
//  AJRInterface
//
//  Created by AJ Raftis on 6/1/19.
//

import Cocoa

@objcMembers
@IBDesignable
open class AJRPairedNumberEditor: NSControl {

    open var leftField : NSTextField!
    open var leftLabelField : NSTextField!
    open var leftStepper : NSStepper!
    open var rightField : NSTextField!
    open var rightLabelField : NSTextField!
    open var rightStepper : NSStepper!
    open var linkedRatioButton : NSButton!
    
    open var computedRatio : Double? = nil
    
    open var showsLinkedRatioButton : Bool = true {
        didSet {
            rebuildViews()
        }
    }
    
    open var valuesAreRatioLinked : Bool = true {
        willSet {
            willChangeValue(forKey: "valuesAreRatioLinked")
        }
        didSet {
            linkedRatioButton.state = valuesAreRatioLinked ? .on : .off
            didChangeValue(forKey: "valuesAreRatioLinked")
            updateComputedRatio()
        }
    }
    
    open override var firstBaselineOffsetFromTop: CGFloat {
        return leftField.firstBaselineOffsetFromTop
    }
    
    open override var baselineOffsetFromBottom: CGFloat {
        return leftField.baselineOffsetFromBottom
    }
    
    open override var lastBaselineOffsetFromBottom: CGFloat {
        return leftField.lastBaselineOffsetFromBottom
    }
    
    open override var controlSize: NSControl.ControlSize {
        didSet {
            configureControlSettings()
        }
    }
    
    @IBInspectable open var leftLabel : String {
        get {
            return leftLabelField.stringValue
        }
        set {
            leftLabelField.stringValue = newValue
        }
    }
    
    @IBInspectable open var rightLabel : String {
        get {
            return rightLabelField.stringValue
        }
        set {
            rightLabelField.stringValue = newValue
        }
    }
    
    @IBInspectable open var leftIntegerValue : Int {
        get {
            return leftField.integerValue
        }
        set {
            leftField.integerValue = newValue
            leftStepper.integerValue = newValue
        }
    }
    
    @IBInspectable open var rightIntegerValue : Int {
        get {
            return rightField.integerValue
        }
        set {
            rightField.integerValue = newValue
            rightStepper.integerValue = newValue
        }
    }
    
    @IBInspectable open var leftDoubleValue : Double {
        get {
            return leftField.doubleValue
        }
        set {
            leftField.doubleValue = newValue
            leftStepper.doubleValue = newValue
        }
    }
    
    @IBInspectable open var rightDoubleValue : Double {
        get {
            return rightField.doubleValue
        }
        set {
            rightField.doubleValue = newValue
            rightStepper.doubleValue = newValue
        }
    }
    
    @IBInspectable open var minLeftValue : Double {
        get {
            return leftStepper.minValue
        }
        set {
            leftStepper.minValue = newValue
        }
    }
    
    @IBInspectable open var maxLeftValue : Double {
        get {
            return leftStepper.maxValue
        }
        set {
            leftStepper.maxValue = newValue
        }
    }
    
    @IBInspectable open var leftIncrement : Double {
        get {
            return leftStepper.increment
        }
        set {
            leftStepper.increment = newValue
        }
    }
    
    @IBInspectable open var minRightValue : Double {
        get {
            return rightStepper.minValue
        }
        set {
            rightStepper.minValue = newValue
        }
    }
    
    @IBInspectable open var maxRightValue : Double {
        get {
            return rightStepper.maxValue
        }
        set {
            rightStepper.maxValue = newValue
        }
    }
    
    @IBInspectable open var rightIncrement : Double {
        get {
            return rightStepper.increment
        }
        set {
            rightStepper.increment = newValue
        }
    }
    
    @IBInspectable open var sizeValue : CGSize {
        get {
            return CGSize(width: leftField.doubleValue, height: rightField.doubleValue)
        }
        set {
            leftDoubleValue = Double(newValue.width)
            rightDoubleValue = Double(newValue.height)
            showsLinkedRatioButton = true
            updateComputedRatio()
            leftLabel = translator["Width"]
            rightLabel = translator["Height"]
        }
    }
    
    @IBInspectable open var pointValue : CGPoint {
        get {
            return CGPoint(x: leftField.doubleValue, y: rightField.doubleValue)
        }
        set {
            leftDoubleValue = Double(newValue.x)
            rightDoubleValue = Double(newValue.y)
            showsLinkedRatioButton = false
            leftLabel = "X"
            rightLabel = "Y"
        }
    }
    
    @IBInspectable open override var isEnabled: Bool {
        didSet {
            leftField.isEnabled = super.isEnabled
            leftStepper.isEnabled = super.isEnabled
            leftLabelField.textColor = super.isEnabled ? .controlTextColor : .disabledControlTextColor
            linkedRatioButton.isEnabled = super.isEnabled
            var linkedImage = AJRImages.imageNamed("AJRImageSizeLinked", forClass: Self.self)
            var unlinkedImage = AJRImages.imageNamed("AJRImageSizeUnlinked", forClass: Self.self)
            if !super.isEnabled {
                linkedImage = linkedImage?.ajr_imageTinted(with: .gray)
                unlinkedImage = linkedImage?.ajr_imageTinted(with: .gray)
            }
            linkedRatioButton.image = unlinkedImage
            linkedRatioButton.alternateImage = linkedImage
            rightField.isEnabled = super.isEnabled
            rightStepper.isEnabled = super.isEnabled
            rightLabelField.textColor = super.isEnabled ? .controlTextColor : .disabledControlTextColor
        }
    }
    
    // MARK: - Image Utilities
    
    internal func image(named name: String, for control: NSControl) -> NSImage? {
        var image = AJRImages.imageNamed(name, forClass: Self.self)
        
        if let loaded = image {
            image = loaded.forAppearance(control.effectiveAppearance)
        }
        
        return image
    }
    
    // MARK: - Creation

    internal func completeInit() -> Void {
        let formatter = NumberFormatter()
        
        if leftField == nil {
            leftField = NSTextField(string: "")
            leftField.translatesAutoresizingMaskIntoConstraints = false
            leftField.alignment = .right
            leftField.formatter = formatter
            leftField.target = self
            leftField.action = #selector(takeLeftValue(_:))
            addSubview(leftField)
        }
        if leftLabelField == nil {
            leftLabelField = NSTextField(labelWithString: "Left")
            leftLabelField.translatesAutoresizingMaskIntoConstraints = false
            addSubview(leftLabelField)
        }
        if leftStepper == nil {
            leftStepper = NSStepper(frame: .zero)
            leftStepper.translatesAutoresizingMaskIntoConstraints = false
            leftStepper.target = self
            leftStepper.action = #selector(takeLeftValue(_:))
            addSubview(leftStepper)
        }
        if rightField == nil {
            rightField = NSTextField(string: "")
            rightField.translatesAutoresizingMaskIntoConstraints = false
            rightField.alignment = .right
            rightField.formatter = formatter
            rightField.target = self
            rightField.action = #selector(takeRightValue(_:))
            addSubview(rightField)
        }
        if rightLabelField == nil {
            rightLabelField = NSTextField(labelWithString: "Right")
            rightLabelField.translatesAutoresizingMaskIntoConstraints = false
            addSubview(rightLabelField)
        }
        if rightStepper == nil {
            rightStepper = NSStepper(frame: .zero)
            rightStepper.translatesAutoresizingMaskIntoConstraints = false
            rightStepper.target = self
            rightStepper.action = #selector(takeRightValue(_:))
            addSubview(rightStepper)
        }
        if linkedRatioButton == nil {
            linkedRatioButton = NSButton(checkboxWithTitle: "", target: self, action: #selector(toggleLinked(_:)))
            linkedRatioButton.translatesAutoresizingMaskIntoConstraints = false
            linkedRatioButton.imagePosition = .imageOnly
            linkedRatioButton.image = AJRImages.imageNamed("AJRImageSizeUnlinked", forClass: Self.self)
            linkedRatioButton.alternateImage = AJRImages.imageNamed("AJRImageSizeLinked", forClass: Self.self)
        }
        
        configureControlSettings()

        rebuildViews()
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        completeInit()
        self.sizeValue = .zero
        self.minLeftValue = 0
        self.maxLeftValue = 5000
        self.leftIncrement = 1
        self.minRightValue = 0
        self.maxRightValue = 5000
        self.rightIncrement = 1
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        completeInit()

        self.minLeftValue = coder.decodeDouble(forKey: "minLeftValue", defaultValue: 0.0)
        self.maxLeftValue = coder.decodeDouble(forKey: "maxLeftValue", defaultValue: 5000.0)
        self.leftIncrement = coder.decodeDouble(forKey: "leftIncrement", defaultValue: 1.0)
        self.minRightValue = coder.decodeDouble(forKey: "minRightValue", defaultValue: 0.0)
        self.maxRightValue = coder.decodeDouble(forKey: "maxRightValue", defaultValue: 5000.0)
        self.rightIncrement = coder.decodeDouble(forKey: "rightIncrement", defaultValue: 1.0)
        self.leftDoubleValue = coder.decodeDouble(forKey: "leftDoubleValue", defaultValue: 0.0)
        self.rightDoubleValue = coder.decodeDouble(forKey: "rightDoubleValue", defaultValue: 0.0)
    }
    
    override open func encode(with coder: NSCoder) {
        let currentSubviews = subviews
        subviews = []
        super.encode(with: coder)
        subviews = currentSubviews
        
        coder.encode(minLeftValue, forKey: "minLeftValue")
        coder.encode(maxLeftValue, forKey: "maxLeftValue")
        coder.encode(leftIncrement, forKey: "leftIncrement")
        coder.encode(minRightValue, forKey: "minRightValue")
        coder.encode(maxRightValue, forKey: "maxRightValue")
        coder.encode(rightIncrement, forKey: "rightIncrement")
        coder.encode(leftDoubleValue, forKey: "leftDoubleValue")
        coder.encode(rightDoubleValue, forKey: "rightDoubleValue")
    }
    
    // MARK: - Utilities
    
    open func updateComputedRatio() -> Void {
        if showsLinkedRatioButton && rightDoubleValue != 0.0 {
            computedRatio = abs(leftDoubleValue) / abs(rightDoubleValue)
        } else {
            computedRatio = nil
        }
    }
    
    open func configureControlSettings() -> Void {
        leftField.controlSize = controlSize
        leftStepper.controlSize = controlSize
        rightField.controlSize = controlSize
        rightStepper.controlSize = controlSize
        linkedRatioButton.controlSize = controlSize

        switch controlSize {
        case .mini:
            leftLabelField.controlSize = .mini
            rightLabelField.controlSize = .mini
        case .small:
            leftLabelField.controlSize = .mini
            rightLabelField.controlSize = .mini
        case .regular:
            leftLabelField.controlSize = .small
            rightLabelField.controlSize = .small
        case .large:
            if #available(OSX 11.0, *) {
                leftLabelField.controlSize = .large
                rightLabelField.controlSize = .large
            } else {
                // Fallback on earlier versions
            }
        @unknown default:
            leftLabelField.controlSize = controlSize
            rightLabelField.controlSize = controlSize
        }
        leftLabelField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: leftLabelField.controlSize), weight: .light)
        rightLabelField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: rightLabelField.controlSize), weight: .light)
    }
    
    open func rebuildViews() -> Void {
        removeConstraints(constraints)

        if showsLinkedRatioButton {
            if linkedRatioButton.superview == nil {
                addSubview(linkedRatioButton)
            }
        } else {
            if linkedRatioButton.superview != nil {
                linkedRatioButton.removeFromSuperview()
            }
        }

        addConstraints([
            leftField.leadingAnchor.constraint(equalTo: leadingAnchor),
            leftField.topAnchor.constraint(equalTo: topAnchor),
            leftLabelField.topAnchor.constraint(equalTo: leftField.bottomAnchor, constant: 0.0),
            leftLabelField.centerXAnchor.constraint(equalTo: leftField.centerXAnchor),
            leftLabelField.bottomAnchor.constraint(equalTo: bottomAnchor),
            leftStepper.centerYAnchor.constraint(equalTo: leftField.centerYAnchor),
            leftStepper.leadingAnchor.constraint(equalTo: leftField.trailingAnchor, constant: 0.0),
            rightField.topAnchor.constraint(equalTo: leftField.topAnchor),
            rightField.widthAnchor.constraint(equalTo: leftField.widthAnchor),
            rightLabelField.topAnchor.constraint(equalTo: rightField.bottomAnchor, constant: 0.0),
            rightLabelField.centerXAnchor.constraint(equalTo: rightField.centerXAnchor),
            rightStepper.centerYAnchor.constraint(equalTo: rightField.centerYAnchor),
            rightStepper.leadingAnchor.constraint(equalTo: rightField.trailingAnchor),
            rightStepper.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
        
        if showsLinkedRatioButton {
            addConstraints([
                linkedRatioButton.centerYAnchor.constraint(equalTo: leftStepper.centerYAnchor),
                linkedRatioButton.leadingAnchor.constraint(equalTo: leftStepper.trailingAnchor, constant: 4.0),
                rightField.leadingAnchor.constraint(equalTo: linkedRatioButton.trailingAnchor, constant: 4.0),
                ])
        } else {
            addConstraints([
                rightField.leadingAnchor.constraint(equalTo: leftStepper.trailingAnchor, constant: 4.0),
                ])
        }
    }
    
    // MARK: - NSView
    
//    override open func draw(_ dirtyRect: NSRect) {
//        NSColor.red.set()
//        NSBezierPath(crossedRect: bounds)?.stroke()
//    }
    
    // MARK: - Actions
    
    @IBAction open func toggleLinked(_ sender: NSButton!) -> Void {
        if sender.state == .on {
            valuesAreRatioLinked = true
        } else {
            valuesAreRatioLinked = false
        }
    }
    
    @IBAction open func takeLeftValue(_ sender: NSControl!) -> Void {
        let value = sender.doubleValue
        
        leftField.doubleValue = value
        leftStepper.doubleValue = value
        
        if valuesAreRatioLinked,
            let computedRatio = computedRatio {
            let ratioValue = value / computedRatio
            rightField.doubleValue = ratioValue
            rightStepper.doubleValue = ratioValue
        }
        
        if let action = action {
            NSApp.sendAction(action, to: target, from: self)
        }
    }
    
    @IBAction open func takeRightValue(_ sender: NSControl!) -> Void {
        let value = sender.doubleValue
        
        rightField.doubleValue = value
        rightStepper.doubleValue = value
        
        if valuesAreRatioLinked,
            let computedRatio = computedRatio {
            let ratioValue = value * computedRatio
            leftField.doubleValue = ratioValue
            leftStepper.doubleValue = ratioValue
        }

        if let action = action {
            NSApp.sendAction(action, to: target, from: self)
        }
    }
    
}
