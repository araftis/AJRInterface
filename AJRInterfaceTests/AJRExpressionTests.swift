/*
 AJRExpressionTests.swift
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
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
        // Just a quickie to make sure everything loaded correctly.
        test(expression: "5 + 5", expectedResult: 10)
    }

    func testColors() throws {
        test(expression: "colors.black", expectedResult: NSColor.black)
        test(expression: "colors.darkGray", expectedResult: NSColor.darkGray)
        test(expression: "colors.darkGrey", expectedResult: NSColor.darkGray)
        test(expression: "colors.lightGray", expectedResult: NSColor.lightGray)
        test(expression: "colors.lightGrey", expectedResult: NSColor.lightGray)
        test(expression: "colors.white", expectedResult: NSColor.white)
        test(expression: "colors.gray", expectedResult: NSColor.gray)
        test(expression: "colors.grey", expectedResult: NSColor.gray)
        test(expression: "colors.red", expectedResult: NSColor.red)
        test(expression: "colors.green", expectedResult: NSColor.green)
        test(expression: "colors.blue", expectedResult: NSColor.blue)
        test(expression: "colors.cyan", expectedResult: NSColor.cyan)
        test(expression: "colors.yellow", expectedResult: NSColor.yellow)
        test(expression: "colors.magenta", expectedResult: NSColor.magenta)
        test(expression: "colors.orange", expectedResult: NSColor.orange)
        test(expression: "colors.purple", expectedResult: NSColor.purple)
        test(expression: "colors.brown", expectedResult: NSColor.brown)
        test(expression: "colors.clear", expectedResult: NSColor.clear)
    }

}
