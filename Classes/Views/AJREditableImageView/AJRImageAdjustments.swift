//
//  AJRImageAdjustments.swift
//  AJRInterface
//
//  Created by AJ Raftis on 7/28/26.
//

import Cocoa

import AJRFoundation

public struct AJRImageAdjustment: AJRInspectorValue {

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
    static let exposure = AJRImageAdjustment("exposure", min: -10.0, default: 0.0, max: 10.0)
    static let contrast = AJRImageAdjustment("contrast", min: 0.25, default: 1.0, max: 4.0)
    static let highlights = AJRImageAdjustment("highlights", min: 0.0, default: 0.0, max: 1.0)
    static let shadows = AJRImageAdjustment("shadows", min: 0.0, default: 0.0, max: 1.0)
    static var saturation = AJRImageAdjustment("saturation", min: 0.0, default: 1.0, max: 2.0)
    static var temperature = AJRImageAdjustment("temperature", min: 2500.0, default: 6500.0, max: 10500.0)
    static var tint = AJRImageAdjustment("tint", min: -150.0, default: 0.0, max: 150.0)
    static var sepia = AJRImageAdjustment("sepia", min:0.0, default: 0.0, max: 1.0)
    static var sharpness = AJRImageAdjustment("sharpness", min: -1.0, default: 0.0, max: 1.0)
}

public func AJRImageAdjustmentFromString(_ string: String) -> AJRImageAdjustment? {
    switch string.lowercased() {
    case AJRImageAdjustment.exposure.rawValue: return .exposure
    case AJRImageAdjustment.contrast.rawValue: return .contrast
    case AJRImageAdjustment.highlights.rawValue: return .highlights
    case AJRImageAdjustment.shadows.rawValue: return .shadows
    case AJRImageAdjustment.saturation.rawValue: return .saturation
    case AJRImageAdjustment.temperature.rawValue: return .temperature
    case AJRImageAdjustment.tint.rawValue: return .tint
    case AJRImageAdjustment.sepia.rawValue: return .sepia
    case AJRImageAdjustment.sharpness.rawValue: return .sharpness
    default: return nil
    }
}


private extension NSCoder {
    func decodeCGFloat(forKey key: AJRImageAdjustment) -> CGFloat {
        return self.decodeCGFloat(forKey: key.rawValue, defaultValue: key.default)
    }
}

@objcMembers
public class AJRImageAdjustments: NSObject, NSCopying, AJRXMLCoding, NSCoding {

    public static let identity = AJRImageAdjustments(editable: false)
    public private(set) var editable : Bool = true

    private var _exposure : CGFloat = AJRImageAdjustment.exposure.default
    dynamic open var exposure : CGFloat {
        get {
            return _exposure
        }
        set {
            if editable {
                _exposure = newValue
                notifyChangeObservers(ofChange: .exposure)
            }
        }
    }
    private var _contrast: CGFloat = AJRImageAdjustment.contrast.default
    dynamic open var contrast: CGFloat {
        get {
            return _contrast
        }
        set {
            if editable {
                _contrast = newValue
                notifyChangeObservers(ofChange: .contrast)
            }
        }
    }
    private var _highlights: CGFloat = AJRImageAdjustment.highlights.default
    dynamic open var highlights: CGFloat {
        get {
            return _highlights
        }
        set {
            if editable {
                _highlights = newValue
                notifyChangeObservers(ofChange: .highlights)
            }
        }
    }
    private var _shadows: CGFloat = AJRImageAdjustment.shadows.default
    dynamic open var shadows: CGFloat {
        get {
            return _shadows
        }
        set {
            if editable {
                _shadows = newValue
                notifyChangeObservers(ofChange: .shadows)
            }
        }
    }
    private var _saturation: CGFloat = AJRImageAdjustment.saturation.default
    dynamic open var saturation: CGFloat {
        get {
            return _saturation
        }
        set {
            if editable {
                _saturation = newValue
                notifyChangeObservers(ofChange: .saturation)
            }
        }
    }
    private var _temperature: CGFloat = AJRImageAdjustment.temperature.default
    dynamic open var temperature: CGFloat {
        get {
            return _temperature
        }
        set {
            if editable {
                _temperature = newValue
                notifyChangeObservers(ofChange: .temperature)
            }
        }
    }
    private var _tint: CGFloat = AJRImageAdjustment.tint.default
    dynamic open var tint: CGFloat {
        get {
            return _tint
        }
        set {
            if editable {
                _tint = newValue
                notifyChangeObservers(ofChange: .tint)
            }
        }
    }
    private var _sepia: CGFloat = AJRImageAdjustment.sepia.default
    dynamic open var sepia: CGFloat {
        get {
            return _sepia
        }
        set {
            if editable {
                _sepia = newValue
                notifyChangeObservers(ofChange: .sepia)
            }
        }
    }
    private var _sharpness: CGFloat = AJRImageAdjustment.sharpness.default
    dynamic open var sharpness: CGFloat {
        get {
            return _sharpness
        }
        set {
            if editable {
                _sharpness = newValue
                notifyChangeObservers(ofChange: .sharpness)
            }
        }
    }

