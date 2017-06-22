import XCTest

extension FormulaTests {
    static let __allTests = [
        ("testProvability", testProvability),
        ("testTautology", testTautology),
    ]
}

extension StatementTests {
    static let __allTests = [
        ("testVisualization", testVisualization),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(FormulaTests.__allTests),
        testCase(StatementTests.__allTests),
    ]
}
#endif
