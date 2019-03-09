@testable import SwiftLogicSystem

import XCTest

class FormulaTests: XCTestCase {
    func testVisualization() {
        let (x, y, z) = Statement.xyz

        func assertVisualization(_ formula: Formula, _ visualization: String, line: UInt = #line) {
            XCTAssertEqual("\(formula)", visualization, line: line)
        }

        assertVisualization(x |- y || z, "x |- y ∨ z")
    }
}
