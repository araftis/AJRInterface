//
//  AJRImageAdjustments.swift
//  AJRInterface
//
//  Created by AJ Raftis on 7/28/26.
//

import Cocoa

import AJRFoundation
import CoreImage
import CoreImage.CIFilterBuiltins

public struct AJRImageAdjustment: AJRInspectorValue, Hashable {

    public let rawValue: String
    public let min: CGFloat
    public let `default`: CGFloat
    public let max: CGFloat

    init(_ rawValue: String, min: CGFloat, default: CGFloat, max: CGFloat) {
        self.rawValue = rawValue
        self.min = min
        self.default = `default`
        self.max = max
    }

    public var minImage: NSImage? {
        return NSImage.image(named: "\(rawValue)Low", in: AJRInterfaceBundle())
    }

    public var maxImage: NSImage? {
        return NSImage.image(named: "\(rawValue)High", in: AJRInterfaceBundle())
    }

    // MARK: - AJRInspectorValue

    public static func inspectorValue(from string: String) -> Any? {
        return AJRImageAdjustmentFromString(string)
    }

    public static func inspectorValue(from value: NSValue) -> Any? {
        nil
    }

    public var description: String {
        return rawValue
    }

}

public extension AJRImageAdjustment {
    /// This key is special, and never used to displays, or an associated set value. It's mostly just used by notify to indicate that all keys may have changed.
    static let all = AJRImageAdjustment("all", min: 0.0, default: 0.0, max: 0.0)
    static let exposure = AJRImageAdjustment("exposure", min: -10.0, default: 0.0, max: 10.0)
    static let contrast = AJRImageAdjustment("contrast", min: 0.25, default: 1.0, max: 4.0)
    static let highlights = AJRImageAdjustment("highlights", min: 0.0, default: 0.0, max: 1.0)
    static let shadows = AJRImageAdjustment("shadows", min: 0.0, default: 0.0, max: 1.0)
    static var saturation = AJRImageAdjustment("saturation", min: 0.0, default: 1.0, max: 2.0)
    static var temperature = AJRImageAdjustment("temperature", min: 2500.0, default: 6500.0, max: 10500.0)
    static var tint = AJRImageAdjustment("tint", min: -150.0, default: 0.0, max: 150.0)
    static var sepia = AJRImageAdjustment("sepia", min:0.0, default: 0.0, max: 1.0)
    static var sharpness = AJRImageAdjustment("sharpness", min: -1.0, default: 0.0, max: 1.0)
    static var allKeys = [exposure, contrast, highlights, shadows, saturation, temperature, tint, sepia, sharpness]
}

public func AJRImageAdjustmentFromString(_ string: String) -> AJRImageAdjustment? {
    let lower = string.lowercased()
    for key in AJRImageAdjustment.allKeys {
        if lower == key.rawValue { return key }
    }
    return nil
}


private extension NSCoder {
    func encode(_ value: CGFloat, forKey key: AJRImageAdjustment) -> Void {
        encode(value, forKey: key.rawValue)
    }
    func decodeCGFloat(forKey key: AJRImageAdjustment) -> CGFloat {
        return self.decodeCGFloat(forKey: key.rawValue, defaultValue: key.default)
    }
}

private extension AJRXMLCoder {
    func encode(_ value: CGFloat, forKey key: AJRImageAdjustment) {
        encode(value, forKey: key.rawValue)
    }
    func decodeCGFloat(forKey key: AJRImageAdjustment, block: @escaping (_:CGFloat) -> Void) -> Void {
        decodeCGFloat(forKey: key.rawValue, setter: block)
    }
}

@objcMembers
public class AJRImageAdjustments: NSObject, NSCopying, AJRXMLCoding, NSCoding, AJRInspectableUndoObservation {

    public static let identity = AJRImageAdjustments(editable: false)
    public private(set) var editable : Bool = true

