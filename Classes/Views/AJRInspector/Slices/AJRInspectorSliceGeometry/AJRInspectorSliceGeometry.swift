/*
 AJRInspectorSliceGeometry.swift
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

// MARK: - AJRInspectorSliceGeometry -

@objcMembers
open class  AJRInspectorSliceGeometry: AJRInspectorSlice {

    @IBOutlet open var numberField1 : NSTextField!
    @IBOutlet open var stepper1 : NSStepper!
    @IBOutlet open var label1 : NSTextField!
    @IBOutlet open var numberField2 : NSTextField!
    @IBOutlet open var stepper2 : NSStepper!
    @IBOutlet open var label2 : NSTextField!
    @IBOutlet open var linkedButton1 : NSButton!

    @IBOutlet open var numberField3 : NSTextField!
    @IBOutlet open var stepper3 : NSStepper!
    @IBOutlet open var label3 : NSTextField!
    @IBOutlet open var numberField4 : NSTextField!
    @IBOutlet open var stepper4 : NSStepper!
    @IBOutlet open var label4 : NSTextField!
    @IBOutlet open var linkedButton2 : NSButton!
    
    open var enabledKey : AJRInspectorKey<Bool>?
    open var unitsKey : AJRInspectorKey<Unit>?
    open var displayUnitsKey : AJRInspectorKey<Unit>?
    open var displayInchesAsFractionsKey : AJRInspectorKey<Bool>?
    open var incrementKey : AJRInspectorKey<CGFloat>?

    // MARK: - Factory

    private static var sliceClassesByType = [String:AJRInspectorSliceGeometry.Type]()

    open override class func registerSlice(_ sliceClass: AJRInspectorSlice.Type, properties: [String:Any]) -> Void {
        if let type = properties["type"] as? String {
            if let sliceClass = sliceClass as? AJRInspectorSliceGeometry.Type {
                sliceClassesByType[type] = sliceClass
            }
        }
    }

    open override class func createSlice(from element: XMLElement, parent: AJRInspectorElement, viewController: AJRObjectInspectorViewController, bundle: Bundle = Bundle.main) throws -> AJRInspectorSlice {
        if let valueType = element.attribute(forName: "type")?.stringValue {
            if let valueClass = sliceClassesByType[valueType] {
                return try valueClass.init(element: element, parent: parent, viewController: viewController, bundle: bundle)
            } else {
                throw NSError(domain: AJRInspectorErrorDomain, message: "Unknown geometry type: \(valueType)")
            }
        } else {
            throw NSError(domain: AJRInspectorErrorDomain, message: "Geometry slices must define the \"type\" property.")
        }
    }
    
    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("enabled")
        keys.insert("units")
        keys.insert("displayUnits")
        keys.insert("displayInchesAsFractions")
        keys.insert("valueType")
        keys.insert("increment")
    }
    
    open override func buildView(from element: XMLElement) throws {
        enabledKey = try AJRInspectorKey(key: "enabled", xmlElement: element, inspectorElement: self)
        unitsKey = try AJRInspectorKey(key: "units", xmlElement: element, inspectorElement: self)
        displayUnitsKey = try AJRInspectorKey(key: "displayUnits", xmlElement: element, inspectorElement: self)
        displayInchesAsFractionsKey = try AJRInspectorKey(key: "displayInchesAsFractions", xmlElement: element, inspectorElement: self)
        incrementKey = try AJRInspectorKey(key: "increment", xmlElement: element, inspectorElement: self, defaultValue: 1.0)

        try super.buildView(from: element)
        
        weak var weakSelf = self
        enabledKey?.addObserver {
            weakSelf?.configureFields()
        }
        unitsKey?.addObserver {
            weakSelf?.configureFields()
        }
        displayUnitsKey?.addObserver {
            weakSelf?.configureFields()
        }
        displayInchesAsFractionsKey?.addObserver {
            weakSelf?.configureFields()
        }
        incrementKey?.addObserver {
            weakSelf?.configureFields()
        }
    }
    
    // MARK: - Utilities
    
    open var fields : [NSTextField] { return [] }
    open var steppers : [NSStepper] { return [] }
    open var toggles : [NSButton] { return [] }
    
    @discardableResult
    open func configureFields() -> Bool {
        return false
    }
    
    open func updateFields() -> Void {
    }
    
    open var units : Unit? {
        // Since we're "geometry", we assume units of points, which is likely to be right the vast majority of the time, if not always.
        return unitsKey?.value ?? Unit(forIdentifier: "points")
    }
    
    open var displayUnits : Unit? {
        return displayUnitsKey?.value
    }
    
    open var formatter : Formatter? {
        let units = self.units
        let displayUnits = self.displayUnits
        
        if let units {
            let formatter = AJRUnitsFormatter(units: units, displayUnits: displayUnits)
            formatter.displayInchesAsFrations = displayInchesAsFractionsKey?.value ?? false

            return formatter
        }

        // If both units and displayUnits are nil, then we don't format in any special way.
        return nil
    }
    
    // MARK: - Overridable Actions
    
    @IBAction open func setValue1(_ sender: NSControl?) -> Void {
    }
    
    @IBAction open func setValue2(_ sender: NSControl?) -> Void {
    }
    
    @IBAction open func setValue3(_ sender: NSControl?) -> Void {
    }
    
    @IBAction open func setValue4(_ sender: NSControl?) -> Void {
    }
    
    @IBAction open func toggleLinked1(_ sender: NSButton?) -> Void {
    }
    
    @IBAction open func toggleLinked2(_ sender: NSButton?) -> Void {
    }
    
}

// MARK: - AJRInspectorSliceGeometryTyped -

@objcMembers
open class AJRInspectorSliceGeometryTyped<T:AJRInspectorValue> : AJRInspectorSliceGeometry {
    
    open var valueKey : AJRInspectorKey<T>?
    
    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("value")
    }
    
    open override func buildView(from element: XMLElement) throws {
        valueKey = try AJRInspectorKey(key: "value", xmlElement: element, inspectorElement: self)
        
        try super.buildView(from: element)
        
        weak var weakSelf = self
        valueKey?.addObserver {
            weakSelf?.updateFields()
        }
    }
    
    open override var fields : [NSTextField] { return [numberField1, numberField2] }
    open override var steppers : [NSStepper] { return [stepper1, stepper2] }
    open override var toggles : [NSButton] { return [linkedButton1] }

    @discardableResult
    open override func configureFields() -> Bool {
        let increment = incrementKey?.value ?? 1.0
        switch valueKey?.selectionType ?? .none {
        case .none:
            for (index, field) in fields.enumerated() {
                field.stringValue = ""
                field.placeholderString = isMerged ? "—" : AJRObjectInspectorViewController.translator["No Selection"]
                field.isEditable = false
                field.formatter = formatter
                steppers[index].isEnabled = false
                steppers[index].increment = increment
            }
            return false
        case .multiple:
            for (index, field) in fields.enumerated() {
                field.stringValue = ""
                field.placeholderString = isMerged ? "—" : AJRObjectInspectorViewController.translator["Multiple Selection"]
                field.isEditable = enabledKey?.value ?? true
                field.formatter = formatter
                steppers[index].isEnabled = false
                steppers[index].increment = increment
            }
            return false
        case .single:
            for (index, field) in fields.enumerated() {
                field.placeholderString = ""
                field.isEditable = enabledKey?.value ?? true
                field.formatter = formatter
                steppers[index].isEnabled = enabledKey?.value ?? true
                steppers[index].increment = increment
            }
            return true
        }
    }
    
}

// MARK: - AJRInspectorSliceTwoValues -

@objcMembers
open class AJRInspectorSliceTwoValues<T:AJRInspectorValue> : AJRInspectorSliceGeometryTyped<T> {
    
    open var subtitle1Key : AJRInspectorKey<String>?
    open var subtitle2Key : AJRInspectorKey<String>?
    
    open var defaultLabel1Value : String { return "Label 1" }
    open var defaultLabel2Value : String { return "Label 2" }

    open var valuesRatio : CGFloat? = nil
    open var valuesAreLinked : Bool {
        return linkedButton1?.state == .on
    }
    open var valuesCanLinkKey : AJRInspectorKey<Bool>?
    open var defaultValuesCanLink : Bool { return false }

    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("subtitle1")
        keys.insert("subtitle2")
        keys.insert("valuesCanLink")
    }
    
    open override func buildView(from element: XMLElement) throws {
        subtitle1Key = try AJRInspectorKey(key: "subtitle1", xmlElement: element, inspectorElement: self, defaultValue: defaultLabel1Value)
        subtitle2Key = try AJRInspectorKey(key: "subtitle2", xmlElement: element, inspectorElement: self, defaultValue: defaultLabel2Value)
        valuesCanLinkKey = try AJRInspectorKey(key: "valuesCanLink", xmlElement: element, inspectorElement: self, defaultValue: defaultValuesCanLink)
        
        try super.buildView(from: element)
        
        weak var weakSelf = self
        subtitle1Key?.addObserver {
            if let strongSelf = weakSelf {
                strongSelf.label1.stringValue = strongSelf.subtitle1Key!.value!
            }
        }
        subtitle2Key?.addObserver {
            if let strongSelf = weakSelf {
                strongSelf.label2.stringValue = strongSelf.subtitle2Key!.value!
            }
        }
        valuesCanLinkKey?.addObserver {
            if let strongSelf = weakSelf {
                let canLink = strongSelf.valuesCanLinkKey!.value!
                strongSelf.linkedButton1.isHidden = !canLink
                if !canLink && strongSelf.valuesAreLinked {
                    strongSelf.linkedButton1.state = .off
                    strongSelf.toggleLinked1(strongSelf.linkedButton1)
                }
            }
        }
    }
    
    open override var nibName: String? {
        return "AJRInspectorSliceGeometryTwoFields"
    }

    open func computeValuesRatio() -> CGFloat? {
        return nil
    }
    
    open override func updateFields() -> Void {
        if !(valuesCanLinkKey?.value ?? false)  {
            valuesRatio = nil
        } else {
            if linkedButton1.state == .on && valuesRatio == nil {
                valuesRatio = computeValuesRatio()
            } else if linkedButton1.state == .off && valuesRatio != nil {
                valuesRatio = nil
            }
        }
    }
    
    open func configureFieldsAndFetchSingleValue() -> T? {
        if configureFields() {
            return valueKey?.value
        }
        return nil
    }
    
    @IBAction override open func toggleLinked1(_ sender: NSButton?) -> Void {
        super.toggleLinked1(sender)
        updateFields()
    }
    
    @IBAction override open func toggleLinked2(_ sender: NSButton?) -> Void {
        super.toggleLinked2(sender)
        updateFields()
    }
    
}

// MARK: - AJRInspectorSliceThreeValues -

@objcMembers
open class AJRInspectorSliceThreeValues<T:AJRInspectorValue> : AJRInspectorSliceGeometryTyped<T> {

    open var subtitle1Key : AJRInspectorKey<String>?
    open var subtitle2Key : AJRInspectorKey<String>?
    open var subtitle3Key : AJRInspectorKey<String>?

    open var defaultLabel1Value : String { return "Label 1" }
    open var defaultLabel2Value : String { return "Label 2" }
    open var defaultLabel3Value : String { return "Label 3" }

    open override var fields : [NSTextField] { return [numberField1, numberField2, numberField3] }
    open override var steppers : [NSStepper] { return [stepper1, stepper2, stepper3] }

    open var valuesRatio : CGFloat? = nil
    open var valuesAreLinked : Bool {
        return linkedButton1?.state == .on
    }
    open var valuesCanLinkKey : AJRInspectorKey<Bool>?
    open var defaultValuesCanLink : Bool { return false }

    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("subtitle1")
        keys.insert("subtitle2")
        keys.insert("subtitle3")
        keys.insert("valuesCanLink")
    }

    open override func buildView(from element: XMLElement) throws {
        subtitle1Key = try AJRInspectorKey(key: "subtitle1", xmlElement: element, inspectorElement: self, defaultValue: defaultLabel1Value)
        subtitle2Key = try AJRInspectorKey(key: "subtitle2", xmlElement: element, inspectorElement: self, defaultValue: defaultLabel2Value)
        subtitle3Key = try AJRInspectorKey(key: "subtitle3", xmlElement: element, inspectorElement: self, defaultValue: defaultLabel3Value)
        valuesCanLinkKey = try AJRInspectorKey(key: "valuesCanLink", xmlElement: element, inspectorElement: self, defaultValue: defaultValuesCanLink)

        try super.buildView(from: element)

        weak var weakSelf = self
        subtitle1Key?.addObserver {
            if let strongSelf = weakSelf {
                strongSelf.label1.stringValue = strongSelf.subtitle1Key!.value!
            }
        }
        subtitle2Key?.addObserver {
            if let strongSelf = weakSelf {
                strongSelf.label2.stringValue = strongSelf.subtitle2Key!.value!
            }
        }
        subtitle3Key?.addObserver {
            if let strongSelf = weakSelf {
                strongSelf.label3.stringValue = strongSelf.subtitle3Key!.value!
            }
        }
        valuesCanLinkKey?.addObserver {
            if let strongSelf = weakSelf {
                let canLink = strongSelf.valuesCanLinkKey!.value!
                strongSelf.linkedButton1.isHidden = !canLink
                if !canLink && strongSelf.valuesAreLinked {
                    strongSelf.linkedButton1.state = .off
                    strongSelf.toggleLinked1(strongSelf.linkedButton1)
                }
            }
        }
    }

    open override var nibName: String? {
        return "AJRInspectorSliceGeometryThreeFields"
    }

    open func computeValuesRatio() -> CGFloat? {
        return nil
    }

    open override func updateFields() -> Void {
        if !(valuesCanLinkKey?.value ?? false)  {
            valuesRatio = nil
        } else {
            if linkedButton1.state == .on && valuesRatio == nil {
                valuesRatio = computeValuesRatio()
            } else if linkedButton1.state == .off && valuesRatio != nil {
                valuesRatio = nil
            }
        }
    }

    open func configureFieldsAndFetchSingleValue() -> T? {
        if configureFields() {
            return valueKey?.value
        }
        return nil
    }

    @IBAction override open func toggleLinked1(_ sender: NSButton?) -> Void {
        super.toggleLinked1(sender)
        updateFields()
    }

}

// MARK: - AJRInspectorSliceSize -

@objcMembers
open class AJRInspectorSliceSize : AJRInspectorSliceTwoValues<CGSize> {
    
    open override var defaultLabel1Value : String { return translator["Width"] }
    open override var defaultLabel2Value : String { return translator["Height"] }
    
    open override var defaultValuesCanLink: Bool { return true }
    
    open override func computeValuesRatio() -> CGFloat? {
        if valueKey?.selectionType == .single,
            let value = valueKey?.value,
            value.width != 0 && value.height != 0.0 {
            return value.width / value.height
        }
        return nil
    }
    
    open override func updateFields() -> Void {
        super.updateFields()
        if let size = configureFieldsAndFetchSingleValue() {
            numberField1.doubleValue = Double(size.width)
            numberField2.doubleValue = Double(size.height)
            stepper1.doubleValue = Double(size.width)
            stepper2.doubleValue = Double(size.height)
        }
    }
    
    @IBAction open override func setValue1(_ sender: NSControl?) {
        if valueKey?.selectionType == .single,
            var size = valueKey!.value {
            let newValue = CGFloat(sender?.doubleValue ?? 0.0)
            if size.width != newValue {
                size.width = newValue
                if linkedButton1.state == .on,
                   let valuesRatio = valuesRatio {
                    size.height = size.width / valuesRatio
                }
                valueKey?.value = size
            }
        }
    }
    
    @IBAction open override func setValue2(_ sender: NSControl?) {
        if valueKey?.selectionType == .single,
            var size = valueKey!.value {
            let newValue = CGFloat(sender?.doubleValue ?? 0.0)
            if size.height != newValue {
                size.height = newValue
                if linkedButton1.state == .on,
                   let valuesRatio = valuesRatio {
                    size.height = size.width * valuesRatio
                }
                valueKey?.value = size
            }
        }
    }
    
}

// MARK: - AJRInspectorSlicePoint -

@objcMembers
open class AJRInspectorSlicePoint : AJRInspectorSliceTwoValues<CGPoint> {
    
    open override var defaultLabel1Value : String { return translator["X"] }
    open override var defaultLabel2Value : String { return translator["Y"] }
    
    open override func updateFields() -> Void {
        super.updateFields()
        if let point = configureFieldsAndFetchSingleValue() {
            numberField1.doubleValue = Double(point.x)
            numberField2.doubleValue = Double(point.y)
            stepper1.doubleValue = Double(point.x)
            stepper2.doubleValue = Double(point.y)
        }
    }
    
    @IBAction open override func setValue1(_ sender: NSControl?) {
        if valueKey?.selectionType == .single,
            var point = valueKey!.value {
            let newValue = CGFloat(sender?.doubleValue ?? 0.0)
            if point.x != newValue {
                point.x = newValue
                valueKey?.value = point
            }
        }
    }
    
    @IBAction open override func setValue2(_ sender: NSControl?) {
        if valueKey?.selectionType == .single,
            var point = valueKey!.value {
            let newValue = CGFloat(sender?.doubleValue ?? 0.0)
            if point.y != newValue {
                point.y = newValue
                valueKey?.value = point
            }
        }
    }
    
}

// MARK: - AJRInspectorSliceFourValues -

@objcMembers
open class AJRInspectorSliceFourValues<T:AJRInspectorValue> : AJRInspectorSliceTwoValues<T> {

    open var subtitle3Key : AJRInspectorKey<String>?
    open var subtitle4Key : AJRInspectorKey<String>?
    
    open var defaultLabel3Value : String { return "Label 3" }
    open var defaultLabel4Value : String { return "Label 4" }
    
    open var secondValuesAreLinked : Bool {
        return linkedButton2?.state == .on
    }
    open var secondValuesCanLinkKey : AJRInspectorKey<Bool>?
    open var defaultSecondValuesCanLink : Bool { return false }
    
    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("subtitle2")
        keys.insert("subtitle3")
        keys.insert("secondValuesCanLink")
    }
    
    open override func buildView(from element: XMLElement) throws {
        subtitle3Key = try AJRInspectorKey(key: "subtitle3", xmlElement: element, inspectorElement: self, defaultValue: defaultLabel3Value)
        subtitle4Key = try AJRInspectorKey(key: "subtitle4", xmlElement: element, inspectorElement: self, defaultValue: defaultLabel4Value)
        secondValuesCanLinkKey = try AJRInspectorKey(key: "secondValuesCanLink", xmlElement: element, inspectorElement: self, defaultValue: defaultSecondValuesCanLink)

        try super.buildView(from: element)
        
        weak var weakSelf = self
        subtitle3Key?.addObserver {
            if let strongSelf = weakSelf {
                strongSelf.label3.stringValue = strongSelf.subtitle3Key!.value!
            }
        }
        subtitle4Key?.addObserver {
            if let strongSelf = weakSelf {
                strongSelf.label4.stringValue = strongSelf.subtitle4Key!.value!
            }
        }
        secondValuesCanLinkKey?.addObserver {
            if let strongSelf = weakSelf {
                let canLink = strongSelf.secondValuesCanLinkKey!.value!
                strongSelf.linkedButton2.isHidden = !canLink
                if !canLink && strongSelf.secondValuesAreLinked {
                    strongSelf.linkedButton2.state = .off
                    strongSelf.toggleLinked2(strongSelf.linkedButton2)
                }
            }
        }
    }
    
    open override var nibName: String? {
        return "AJRInspectorSliceGeometryFourFields"
    }
    
    open override var fields : [NSTextField] { return [numberField1, numberField2, numberField3, numberField4] }
    open override var steppers : [NSStepper] { return [stepper1, stepper2, stepper3, stepper4] }
    open override var toggles : [NSButton] { return [linkedButton1, linkedButton2] }
    
}

// MARK: - AJRInspectorSliceRect -

@objcMembers
open class AJRInspectorSliceRect : AJRInspectorSliceFourValues<CGRect> {
    
    open override var defaultLabel1Value : String { return translator["X"] }
    open override var defaultLabel2Value : String { return translator["Y"] }
    open override var defaultLabel3Value : String { return translator["Width"] }
    open override var defaultLabel4Value : String { return translator["Height"] }

    open override var defaultSecondValuesCanLink: Bool { return true }
    
    open override func updateFields() -> Void {
        super.updateFields()
        if let rect = configureFieldsAndFetchSingleValue() {
            numberField1.doubleValue = Double(rect.origin.x)
            numberField2.doubleValue = Double(rect.origin.y)
            numberField3.doubleValue = Double(rect.size.width)
            numberField4.doubleValue = Double(rect.size.height)
            stepper1.doubleValue = Double(rect.origin.x)
            stepper2.doubleValue = Double(rect.origin.y)
            stepper3.doubleValue = Double(rect.size.width)
            stepper4.doubleValue = Double(rect.size.height)
        }
    }
    
    @IBAction open override func setValue1(_ sender: NSControl?) {
        if valueKey?.selectionType == .single,
            var rect = valueKey!.value {
            let newValue = CGFloat(sender?.doubleValue ?? 0.0)
            if rect.origin.x != newValue {
                rect.origin.x = newValue
                valueKey?.value = rect
            }
        }
    }
    
    @IBAction open override func setValue2(_ sender: NSControl?) {
        if valueKey?.selectionType == .single,
            var rect = valueKey!.value {
            let newValue = CGFloat(sender?.doubleValue ?? 0.0)
            if rect.origin.y != newValue {
                rect.origin.y = newValue
                valueKey?.value = rect
            }
        }
    }
    
    @IBAction open override func setValue3(_ sender: NSControl?) {
        if valueKey?.selectionType == .single,
            var rect = valueKey!.value {
            let newValue = CGFloat(sender?.doubleValue ?? 0.0)
            if rect.size.width != newValue {
                rect.size.width = newValue
                if let valuesRatio = valuesRatio {
                    rect.size.height = rect.size.width / valuesRatio
                }
                valueKey?.value = rect
            }
        }
    }
    
    @IBAction open override func setValue4(_ sender: NSControl?) {
        if valueKey?.selectionType == .single,
            var rect = valueKey!.value {
            let newValue = CGFloat(sender?.doubleValue ?? 0.0)
            if rect.size.height != newValue {
                rect.size.height = newValue
                if let valuesRatio = valuesRatio {
                    rect.size.width = rect.size.height * valuesRatio
                }
                valueKey?.value = rect
            }
        }
    }
    
    open override func computeValuesRatio() -> CGFloat? {
        if valueKey?.selectionType == .single,
            let value = valueKey?.value {
            return value.size.width / value.size.height
        }
        return nil
    }
    
}

// MARK: - AJRInspectorSliceInsets -

@objcMembers
open class AJRInspectorSliceInsets : AJRInspectorSliceFourValues<NSEdgeInsets> {
    
    open override var defaultLabel1Value : String { return translator["Top"] }
    open override var defaultLabel2Value : String { return translator["Left"] }
    open override var defaultLabel3Value : String { return translator["Bottom"] }
    open override var defaultLabel4Value : String { return translator["Right"] }
    
    open override func updateFields() -> Void {
        super.updateFields()
        if let insets = configureFieldsAndFetchSingleValue() {
            numberField1.doubleValue = Double(insets.top)
            numberField2.doubleValue = Double(insets.left)
            numberField3.doubleValue = Double(insets.bottom)
            numberField4.doubleValue = Double(insets.right)
            stepper1.doubleValue = Double(insets.top)
            stepper2.doubleValue = Double(insets.left)
            stepper3.doubleValue = Double(insets.bottom)
            stepper4.doubleValue = Double(insets.right)
        }
    }
    
    @IBAction open override func setValue1(_ sender: NSControl?) {
        if valueKey?.selectionType == .single,
            var insets = valueKey!.value {
            let newValue = CGFloat(sender?.doubleValue ?? 0.0)
            if insets.top != newValue {
                insets.top = newValue
                valueKey?.value = insets
            }
        }
    }
    
    @IBAction open override func setValue2(_ sender: NSControl?) {
        if valueKey?.selectionType == .single,
            var insets = valueKey!.value {
            let newValue = CGFloat(sender?.doubleValue ?? 0.0)
            if insets.left != newValue {
                insets.left = newValue
                valueKey?.value = insets
            }
        }
    }
    
    @IBAction open override func setValue3(_ sender: NSControl?) {
        if valueKey?.selectionType == .single,
            var insets = valueKey!.value {
            let newValue = CGFloat(sender?.doubleValue ?? 0.0)
            if insets.bottom != newValue {
                insets.bottom = newValue
                valueKey?.value = insets
            }
        }
    }
    
    @IBAction open override func setValue4(_ sender: NSControl?) {
        if valueKey?.selectionType == .single,
            var insets = valueKey!.value {
            let newValue = CGFloat(sender?.doubleValue ?? 0.0)
            if insets.right != newValue {
                insets.right = newValue
                valueKey?.value = insets
            }
        }
    }
    
}
