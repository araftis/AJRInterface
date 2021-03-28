
import Cocoa

@objcMembers
open class AJRInspectorSliceNumber: AJRInspectorSlice {

    @IBOutlet open var numberField : NSTextField!
    @IBOutlet open var stepper : NSStepper!
    @IBOutlet open var subtitleField : NSTextField? // Only set if we have a subtitle key.
    
    open var enabledKey : AJRInspectorKey<Bool>?
    open var subtitleKey : AJRInspectorKey<String>?
    open var valueWhenNilKey : AJRInspectorKey<String>!
    open var mergeWithRightKey : AJRInspectorKey<Bool>?

    open override class func createSlice(from element: XMLElement, parent: AJRInspectorElement, viewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main) throws -> AJRInspectorSlice {
        let valueType = element.attribute(forName: "type")?.stringValue
        switch valueType {
        case "integer":
            return try AJRInspectorSliceInteger(element: element, parent: parent, viewController: viewController, bundle: bundle)
        case "float":
            return try AJRInspectorSliceFloat(element: element, parent: parent, viewController: viewController, bundle: bundle)
        case "timeInterval":
            return try AJRInspectorSliceTimeInterval(element: element, parent: parent, viewController: viewController, bundle: bundle)
        default:
            throw NSError(domain: AJRInspectorErrorDomain, message: "Unknown choice type: \(valueType!)")
        }
    }

    open var wantsMergeWithRight : Bool {
        if let mergeWithRightKey = mergeWithRightKey {
            return mergeWithRightKey.value ?? false
        }
        return false
    }

}

@objcMembers
open class AJRInspectorSliceNumberTyped<T: AJRInspectorValue>: AJRInspectorSliceNumber {

    open var valueKey : AJRInspectorKey<T>?
    open var minValueKey : AJRInspectorKey<T>?
    open var maxValueKey : AJRInspectorKey<T>?
    open var incrementKey : AJRInspectorKey<T>?
    
    open override var isMerged: Bool {
        didSet {
            //updateDisplayedValue()
        }
    }
    
    // Merging
    @IBOutlet open var trailingContraintToBreakOnMerge : NSLayoutConstraint?

    deinit {
        print("releasing: \(self)")
    }
    
    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("value")
        keys.insert("enabled")
        keys.insert("minValue")
        keys.insert("maxValue")
        keys.insert("subtitle")
        keys.insert("increment")
        keys.insert("valueWhenNil")
        keys.insert("mergeWithRight")
    }
    
    // MARK: - Generation
    
    open override var nibName: String? {
        return subtitleKey?.value == nil ? "AJRInspectorSliceNumber" : "AJRInspectorSliceNumberWithLabel"
    }
    
    open override func buildView(from element: XMLElement) throws {
        valueKey = try AJRInspectorKey(key: "value", xmlElement: element, inspectorElement: self)
        enabledKey = try AJRInspectorKey(key: "enabled", xmlElement: element, inspectorElement: self)
        minValueKey = try AJRInspectorKey(key: "minValue", xmlElement: element, inspectorElement: self)
        maxValueKey = try AJRInspectorKey(key: "maxValue", xmlElement: element, inspectorElement: self)
        subtitleKey = try AJRInspectorKey(key: "subtitle", xmlElement: element, inspectorElement: self)
        incrementKey = try AJRInspectorKey(key: "increment", xmlElement: element, inspectorElement: self)
        valueWhenNilKey = try AJRInspectorKey(key: "valueWhenNil", xmlElement: element, inspectorElement: self, defaultValue: "")
        mergeWithRightKey = try AJRInspectorKey(key: "mergeWithRight", xmlElement: element, inspectorElement: self, defaultValue: false)

        try super.buildView(from: element)
        
        subtitleField?.font = NSFont.systemFont(ofSize: viewController!.fontSize)
        numberField.font = NSFont.monospacedDigitSystemFont(ofSize: viewController!.fontSize, weight: .regular)
        
        weak var weakSelf = self
        valueKey?.addObserver {
            if let strongSelf = weakSelf {
                switch strongSelf.valueKey?.selectionType ?? .none {
                case .none:
                    strongSelf.numberField.stringValue = ""
                    strongSelf.numberField.placeholderString = strongSelf.isMerged ? "—" : AJRObjectInspectorViewController.translator["No Selection"]
                    strongSelf.numberField.isEditable = false
                    strongSelf.stepper.isEnabled = false
                case .multiple:
                    strongSelf.numberField.stringValue = ""
                    strongSelf.numberField.placeholderString = strongSelf.isMerged ? "—" : AJRObjectInspectorViewController.translator["Multiple Selection"]
                    strongSelf.numberField.isEditable = strongSelf.enabledKey?.value ?? true
                    strongSelf.stepper.isEnabled = false
                case .single:
                    strongSelf.numberField.placeholderString = ""
                    strongSelf.numberField.isEditable = strongSelf.enabledKey?.value ?? true
                    strongSelf.stepper.isEnabled = strongSelf.enabledKey?.value ?? true
                    strongSelf.updateSingleDisplayedValue()
                }
            }
        }
        enabledKey?.addObserver {
            weakSelf?.stepper.isEnabled = weakSelf?.enabledKey?.value ?? true
        }
        minValueKey?.addObserver {
            weakSelf?.stepper.minValue = weakSelf?.minValueKey?.value?.doubleValue ?? 0.0
        }
        maxValueKey?.addObserver {
            weakSelf?.stepper.maxValue = weakSelf?.maxValueKey?.value?.doubleValue ?? 0.0
        }
        subtitleKey?.addObserver  {
            weakSelf?.subtitleField?.stringValue = weakSelf?.subtitleKey?.value ?? ""
        }
        incrementKey?.addObserver {
            weakSelf?.stepper.increment = weakSelf?.incrementKey?.value?.doubleValue ?? 1.0
        }
        mergeWithRightKey?.addObserver {
            // Do we do anything here? We don't actually expect this to change during run time.
        }
    }
    
    open override func canMergeWithElement(_ element: AJRInspectorElement) -> Bool {
        // Basically, we can merge if we don't have a label, the previous view is a number slice, both ourself and slice have a subtitle, and slice hasn't already merged with another slice.
        if let slice = element as? AJRInspectorSliceNumber {
            if self.labelKey == nil
                && (slice.wantsMergeWithRight || (slice.subtitleField != nil && self.subtitleField != nil)) {
                return true
            }
        }
        return false
    }
    
    // MARK: - Actions
    
    @IBAction open func takeNumber(from sender: Any?) -> Void {
    }
    
    @IBAction open func step(_ sender: NSStepper?) -> Void {
    }
    
    // MARK: - Value
    
    open func updateSingleDisplayedValue() {
        // Meant for subclasses to override
    }
    
}

