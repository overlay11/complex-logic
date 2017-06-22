protocol SubjectProtocol {
    static func !! (a: Self, x: Statement) -> Self
    static func <-- (a: Self, p: Predicate) -> Statement
    static func !<-- (a: Self, p: Predicate) -> Statement
}

extension SubjectProtocol {
    static func !! (a: Self, p: Predicate) -> Self {
        return a !! (a <-- p)
    }
    static func ?<-- (a: Self, p: Predicate) -> Statement {
        return ~(a <-- p) && ~(a !<-- p)
    }
}

enum Subject: Hashable {
    case variable(String)

    indirect case limitation(Subject, Statement)

    init(_ symbol: String) {
        self = .variable(symbol)
    }
}

extension Subject: SubjectProtocol {
    static func !! (a: Subject, x: Statement) -> Subject {
        return .limitation(a, x)
    }
    static func <-- (a: Subject, p: Predicate) -> Statement {
        return .sentence(a, p)
    }
    static func !<-- (a: Subject, p: Predicate) -> Statement {
        return .negativeSentence(a, p)
    }
}

extension Subject: Visualizable {
    var precedence: Precedence {
        switch self {
        case .variable:
            return .functionalPrecedence
        case .limitation:
            return .limitationPrecedence
        }
    }
    func subexpressions() -> [Visualizable] {
        switch self {
        case .variable:
            return []
        case let .limitation(a, p):
            return [a, p]
        }
    }
    var symbol: String {
        switch self {
        case let .variable(symbol):
            return symbol
        case .limitation:
            return "!!"
        }
    }
}
