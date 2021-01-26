//
//  AJRInspectorSliceLevel.swift
//  AJRInterface
//
//  Created by AJ Raftis on 4/25/19.
//

import Cocoa

extension NSLevelIndicator.Style : CustomStringConvertible, AJRInspectorValue {
    
    public var description: String {
        switch self {
        case .continuousCapacity:
            return "continuous"
        case .discreteCapacity:
            return "discrete"
        case .rating:
            return "rating"
        case .relevancy:
            return "relevancy"
        default:
            return "continuous"
        }
    }
    
    public static func inspectorValue(from string: String) -> Any? {
        switch string {
        case "continuous":
            return NSLevelIndicator.Style.continuousCapacity
        case "discrete":
            return NSLevelIndicator.Style.discreteCapacity
        case "rating":
            return NSLevelIndicator.Style.rating
        case "relevancy":
            return NSLevelIndicator.Style.relevancy
        default:
            return nil
        }
    }
    
    public static func inspectorValue(from value: NSValue) -> Any? {
        return nil
    }
    
}

extension NSLevelIndicator.PlaceholderVisibility : CustomStringConvertible, AJRInspectorValue {
    
    public var description: String {
        switch self {
        case .always:
            return "always"
        case .automatic:
            return "automatic"
        case .whileEditing:
            return "whileEditing"
        default:
            return "always"
        }
    }
    
    public static func inspectorValue(from string: String) -> Any? {
        switch string {
        case "always":
            return NSLevelIndicator.PlaceholderVisibility.always
        case "automatic":
            return NSLevelIndicator.PlaceholderVisibility.automatic
        case "whileEditing":
            return NSLevelIndicator.PlaceholderVisibility.whileEditing
        default:
            return NSLevelIndicator.PlaceholderVisibility.always
        }
    }

    public static func inspectorValue(from value: NSValue) -> Any? {
        return nil
    }
    
}

@objcMembers
open class AJRInspectorSliceLevel: AJRInspectorSlice {
    
    @IBOutlet var levelIndicator : NSLevelIndicator!
    
    open var valueKey : AJRInspectorKey<Double>?
    open var valueScaleKey : AJRInspectorKey<Double>!
    open var minValueKey : AJRInspectorKey<Double>?
    open var maxValueKey : AJRInspectorKey<Double>?
    open var warningValueKey : AJRInspectorKey<Double>?
    open var criticalValueKey : AJRInspectorKey<Double>?
    open var styleKey : AJRInspectorKey<NSLevelIndicator.Style>!
    open var placeholderVisibilityKey : AJRInspectorKey<NSLevelIndicator.PlaceholderVisibility>!
    open var editableKey : AJRInspectorKey<Bool>!
    open var enabledKey : AJRInspectorKey<Bool>!
    open var fillColorKey : AJRInspectorKey<NSColor>?
    open var warningColorKey : AJRInspectorKey<NSColor>?
    open var criticalColorKey : AJRInspectorKey<NSColor>?
    
    override open var baseLineOffset: CGFloat { return -1.0 }
    