    private var _values = [AJRImageAdjustment: CGFloat]()
    public subscript(_ key: AJRImageAdjustment) -> CGFloat {
        get { return _value(for: key) }
        set { _setValue(newValue, for: key, notify: true) }
    }
    private subscript(_ key: AJRImageAdjustment, notify: Bool = true) -> CGFloat {
        get { return _value(for: key) }
        set { _setValue(newValue, for: key, notify: notify) }
    }
    internal func _value(for key: AJRImageAdjustment) -> CGFloat {
        return _values[key] ?? key.default
    }
    internal func _setValue(_ value: CGFloat, for key: AJRImageAdjustment, notify: Bool = true) -> Void {
        assert(editable, "An attempt was made to mutate an immutable AJRImageAdjustments object. You probaby forgot to make a copy of the identity instance before mutating.")
        if _values[key] != value {
            _values[key] = value
            if notify {
                notifyChangeObserversOfChange(forAction: .changeValue, key: key)
            }
        }
    }
    dynamic open var exposure : CGFloat {
        get { return self[.exposure] }
        set { self[.exposure] = newValue }
    }
    dynamic open var contrast: CGFloat {
        get { return self[.contrast] }
        set { self[.contrast] = newValue }
    }
    dynamic open var highlights: CGFloat {
        get { return self[.highlights] }
        set { self[.highlights] = newValue }
    }
    dynamic open var shadows: CGFloat {
        get { return self[.shadows] }
        set { self[.shadows] = newValue }
    }
    dynamic open var saturation: CGFloat {
        get { return self[.saturation] }
        set { self[.saturation] = newValue }
    }
    dynamic open var temperature: CGFloat {
        get { return self[.temperature] }
        set { self[.temperature] = newValue }
    }
    dynamic open var tint: CGFloat {
        get { return self[.tint] }
        set { self[.tint] = newValue }
    }
    dynamic open var sepia: CGFloat {
        get { return self[.sepia] }
        set { self[.sepia] = newValue }
    }
    dynamic open var sharpness: CGFloat {
        get { return self[.sharpness] }
        set { self[.sharpness] = newValue }
    }

    // MARK: - Creation

    required public override init() {
        for key in AJRImageAdjustment.allKeys {
            _values[key] = key.default
        }
        super.init()
    }

    public convenience init(editable: Bool = true) {
        self.init()
        self.editable = editable
    }

    // MARK: - Utilities

    open var isIdentity: Bool {
        return self == .identity
    }

    open func imageByApplying(toAllRepresentationsIn image: NSImage) -> NSImage? {
        let newImage = NSImage(size: image.size)

        for representation in image.representations {
            if let cgImage = imageByApplying(to: representation.ajr_CGImage()) {
                newImage.addRepresentation(NSBitmapImageRep(cgImage: cgImage))
            }
        }

        return newImage
    }

    open func reset() -> Void {
        for key in AJRImageAdjustment.allKeys {
            _setValue(key.default, for: key, notify: false)
        }
        notifyChangeObserversOfChange(forAction: .changeValue, key: .all)
    }

    private static let imageContext = CIContext()
    private static let defaultOutputColorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

    private func outputColorSpace(for image: CGImage) -> CGColorSpace {
        if let colorSpace = image.colorSpace,
           colorSpace.model == .rgb {
            return colorSpace
        }

        return Self.defaultOutputColorSpace
    }

    open func imageByApplying(to image: CGImage?) -> CGImage? {
        guard let image else { return nil }

        let sourceImage = CIImage(cgImage: image)
        var outputImage = sourceImage

        for stage in Self.filterStages {
            outputImage = stage(outputImage, self)
        }

        return Self.imageContext.createCGImage(
            outputImage,
            from: sourceImage.extent,
            format: .RGBA8,
            colorSpace: outputColorSpace(for: image)
        )
    }

    // MARK: - Observation

