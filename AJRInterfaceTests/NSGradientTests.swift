//
//  NSGradientTests.swift
//  AJRInterfaceTests
//
//  Created by AJ Raftis on 3/27/23.
//

import XCTest
import AJRInterface

final class NSGradientTests: XCTestCase {

    override func setUpWithError() throws {
        _ = AJRPlugInManager.shared
    }

    func testGradientCoding() throws -> Void {
        // This may seem like a lot of work, but we want to make sure everything stays in the same color space. That makes sure our colors roundtrip cleanly.
        let red   = NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let green = NSColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        let blue  = NSColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        let colors = [red, green, blue]
        var locations : [CGFloat] = [0.0, 0.5, 1.0]
        let test = NSGradient(colors: colors, atLocations: &locations, colorSpace: NSColorSpace.sRGB)!

        let data = AJRXMLArchiver.archivedData(withRootObject: test)
        XCTAssert(data != nil, "gradient failed to archive")
        if let data {
            if let string = String(data: data, encoding: .utf8) {
                print(string)
            }
            if let decoded = try? AJRXMLUnarchiver.unarchivedObject(with: data) as? NSGradient {
                print("\(decoded): \(AJRAnyEquals(test, decoded))")
                print("stops: test: \(test.numberOfColorStops), decoded: \(decoded.numberOfColorStops) == \(AJRAnyEquals(test.numberOfColorStops, decoded.numberOfColorStops))")
                print("colorSpace: test: \(test.colorSpace), decoded: \(decoded.colorSpace) == \(AJRAnyEquals(test.colorSpace, decoded.colorSpace))")
                for x in 0 ..< min(test.numberOfColorStops, decoded.numberOfColorStops) {
                    let testStop : NSColorStop = test[x]
                    let decodedStop : NSColorStop = decoded[x]
                    print("color \(x): test: \(testStop.color), \(testStop.location), decoded: \(decodedStop.color), \(decodedStop.location) == \(AJRAnyEquals(testStop.color, decodedStop.color)), \(AJRAnyEquals(testStop.location, decodedStop.location))")
                }
                XCTAssert(AJRAnyEquals(test, decoded))
            }
        }
    }

}
