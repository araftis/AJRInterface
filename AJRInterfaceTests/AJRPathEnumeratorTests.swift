//
//  AJRPathEnumeratorTests.swift
//  AJRInterfaceTests
//
//  Created by AJ Raftis on 3/24/23.
//

import XCTest
import AJRInterface

final class AJRPathEnumeratorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAJRBezierPathEnumeration() throws {
        let path = AJRBezierPath()

        path.move(to: CGPoint(x: 297.000000, y: 352.000000))
        path.line(to: CGPoint(x: 297.010000, y: 352.000000))
        path.line(to: CGPoint(x: 297.010000, y: 368.700000))
        path.line(to: CGPoint(x: 297.000000, y: 368.700000))
        path.close()
        path.move(to: CGPoint(x: 297.000000, y: 352.000000))

        let enumerator = path.pathEnumerator
        var points : [CGPoint] = [.zero, .zero, .zero]
        while let element = enumerator.nextElement(withPoints: &points) {
            print("element: \(element): \(points)")
        }
    }

    func testNSBezierPathEnumeration() throws {
        let path = NSBezierPath()

        path.move(to: CGPoint(x: 297.000000, y: 352.000000))
        path.line(to: CGPoint(x: 297.010000, y: 352.000000))
        path.line(to: CGPoint(x: 297.010000, y: 368.700000))
        path.line(to: CGPoint(x: 297.000000, y: 368.700000))
        path.close()
        path.move(to: CGPoint(x: 297.000000, y: 352.000000))

        let enumerator = path.pathEnumerator
        var points : [CGPoint] = [.zero, .zero, .zero]
        while let element = enumerator.nextElement(withPoints: &points) {
            print("element: \(element): \(points)")
        }
    }

}
