import XCTest

extension FormulaTests {
    static let __allTests = [
        ("testVisualization", testVisualization),
    ]
}

extension ProvabilityTests {
    static let __allTests = [
        ("testConverseEntailment", testConverseEntailment),
        ("testDegenerateEntailment", testDegenerateEntailment),
        ("testMaximalEntailment", testMaximalEntailment),
        ("testQuantifiers", testQuantifiers),
        ("testStrongEntailment", testStrongEntailment),
        ("testWeakEntailment", testWeakEntailment),
    ]
}

extension StatementTests {
    static let __allTests = [
        ("testVisualization", testVisualization),
    ]
}

extension TautologyTests {
    static let __allTests = [
        ("testconditionalSentences", testconditionalSentences),
        ("testPredication", testPredication),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(FormulaTests.__allTests),
        testCase(ProvabilityTests.__allTests),
        testCase(StatementTests.__allTests),
        testCase(TautologyTests.__allTests),
    ]
}
#endif
