/*
 AJRInspectorSliceNumber.swift
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
            throw NSError(domain: AJRInspectorErrorDomain, message: "Unknown number type: \(valueType!). Current valid values are \"integer\", \"float\", and \"timeInterval\".")
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
    open var formatKey : AJRInspectorKey<String>?
    open var unitsKey : AJRInspectorKey<Unit>?
    open var displayUnitsKey : AJRInspectorKey<Unit>?
    open var displayInchesAsFractionsKey : AJRInspectorKey<Bool>?
    open var placeholderStringKey : AJRInspectorKey<String>?

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
        keys.insert("format")
        keys.insert("units")
        keys.insert("displayUnits")
        keys.insert("displayInchesAsFractions")
        keys.insert("placeholderString")
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
        formatKey = try AJRInspectorKey(key: "format", xmlElement: element, inspectorElement: self)
        unitsKey = try AJRInspectorKey(key: "units", xmlElement: element, inspectorElement: self)
        displayUnitsKey = try AJRInspectorKey(key: "displayUnits", xmlElement: element, inspectorElement: self)
        displayInchesAsFractionsKey = try AJRInspectorKey(key: "displayInchesAsFractions", xmlElement: element, inspectorElement: self)
        placeholderStringKey = try AJRInspectorKey(key: "placeholderString", xmlElement: element, inspectorElement: self, defaultValue: "")

        try super.buildView(from: element)
        
        subtitleField?.font = NSFont.systemFont(ofSize: viewController!.fontSize)
        numberField.font = NSFont.monospacedDigitSystemFont(ofSize: viewController!.fontSize, weight: .regular)
        numberField.formatter = defaultFormatter
        
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
                    strongSelf.numberField.placeholderString = strongSelf.placeholderStringKey?.value ?? ""
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
        formatKey?.addObserver {
            weakSelf?.updateFormatter()
        }
        unitsKey?.addObserver {
            weakSelf?.updateFormatter()
        }
        displayUnitsKey?.addObserver {
            weakSelf?.updateFormatter()
        }
        displayInchesAsFractionsKey?.addObserver {
            weakSelf?.updateFormatter()
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

    open var isEnabled : Bool {
        return enabledKey?.value ?? true
    }
    
    @IBAction open func takeNumber(from sender: Any?) -> Void {
    }
    
    @IBAction open func step(_ sender: NSStepper?) -> Void {
    }
    
    // MARK: - Value
    
    open func updateSingleDisplayedValue() {
        // Meant for subclasses to override
    }

    // MARK: - Default Formatter

    open var defaultFormatter : NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
    
    open var formatter : Formatter {
        let units = unitsKey?.value
        let displayUnits = displayUnitsKey?.value
        
        if let units {
            let formatter = AJRUnitsFormatter(units: units, displayUnits: displayUnits)
            formatter.displayInchesAsFrations = displayInchesAsFractionsKey?.value ?? false

            return formatter
        }

        // If both units and displayUnits are nil, then we'll just display with a plain old number formatter.
        return defaultFormatter
    }
    
    open func updateFormatter() {
        let formatter : Formatter
        if let format = formatKey?.value {
            formatter = NumberFormatter()
            (formatter as! NumberFormatter).format = format
        } else {
            formatter = self.formatter
        }
        numberField.formatter = formatter
    }
    
}

@objcMembers
open class AJRInspectorSliceInteger : AJRInspectorSliceNumberTyped<Int> {
    
    // MARK: - Actions
    
    @IBAction override open func takeNumber(from sender: Any?) -> Void {
        if isEnabled {
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
        if isEnabled {
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
        if isEnabled {
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
