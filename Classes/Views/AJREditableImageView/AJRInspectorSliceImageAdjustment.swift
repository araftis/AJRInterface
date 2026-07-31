//
//  AJRImageAdjustmentSlice.swift
//  AJRInterface
//
//  Created by AJ Raftis on 7/28/26.
//

import Cocoa

@objcMembers
open class AJRInspectorSliceImageAdjustment: AJRInspectorSlice {

    // Outlets
    @IBOutlet var minImageView: NSImageView!
    @IBOutlet var maxImageView: NSImageView!
    @IBOutlet var valueSlider: AJRTrackingSlider!

    // Observables
    open var enabledKey : AJRInspectorKey<Bool>?
    open var valueKey : AJRInspectorKey<CGFloat>?
    open var roleKey : AJRInspectorKey<AJRImageAdjustment>?

    open override var nibName: String? {
        return "AJRInspectorSliceImageAdjustment"
    }

    open override func tearDown() {
        minImageView = nil
        maxImageView = nil
        valueSlider = nil
        enabledKey?.stopObserving()
        valueKey?.stopObserving()
        roleKey?.stopObserving()
        super.tearDown()
    }

    open override func populateKnownKeys(_ keys: inout Set<String>) -> Void {
        super.populateKnownKeys(&keys)
        keys.insert("enabled")
        keys.insert("value")
        keys.insert("role")
    }

    // MARK: - View

    open override func buildView(from element: XMLElement) throws {
        valueKey = try AJRInspectorKey(key: "value", xmlElement: element, inspectorElement: self)
        roleKey = try AJRInspectorKey(key: "role", xmlElement: element, inspectorElement: self)
        enabledKey = try AJRInspectorKey(key: "enabled", xmlElement: element, inspectorElement: self)

        try super.buildView(from: element)

        // We only need to do this if something is tracking our value.
        valueSlider.willBeginTracking = { [weak self] in
            guard let self else { return }
            valueKey?.sendBeginUndoableChange()
        }
        valueSlider.didEndTracking = { [weak self] in
            guard let self else { return }
            valueKey?.sendCommitUndoableChange()
        }

        if roleKey == nil {
            // The user didn't explicitly define the role, so we'll try to infer from the value's keyPath
            if let rawRole = (valueKey?.keyPath as? NSString)?.pathExtension,
               let role = AJRImageAdjustmentFromString(rawRole) {
                minImageView.image = role.minImage
                maxImageView.image = role.maxImage
                valueSlider.minValue = role.min
                valueSlider.maxValue = role.max
            }
        }

        valueKey?.addObserver { [weak self] in
            guard let self else { return }
            guard let valueKey = self.valueKey else { return }
            let enabled = self.enabledKey?.value ?? true
            switch valueKey.selectionType {
            case .none:
                self.valueSlider.doubleValue = 0.0
                self.valueSlider.isEnabled = false
            case .multiple:
                self.valueSlider.doubleValue = valueKey.value ?? 0.0
                self.valueSlider.isEnabled = enabled
            case .single:
                self.valueSlider.doubleValue = valueKey.value ?? 0.0
                self.valueSlider.isEnabled = enabled
            }
        }
        enabledKey?.addObserver { [weak self] in
            guard let self else { return }
            guard let enabled = self.enabledKey?.value else { return }
            self.valueSlider.isEnabled = enabled
        }
        roleKey?.addObserver { [weak self] in
            guard let self else { return }
            guard let role = self.roleKey?.value else {
                AJRLog.warning("Missing or invalid value for key \"role\".")
                return
            }
            self.minImageView.image = role.minImage
            self.maxImageView.image = role.maxImage
            self.valueSlider.minValue = role.min
            self.valueSlider.maxValue = role.max
        }
    }

    // MARK: - Actions

    @IBAction open func takeValueFrom(_ slider: NSSlider?) -> Void {
        valueKey?.value = valueSlider.doubleValue
    }

}
