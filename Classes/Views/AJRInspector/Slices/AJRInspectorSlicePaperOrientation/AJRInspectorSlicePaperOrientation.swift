//
//  AJRInspectorSlicePageOrientation.swift
//  AJRInterface
//
//  Created by AJ Raftis on 11/4/22.
//

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

    // MARK: - Actions

    @IBAction open func takeOrientation(from sender: AJRPaperOrientationChooser?) -> Void {
        valueKey?.value = sender?.orientation ?? .portrait
    }

    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("value")
        keys.insert("paperValue")
        keys.insert("enabled")
        keys.insert("units")
    }

    // MARK: - View

    open override func buildView(from element: XMLElement) throws {
        valueKey = try AJRInspectorKey(key: "value", xmlElement: element, inspectorElement: self)
        paperValueKey = try AJRInspectorKey(key: "paperValue", xmlElement: element, inspectorElement: self)
        unitsKey = try AJRInspectorKey(key: "units", xmlElement: element, inspectorElement: self)
        enabledKey = try AJRInspectorKey(key: "enabled", xmlElement: element, inspectorElement: self)

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
    }

}