    // MARK: - Creation

    required public override init() {
        super.init()
    }

    public init(editable: Bool = true) {
        super.init()
    }

    // MARK: - Utilities

    open var isIdentity: Bool {
        return self == .identity
    }

    // MARK: - Observation

    public typealias ChangeBlock = (AJRImageAdjustments, AJRImageAdjustment) -> Void
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

    open func notifyChangeObservers(ofChange key: AJRImageAdjustment) {
        for block in Array(observers.values) {
            block(self, key)
        }
    }

    // MARK: - NSCopying

    open func copy(with zone: NSZone? = nil) -> Any {
        let copy = AJRImageAdjustments()
        copy.exposure = exposure
        copy.contrast = contrast
        copy.highlights = highlights
        copy.shadows = shadows
        copy.saturation = saturation
        copy.temperature = temperature
        copy.tint = tint
        copy.sepia = sepia
        copy.sharpness = sharpness
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
        coder.encode(exposure, forKey: AJRImageAdjustment.exposure.rawValue)
        coder.encode(contrast, forKey: AJRImageAdjustment.contrast.rawValue)
        coder.encode(highlights, forKey: AJRImageAdjustment.highlights.rawValue)
        coder.encode(shadows, forKey: AJRImageAdjustment.shadows.rawValue)
        coder.encode(saturation, forKey: AJRImageAdjustment.saturation.rawValue)
        coder.encode(temperature, forKey: AJRImageAdjustment.temperature.rawValue)
        coder.encode(tint, forKey: AJRImageAdjustment.tint.rawValue)
        coder.encode(sepia, forKey: AJRImageAdjustment.sepia.rawValue)
        coder.encode(sharpness, forKey: AJRImageAdjustment.sharpness.rawValue)
    }

    public func decode(with coder: AJRXMLCoder) {
        coder.decodeCGFloat(forKey: AJRImageAdjustment.exposure.rawValue) { self.exposure = $0 }
        coder.decodeCGFloat(forKey: AJRImageAdjustment.contrast.rawValue) { self.contrast = $0 }
        coder.decodeCGFloat(forKey: AJRImageAdjustment.highlights.rawValue) { self.highlights = $0 }
        coder.decodeCGFloat(forKey: AJRImageAdjustment.shadows.rawValue) { self.shadows = $0 }
        coder.decodeCGFloat(forKey: AJRImageAdjustment.saturation.rawValue) { self.saturation = $0 }
        coder.decodeCGFloat(forKey: AJRImageAdjustment.temperature.rawValue) { self.temperature = $0 }
        coder.decodeCGFloat(forKey: AJRImageAdjustment.tint.rawValue) { self.tint = $0 }
        coder.decodeCGFloat(forKey: AJRImageAdjustment.sepia.rawValue) { self.sepia = $0 }
        coder.decodeCGFloat(forKey: AJRImageAdjustment.sharpness.rawValue) { self.sharpness = $0 }
    }

    // MARK: - NSCoding

    public func encode(with coder: NSCoder) {
        coder.encode(exposure, forKey: AJRImageAdjustment.exposure.rawValue)
        coder.encode(contrast, forKey: AJRImageAdjustment.contrast.rawValue)
        coder.encode(highlights, forKey: AJRImageAdjustment.highlights.rawValue)
        coder.encode(shadows, forKey: AJRImageAdjustment.shadows.rawValue)
        coder.encode(saturation, forKey: AJRImageAdjustment.saturation.rawValue)
        coder.encode(temperature, forKey: AJRImageAdjustment.temperature.rawValue)
        coder.encode(tint, forKey: AJRImageAdjustment.tint.rawValue)
        coder.encode(sepia, forKey: AJRImageAdjustment.sepia.rawValue)
        coder.encode(sharpness, forKey: AJRImageAdjustment.sharpness.rawValue)
        coder.encode(editable, forKey: "editable")
    }

    public required init?(coder: NSCoder) {
        super.init()
        editable = coder.decodeBool(forKey: "editable", defaultValue: true)
        // These assign to the private variables, because we may not be editable, but this is the one place we are allowed to edit these values.
        _exposure = coder.decodeCGFloat(forKey: .exposure)
        _contrast = coder.decodeCGFloat(forKey: .contrast)
        _highlights = coder.decodeCGFloat(forKey: .highlights)
        _shadows = coder.decodeCGFloat(forKey: .shadows)
        _saturation = coder.decodeCGFloat(forKey: .saturation)
        _temperature = coder.decodeCGFloat(forKey: .temperature)
        _tint = coder.decodeCGFloat(forKey: .tint)
        _sepia = coder.decodeCGFloat(forKey: .sepia)
        _sharpness = coder.decodeCGFloat(forKey: .sharpness)
    }

    public func value(forKey key: AJRImageAdjustment) -> CGFloat {
        return value(forKeyPath: key.rawValue) as? CGFloat ?? 0
    }

}
