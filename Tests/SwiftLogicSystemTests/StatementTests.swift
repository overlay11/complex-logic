@testable import SwiftLogicSystem

import XCTest

class StatementTests: XCTestCase {
    func testVisualization() {
        let (x, y, z) = Statement.xyz

        func assertVisualization(_ statement: Statement, _ visualization: String, line: UInt = #line) {
            XCTAssertEqual("\(statement)", visualization, line: line)
        }

        assertVisualization(x && y || z, "x ∧ y ∨ z")
    }
}
