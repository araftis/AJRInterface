//
//  NSGradient+Extensions.swift
//  AJRInterface
//
//  Created by AJ Raftis on 3/26/23.
//

import Foundation

extension NSGradient : AJRUserDefaultProvider {

    public static func userDefault(forKey key: String, from userDefaults: UserDefaults) -> NSGradient? {
        if let data = userDefaults.data(forKey: key),
           let gradient = AJRObjectFromEncodedData(data, nil) as? NSGradient {
            return gradient
        }
        return nil
    }

    public static func setUserDefault(_ value: NSGradient?, forKey key: String, into userDefaults: UserDefaults) {
        if let value = value {
            if let data = AJRDataFromCodableObject(value) {
                userDefaults.set(data, forKey: key);
            }
        } else {
            userDefaults.set(nil, forKey: key)
        }
    }

}

extension NSGradient : AJRXMLCoding {

    internal class Placeholder : NSObject, AJRXMLDecoding {

        var colors = [NSColor]()
        var locations = [CGFloat]()
        var colorSpace : NSColorSpace? = nil

        required override init() {
        }

        func decode(with coder: AJRXMLCoder) {
            coder.decodeGroup(forKey: "stop") {
                coder.decodeObject(forKey: "color") { color in
                    if let color = color as? NSColor {
                        self.colors.append(color)
                    } else {
                        self.colors.append(.black)
                        AJRLog.in(domain: .xmlDecoding, message: "Gradient color failed to decode as a color.")
                    }
                }
                coder.decodeCGFloat(forKey: "location") { value in
                    self.locations.append(value)
                }
            } setter: {
                // Do nothing?
            }
            coder.decodeString(forKey: "colorSpace") { name in
                self.colorSpace = NSColorSpace.ajr_colorSpace(withName: name)
            }
        }

        func finalizeXMLDecoding() throws -> Any {
            if colors.count != locations.count {
                throw NSError(domain: AJRXMLDecodingErrorDomain, message: "When decoding an NSGradient, we decoded a different number of colors and locations. This indicates the XML has become corrupted. Failing.")
            }
            if let gradient = NSGradient(colors: colors, atLocations: &locations, colorSpace: colorSpace ?? NSColorSpace.displayP3) {
                return gradient
            }
            throw NSError(domain: AJRXMLDecodingErrorDomain, message: "Failed to produce a gradient from XML using values: colors: \(colors), locations: \(locations), colorSpace: \(colorSpace?.description ?? "No Color Space")")
        }

    }

    public static func instantiate(with coder: AJRXMLCoder) -> Any {
        return Placeholder()
    }
    
    public func encode(with coder: AJRXMLCoder) {
        coder.encode(colorSpace.ajr_name, forKey: "colorSpace")
        enumerate { color, location in
            coder.encodeGroup(forKey: "stop") {
                coder.encode(color, forKey: "color")
                coder.encode(location, forKey: "location")
            }
        }
    }

    open override class var ajr_nameForXMLArchiving: String {
        return "gradient"
    }

}

public typealias NSColorStop = (color: NSColor, location: CGFloat)

public extension NSGradient {

    convenience init?(colorStops: [NSColorStop], colorSpace: NSColorSpace = .sRGB) {
        let colors = colorStops.map { (color: NSColor, location: CGFloat) in
            return color
        }
        var locations = colorStops.map { (color: NSColor, location: CGFloat) in
            return location
        }
        self.init(colors: colors, atLocations: &locations, colorSpace: colorSpace)
    }

    func enumerate(using block: (_ color: NSColor, _ location: CGFloat) -> Void) {
        for x in 0 ..< self.numberOfColorStops {
            var color : NSColor = .black
            var location : CGFloat = 0.0

            getColor(&color, location: &location, at: x)
            block(color, location)
        }
    }

    subscript(_ index: Int) -> NSColor {
        var color : NSColor = .black
        getColor(&color, location: nil, at: index)
        return color
    }

    subscript(_ index: Int) -> CGFloat {
        var location : CGFloat = 0.0
        getColor(nil, location: &location, at: index)
        return location
    }

    subscript(_ index: Int) -> NSColorStop {
        var color : NSColor = .black
        var location : CGFloat = 0.0
        getColor(&color, location: &location, at: index)
        return (color: color, location: location)
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? NSGradient {
            if !AJRAnyEquals(numberOfColorStops, object.numberOfColorStops) {
                return false
            }
            if !AJRAnyEquals(colorSpace, object.colorSpace) {
                return false
            }
            for x in 0 ..< numberOfColorStops {
                let leftStop : NSColorStop = self[x]
                let rightStop : NSColorStop = object[x]
                if !AJRAnyEquals(leftStop.color, rightStop.color) {
                    return false
                }
                if !AJRAnyEquals(leftStop.location, rightStop.location) {
                    return false
                }
            }
            return true
        }
        return false
    }

    var colorStops : [NSColorStop] {
        var stops = [NSColorStop]()
        for x in 0 ..< numberOfColorStops {
            var color : NSColor = .clear
            var location : CGFloat = 0.0
            getColor(&color, location: &location, at: x)
            stops.append((color: color, location: location))
        }
        return stops
    }

    var colors : [NSColor] {
        var colors = [NSColor]()
        for x in 0 ..< numberOfColorStops {
            var color : NSColor = .clear
            getColor(&color, location: nil, at: x)
            colors.append(color)
        }
        return colors
    }

    var locations : [CGFloat] {
        var locations = [CGFloat]()
        for x in 0 ..< numberOfColorStops {
            var location : CGFloat = 0.0
            getColor(nil, location: &location, at: x)
            locations.append(location)
        }
        return locations
    }

}

public extension NSGradient {

    func draw(in path: AJRBezierPath, angle: CGFloat) -> Void {
        draw(in: path.asBezierPath, angle: angle)
    }

}

public extension AJRXMLCoder {

    func decodeGradient(forKey key: String, setter: ((NSGradient?) -> Void)?) -> Void {
        if let setter {
            decodeObject(forKey: key) { value in
                if let value = value as? NSGradient {
                    setter(value)
                }
            }
        }
    }

}
