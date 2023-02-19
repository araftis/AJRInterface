/*
 AJRInspectorSlicePaperOrientation.swift
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

extension NSPrintInfo.PaperOrientation : AJRInspectorValue, AJRXMLEncodableEnum, AJRInspectorValueAsValue {

    public static var allCases: [NSPrintInfo.PaperOrientation] = [.portrait, .landscape]

    public static func inspectorValue(from string: String) -> Any? {
        return self.init(string: string)
    }

    public var integerValue : Int { return rawValue }
    public var doubleValue : Double { return Double(rawValue) }
    public func toValue() -> NSValue { return NSNumber(integerLiteral: rawValue) }

    public static func inspectorValue(from value: NSValue) -> Any? {
        if let value = value as? NSNumber {
            // This should be the case for us.
            return NSPrintInfo.PaperOrientation(rawValue: value.intValue)
        }
        return nil
    }

    public var description: String {
        switch self {
        case .portrait: return "portrait"
        case .landscape: return "landscape"
        @unknown default:
            return "portrait"
        }
    }
}

extension AJRPaper : AJRInspectorValue {

    public static func inspectorValue(from string: String) -> Any? {
        return AJRPaper(forPaperId: string)
    }

    public static func inspectorValue(from value: NSValue) -> Any? {
        nil
    }

}

class AJRInspectorSlicePaperOrientation: AJRInspectorSlice {

    @IBOutlet open var orientationChooser : AJRPaperOrientationChooser!
    open override var baseLineOffset : CGFloat { return 13.0 }

    open var valueKey : AJRInspectorKey<NSPrintInfo.PaperOrientation>?
    open var paperValueKey : AJRInspectorKey<AJRPaper>?
    open var enabledKey : AJRInspectorKey<Bool>?
    open var unitsKey : AJRInspectorKey<Unit>?
    open var displayInchesAsFractionsKey : AJRInspectorKey<Bool>?

    // MARK: - Actions

    @IBAction open func takeOrientation(from sender: AJRPaperOrientationChooser?) -> Void {
        valueKey?.value = sender?.orientation ?? .portrait
    }

    open override func tearDown() {
        orientationChooser?.target = nil
        orientationChooser = nil
        valueKey?.stopObserving()
        paperValueKey?.stopObserving()
        enabledKey?.stopObserving()
        unitsKey?.stopObserving()
        displayInchesAsFractionsKey?.stopObserving()
        super.tearDown()
    }

    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("value")
        keys.insert("paperValue")
        keys.insert("enabled")
        keys.insert("units")
        keys.insert("displayInchesAsFractions")
    }

    // MARK: - View

    open override func buildView(from element: XMLElement) throws {
        valueKey = try AJRInspectorKey(key: "value", xmlElement: element, inspectorElement: self)
        paperValueKey = try AJRInspectorKey(key: "paperValue", xmlElement: element, inspectorElement: self)
        unitsKey = try AJRInspectorKey(key: "units", xmlElement: element, inspectorElement: self)
        enabledKey = try AJRInspectorKey(key: "enabled", xmlElement: element, inspectorElement: self)
        displayInchesAsFractionsKey = try AJRInspectorKey(key: "displayInchesAsFractions", xmlElement: element, inspectorElement: self, defaultValue: false)

        try super.buildView(from: element)

        weak var weakSelf = self
        valueKey?.addObserver {
            if let strongSelf = weakSelf {
                switch strongSelf.valueKey?.selectionType ?? .none {
                case .none:
                    strongSelf.orientationChooser.isEnabled = false
                case .multiple:
                    strongSelf.orientationChooser.isEnabled = strongSelf.enabledKey?.value ?? true
                case .single:
                    strongSelf.orientationChooser.isEnabled = strongSelf.enabledKey?.value ?? true
                    strongSelf.orientationChooser.orientation = strongSelf.valueKey?.value ?? .portrait
                }
            }
        }
        paperValueKey?.addObserver {
            if let strongSelf = weakSelf {
                switch strongSelf.paperValueKey?.selectionType ?? .none {
                case .none:
                    break
                case .multiple:
                    break
                case .single:
                    if let paper = strongSelf.paperValueKey?.value {
                        strongSelf.orientationChooser.paper = paper
                    }
                }
            }
        }
        unitsKey?.addObserver {
            if let strongSelf = weakSelf {
                switch strongSelf.unitsKey?.selectionType ?? .none {
                case .none:
                    break
                case .multiple:
                    break
                case .single:
                    if let units = strongSelf.unitsKey?.value as? UnitLength {
                        strongSelf.orientationChooser.units = units
                    }
                }
            }
        }
        enabledKey?.addObserver {
            if let strongSelf = weakSelf {
                strongSelf.orientationChooser.isEnabled = strongSelf.enabledKey?.value ?? true
            }
        }
        displayInchesAsFractionsKey?.addObserver {
            if let strongSelf = weakSelf {
                strongSelf.orientationChooser.displayInchesAsFractions = strongSelf.displayInchesAsFractionsKey?.value ?? false
            }
        }
    }

}