    public enum ChangeAction {
        case beginUndoTracking
        case changeValue
        case commitUndoTracking
    }
    public typealias ChangeBlock = (AJRImageAdjustments, ChangeAction, AJRImageAdjustment) -> Void
    public typealias ObserverToken = AnyHashable

    internal var observers = [ObserverToken:ChangeBlock]()

    open func addChangeObserver(_ block: @escaping ChangeBlock) -> ObserverToken {
        let token = UUID()
        observers[token] = block
        return token
    }

    open func removeChangeObserver(_ token: ObserverToken) {
        observers.removeValue(forKey: token)
    }

    open func notifyChangeObserversOfChange(forAction action: ChangeAction, key: AJRImageAdjustment) {
        for block in Array(observers.values) {
            block(self, action, key)
        }
    }

    // MARK: - AJRInspectableUndoObservation

    public func inspectorWillBeginUndoableChange(forKey key: String) {
        if let key = AJRImageAdjustmentFromString((key as NSString).pathExtension) {
            notifyChangeObserversOfChange(forAction: .beginUndoTracking, key: key)
        }
    }

    public func inspectorDidCommitUndoableChange(forKey key: String) {
        if let key = AJRImageAdjustmentFromString((key as NSString).pathExtension) {
            notifyChangeObserversOfChange(forAction: .commitUndoTracking, key: key)
        }
    }

    // MARK: - NSCopying

    open func copy(with zone: NSZone? = nil) -> Any {
        self.copy(mutable: true) as! AJRImageAdjustments
    }

    open func copy(mutable copyIsMutable: Bool = true) -> Any {
        let copy = AJRImageAdjustments()
        for key in AJRImageAdjustment.allKeys {
            copy[key] = self[key]
        }
        if !copyIsMutable {
            copy.editable = false
        }
        return copy
    }

    // MARK: - Equality & Hashing

    override open func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? AJRImageAdjustments else { return false }
        return self == other
    }

    static func == (lhs: AJRImageAdjustments, rhs: AJRImageAdjustments) -> Bool {
        return (lhs.exposure == rhs.exposure &&
                lhs.contrast == rhs.contrast &&
                lhs.highlights == rhs.highlights &&
                lhs.shadows == rhs.shadows &&
                lhs.saturation == rhs.saturation &&
                lhs.temperature == rhs.temperature &&
                lhs.tint == rhs.tint &&
                lhs.sepia == rhs.sepia &&
                lhs.sharpness == rhs.sharpness)
    }

    override open var hash: Int {
        var hasher = Hasher()
        hasher.combine(exposure)
        hasher.combine(contrast)
        hasher.combine(highlights)
        hasher.combine(shadows)
        hasher.combine(saturation)
        hasher.combine(temperature)
        hasher.combine(tint)
        hasher.combine(sepia)
        hasher.combine(sharpness)
        return hasher.finalize()
    }

    // MARK: - AJRXMLCoding

    public override class var ajr_nameForXMLArchiving: String {
        return "imageAdjustments"
    }

    public func encode(with coder: AJRXMLCoder) {
        for key in AJRImageAdjustment.allKeys {
            if self[key] != key.default {
                coder.encode(self[key], forKey: key)
            }
        }
        if !editable {
            coder.encode(editable, forKey: "editble")
        }
    }

    public func decode(with coder: AJRXMLCoder) {
        editable = true
        for key in AJRImageAdjustment.allKeys {
            // We do this, because the XML coder doesn't call the call back if there's no key present. As such, we set the value to it's default here, and then allow that to be overridden if the key is found. This is important, because we're not going encode values that are the default.
            _setValue(key.default, for: key, notify: false)
            coder.decodeCGFloat(forKey: key) { self._setValue($0, for: key, notify: false) }
        }
        coder.decodeBool(forKey: "editble") { self.editable = $0 }
    }

    // MARK: - NSCoding

    public func encode(with coder: NSCoder) {
        for (key, value) in _values {
            coder.encode(value, forKey: key)
        }
        coder.encode(editable, forKey: "editable")
    }

    public required init?(coder: NSCoder) {
        super.init()

        editable = true
        for key in AJRImageAdjustment.allKeys {
            self._setValue(coder.decodeCGFloat(forKey: key), for: key, notify: false)
        }
        editable = coder.decodeBool(forKey: "editable", defaultValue: true)
    }

    public func value(forKey key: AJRImageAdjustment) -> CGFloat {
        return value(forKeyPath: key.rawValue) as? CGFloat ?? 0
    }

}

