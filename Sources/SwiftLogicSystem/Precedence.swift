enum Precedence: Int {
    case entailmentPrecedence = 0
    case arrowPrecedence
    case limitationPrecedence
    case disjunctionPrecedence
    case conjunctionPrecedence
    case prefixPrecedence
    case postfixPrecedence
    case functionalPrecedence
}

extension Precedence: Comparable {
    static func < (n: Precedence, m: Precedence) -> Bool {
        return n.rawValue < m.rawValue
    }
}