@objcMembers
open class AJRInspectorSliceInteger : AJRInspectorSliceNumberTyped<Int> {
    
    // MARK: - Actions
    
    @IBAction override open func takeNumber(from sender: Any?) -> Void {
        var value = numberField.integerValue
        if let minValue = minValueKey?.value {
            if value < minValue {
                value = minValue
            }
        }
        if let maxValue = maxValueKey?.value {
            if value > maxValue {
                value = maxValue
            }
        }
        valueKey?.value = value
    }
    
    @IBAction override open func step(_ sender: NSStepper?) -> Void {
        self.valueKey?.value = stepper.integerValue
    }
    
    // MARK: - Value
    
    open override func updateSingleDisplayedValue() {
        if let value = valueKey?.value {
            numberField.integerValue = value
            stepper.integerValue = value
        } else {
            numberField.stringValue = valueWhenNilKey.value!
        }
    }
    
}

@objcMembers
open class AJRInspectorSliceFloat : AJRInspectorSliceNumberTyped<Double> {
    
    // MARK: - Actions
    
    @IBAction override open func takeNumber(from sender: Any?) -> Void {
        var value = numberField.doubleValue
        if let minValue = minValueKey?.value {
            if value < minValue {
                value = minValue
            }
        }
        if let maxValue = maxValueKey?.value {
            if value > maxValue {
                value = maxValue
            }
        }
        self.valueKey?.value = value
    }
    
    @IBAction override open func step(_ sender: NSStepper?) -> Void {
        self.valueKey?.value = stepper.doubleValue
    }
    
    // MARK: - Value
    
    open override func updateSingleDisplayedValue() {
        if let value = valueKey?.value {
            numberField.doubleValue = value
            stepper.doubleValue = value
        } else {
            numberField.stringValue = valueWhenNilKey.value!
        }
    }
    
}

@objcMembers
open class AJRInspectorSliceTimeInterval : AJRInspectorSliceNumberTyped<TimeInterval> {
    
    // MARK: - Actions
    
    @IBAction override open func takeNumber(from sender: Any?) -> Void {
        guard let sender = sender as? NSTextField else {
            return
        }
        guard var value = try? AJRTimeIntervalFormatter.timeInterval(from: sender.stringValue) else {
            return
        }
        
        if let minValue = minValueKey?.value {
            if value < minValue {
                value = minValue
            }
        }
        if let maxValue = maxValueKey?.value {
            if value > maxValue {
                value = maxValue
            }
        }
        self.valueKey?.value = value
    }
    
    @IBAction override open func step(_ sender: NSStepper?) -> Void {
        self.valueKey?.value = stepper.doubleValue
    }
    
    // MARK: - Value
    
    open override func updateSingleDisplayedValue() {
        if let value = valueKey?.value {
            numberField.stringValue = AJRTimeIntervalFormatter.string(fromTimeInterval: value) ?? ""
            stepper.doubleValue = value
        } else {
            numberField.stringValue = valueWhenNilKey.value!
        }
    }
    
}
