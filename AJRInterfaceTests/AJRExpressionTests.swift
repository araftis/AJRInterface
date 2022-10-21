//
//  AJRExpressionTests.swift
//  AJRInterfaceTests
//
//  Created by AJ Raftis on 10/20/22.
//

import XCTest
import AJRFoundation
import AJRInterface

final class AJRExpressionTests: XCTestCase {

    override func setUpWithError() throws {
        AJRPlugInManager.initializePlugInManager()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @discardableResult
    public func test(expression string: String,
                     with object: Any? = nil,
                     expectedResult: Any? = nil,
                     expectError: Bool = false) -> String? {
        var expression : AJREvaluation? = nil
        var localError : Error? = nil;

        do {
            expression = try AJRExpression.expression(string: string)
        } catch {
            localError = error
        }

        if localError == nil {
            XCTAssert(expression != nil, "Failed to parse expression: \(string)");

            do {
                var result = try expression?.evaluate(with: AJREvaluationContext(rootObject: object))
                if result is NSNull {
                    result = nil
                }
                print("[\(string)]: \(expression!) = \(result ?? "nil")")

                XCTAssert(AJRAnyEquals(result, expectedResult), "expression: \(string), expected result: \(expectedResult ?? "nil"), got: \(result ?? "nil")")
            } catch {
                localError = error
            }
        }

        if expectError {
            XCTAssert(localError != nil, "We expected a failure in expression: \"\(string)\", but didn't get one.");
            if let localError {
                return String(describing: localError)
            }
        } else {
            XCTAssert(localError == nil, "We didn't expect a failure, but got one in expression: \"\(string)\": \(localError!)");
        }

        return nil;
    }

    func testBasic() throws {
        test(expression: "5 + 5", expectedResult: 10)
    }

    func testColors() throws {
        test(expression: "black", expectedResult: NSColor.black)
        test(expression: "darkGray", expectedResult: NSColor.darkGray)
        test(expression: "darkGrey", expectedResult: NSColor.darkGray)
        test(expression: "lightGray", expectedResult: NSColor.lightGray)
        test(expression: "lightGrey", expectedResult: NSColor.lightGray)
        test(expression: "white", expectedResult: NSColor.white)
        test(expression: "gray", expectedResult: NSColor.gray)
        test(expression: "grey", expectedResult: NSColor.gray)
        test(expression: "red", expectedResult: NSColor.red)
        test(expression: "green", expectedResult: NSColor.green)
        test(expression: "blue", expectedResult: NSColor.blue)
        test(expression: "cyan", expectedResult: NSColor.cyan)
        test(expression: "yellow", expectedResult: NSColor.yellow)
        test(expression: "magenta", expectedResult: NSColor.magenta)
        test(expression: "orange", expectedResult: NSColor.orange)
        test(expression: "purple", expectedResult: NSColor.purple)
        test(expression: "brown", expectedResult: NSColor.brown)
        test(expression: "clear", expectedResult: NSColor.clear)
    }

}
