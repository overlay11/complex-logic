enum Predicate: Hashable {
    case variable(String)

    init(_ symbol: String) {
        self = .variable(symbol)
    }
}

extension Predicate {
    subscript(a: Subject) -> Statement {
        return a <-- self
    }
}

extension Predicate: Visualizable {
    var precedence: Precedence {
        switch self {
        case .variable:
            return .functionalPrecedence
        }
    }
    var symbol: String {
        switch self {
        case let .variable(symbol):
            return symbol
        }
    }
    func subexpressions() -> [Visualizable] {
        switch self {
        case .variable:
            return []
        }
    }
}