    override open var nibName: String? {
        if styleKey.value == .rating {
            return "AJRInspectorSliceStars"
        } else {
            return super.nibName
        }
    }

    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("value")
        keys.insert("valueScale")
        keys.insert("minValue")
        keys.insert("maxValue")
        keys.insert("warningValue")
        keys.insert("criticalValue")
        keys.insert("style")
        keys.insert("placeholderVisibility")
        keys.insert("editable")
        keys.insert("enabled")
        keys.insert("colorKey")
        keys.insert("warningColorKey")
        keys.insert("criticalColorKey")
    }
    
    // MARK: - Building
    
    override open func buildView(from element: XMLElement) throws {
        valueKey = try AJRInspectorKey(key: "value", xmlElement: element, inspectorElement: self)
        valueScaleKey = try AJRInspectorKey(key: "valueScale", xmlElement: element, inspectorElement: self, defaultValue: 1.0)
        minValueKey = try AJRInspectorKey(key: "minValue", xmlElement: element, inspectorElement: self)
        maxValueKey = try AJRInspectorKey(key: "maxValue", xmlElement: element, inspectorElement: self)
        warningValueKey = try AJRInspectorKey(key: "warningValue", xmlElement: element, inspectorElement: self)
        criticalValueKey = try AJRInspectorKey(key: "criticalValue", xmlElement: element, inspectorElement: self)
        styleKey = try AJRInspectorKey(key: "style", xmlElement: element, inspectorElement: self, defaultValue: .continuousCapacity)
        placeholderVisibilityKey = try AJRInspectorKey(key: "placeholderVisibility", xmlElement: element, inspectorElement: self, defaultValue: .automatic)
        editableKey = try AJRInspectorKey(key: "editable", xmlElement: element, inspectorElement: self, defaultValue: true)
        enabledKey = try AJRInspectorKey(key: "enabled", xmlElement: element, inspectorElement: self, defaultValue: true)
        fillColorKey = try AJRInspectorKey(key: "colorKey", xmlElement: element, inspectorElement: self)
        warningColorKey = try AJRInspectorKey(key: "warningColorKey", xmlElement: element, inspectorElement: self)
        criticalColorKey = try AJRInspectorKey(key: "criticalColorKey", xmlElement: element, inspectorElement: self)

        try super.buildView(from: element)
        
        weak var weakSelf = self
        valueKey?.addObserver {
            if let strongSelf = weakSelf {
                switch strongSelf.valueKey!.selectionType {
                case .none:
                    strongSelf.levelIndicator.doubleValue = 0.0
                    strongSelf.levelIndicator.isEnabled = false
                    strongSelf.levelIndicator.isEditable = false
                case .multiple:
                    strongSelf.levelIndicator.doubleValue = 0.0
                    strongSelf.levelIndicator.isEnabled = strongSelf.enabledKey.value!
                    strongSelf.levelIndicator.isEditable = strongSelf.editableKey.value!
                case .single:
                    strongSelf.levelIndicator.doubleValue = (strongSelf.valueKey?.value ?? 0.0) / strongSelf.valueScaleKey.value!
                    strongSelf.levelIndicator.isEnabled = strongSelf.enabledKey.value!
                    strongSelf.levelIndicator.isEditable = strongSelf.editableKey.value!
                }
            }
        }
        minValueKey?.addObserver {
            if let strongSelf = weakSelf {
                if let minValue = strongSelf.minValueKey?.value {
                    strongSelf.levelIndicator.minValue = minValue
                }
            }
        }
        maxValueKey?.addObserver {
            if let strongSelf = weakSelf {
                if let maxValue = strongSelf.maxValueKey?.value {
                    strongSelf.levelIndicator.maxValue = maxValue
                }
            }
        }
        warningValueKey?.addObserver {
            if let strongSelf = weakSelf {
                if let warningValue = strongSelf.warningValueKey?.value {
                    strongSelf.levelIndicator.warningValue = warningValue
                }
            }
        }
        criticalValueKey?.addObserver {
            if let strongSelf = weakSelf {
                if let criticalValue = strongSelf.criticalValueKey?.value {
                    strongSelf.levelIndicator.criticalValue = criticalValue
                }
            }
        }
        styleKey?.addObserver {
            if let strongSelf = weakSelf {
                strongSelf.levelIndicator.levelIndicatorStyle = strongSelf.styleKey.value!
            }
        }
        placeholderVisibilityKey?.addObserver {
            if let strongSelf = weakSelf {
                strongSelf.levelIndicator.placeholderVisibility = strongSelf.placeholderVisibilityKey.value!
            }
        }
        editableKey?.addObserver {
            if let strongSelf = weakSelf {
                strongSelf.levelIndicator.isEditable = strongSelf.editableKey.value!
            }
        }
        enabledKey?.addObserver {
            if let strongSelf = weakSelf {
                strongSelf.levelIndicator.isEnabled = strongSelf.enabledKey.value!
            }
        }
        fillColorKey?.addObserver {
            if let strongSelf = weakSelf {
                strongSelf.levelIndicator.fillColor = strongSelf.fillColorKey?.value
            }
        }
        warningColorKey?.addObserver {
            if let strongSelf = weakSelf {
                strongSelf.levelIndicator.warningFillColor = strongSelf.warningColorKey?.value
            }
        }
        criticalColorKey?.addObserver {
            if let strongSelf = weakSelf {
                strongSelf.levelIndicator.criticalFillColor = strongSelf.criticalColorKey?.value
            }
        }
    }
    
    @IBAction open func takeLevelFrom(_ sender: NSLevelIndicator?) -> Void {
        if let sender = sender {
            valueKey?.value = sender.doubleValue * valueScaleKey.value!
        }
    }
    
}
