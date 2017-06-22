protocol Visualizable: CustomStringConvertible {
    var precedence: Precedence { get }
    func subexpressions() -> [Visualizable]
    var symbol: String { get }
}

extension Visualizable {
    func visualizeSubexpression(_ x: Visualizable) -> String {
        if self.precedence >= x.precedence {
            return "(\(x))"
        }
        return "\(x)"
    }
    func visualization() -> String {
        let subexpressions = self.subexpressions()
        switch self.precedence {
        case .functionalPrecedence:
            if !subexpressions.isEmpty {
                return "\(self.symbol)(" + subexpressions.map { "\($0)" }.joined(separator: ", ") + ")"
            }
            return self.symbol
        case .prefixPrecedence:
            return self.symbol + self.visualizeSubexpression(subexpressions.first!)
        case .postfixPrecedence:
            return self.visualizeSubexpression(subexpressions.first!) + self.symbol
        default:
            return subexpressions.map { self.visualizeSubexpression($0) }.joined(separator: " \(self.symbol) ")
        }
    }
    var description: String {
        return self.visualization()
    }
}