private extension AJRImageAdjustments {

    typealias FilterStage = (
        _ image: CIImage,
        _ adjustments: AJRImageAdjustments
    ) -> CIImage

    static let filterStages: [FilterStage] = [
        applyExposure,
        applyColorControls,
        applyHighlightAndShadow,
        applyTemperatureAndTint,
        applySepia,
        applySharpness,
    ]

}

private func applyExposure(to image: CIImage, adjustments: AJRImageAdjustments) -> CIImage {
    guard adjustments.exposure != AJRImageAdjustment.exposure.default else {
        return image
    }

    let filter = CIFilter.exposureAdjust()
    filter.inputImage = image
    filter.ev = Float(adjustments.exposure)

    return filter.outputImage ?? image
}

private func applyColorControls(to image: CIImage, adjustments: AJRImageAdjustments) -> CIImage {
    guard adjustments.contrast != AJRImageAdjustment.contrast.default
            || adjustments.saturation != AJRImageAdjustment.saturation.default else {
        return image
    }

    let filter = CIFilter.colorControls()
    filter.inputImage = image
    filter.contrast = Float(adjustments.contrast)
    filter.saturation = Float(adjustments.saturation)
    filter.brightness = 0.0

    return filter.outputImage ?? image
}

private func applyHighlightAndShadow(to image: CIImage, adjustments: AJRImageAdjustments) -> CIImage {
    guard adjustments.highlights != AJRImageAdjustment.highlights.default
            || adjustments.shadows != AJRImageAdjustment.shadows.default else {
        return image
    }

    let filter = CIFilter.highlightShadowAdjust()
    filter.inputImage = image
    filter.highlightAmount = Float(
        1.0 - adjustments.highlights * 0.7
    )
    filter.shadowAmount = Float(adjustments.shadows)

    return filter.outputImage ?? image
}

private func applyTemperatureAndTint(to image: CIImage, adjustments: AJRImageAdjustments) -> CIImage {
    guard adjustments.temperature != AJRImageAdjustment.temperature.default
            || adjustments.tint != AJRImageAdjustment.tint.default else {
        return image
    }

    let filter = CIFilter.temperatureAndTint()
    filter.inputImage = image
    filter.neutral = CIVector(x: 6500.0, y: 0.0)
    filter.targetNeutral = CIVector(
        x: adjustments.temperature,
        y: adjustments.tint
    )

    return filter.outputImage ?? image
}

private func applySepia(to image: CIImage, adjustments: AJRImageAdjustments) -> CIImage {
    guard adjustments.sepia != AJRImageAdjustment.sepia.default else {
        return image
    }

    let filter = CIFilter.sepiaTone()
    filter.inputImage = image
    filter.intensity = Float(adjustments.sepia)

    return filter.outputImage ?? image
}

private  func applySharpness(to image: CIImage, adjustments: AJRImageAdjustments) -> CIImage {
    if adjustments.sharpness < 0.0 {
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = image
        filter.radius = Float(-adjustments.sharpness * 5.0)
        return filter.outputImage?.cropped(to: image.extent) ?? image
    }

    if adjustments.sharpness > 0.0 {
        let filter = CIFilter.sharpenLuminance()
        filter.inputImage = image
        filter.sharpness = Float(adjustments.sharpness * 2.0)
        return filter.outputImage ?? image
    }

    return image
}
