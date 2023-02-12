/*
 AJRInspectorSliceLevel.swift
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
        if let value = value as? NSNumber {
            return NSLevelIndicator.Style(rawValue: value.uintValue)
        }
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
        if let value = value as? NSNumber {
            return NSLevelIndicator.PlaceholderVisibility(rawValue: value.intValue)
        }
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
