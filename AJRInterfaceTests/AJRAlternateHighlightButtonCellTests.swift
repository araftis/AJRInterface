
import XCTest

import AJRInterface

class AJRAlternateHighlightButtonCellTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        var copy : AJRAlternateHighlightButtonCell? = nil
        autoreleasepool {
            let cell = AJRAlternateHighlightButtonCell(textCell: "Test")
            print("cell: \(cell)")
            copy = cell.copy(with: nil) as? AJRAlternateHighlightButtonCell
        }
        print("copy: \(copy!)")
    }

}
