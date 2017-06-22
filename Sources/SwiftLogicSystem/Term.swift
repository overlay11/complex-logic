enum Term: Hashable {
    case variable(String)

    case predicate(Predicate)
    case subject(Subject)

    init(_ p: Predicate) {
        self = .predicate(p)
    }

    init(_ a: Subject) {
        self = .subject(a)
    }
}

extension Term {
    func occurs(in x: Statement) -> Bool {
        switch x {
        case .variable:
            return false
        case let .sentence(a, p), let .negativeSentence(a, p):
            return self == Term(a) || self == Term(p)
        case let .conjunction(u, v, w), let .disjunction(u, v, w):
            return w.reduce(self.occurs(in: u) || self.occurs(in: v)) {
                $0 || self.occurs(in: $1)
            }
        case let .conditionalStatement(antecedent, consequent),
             let .negativeConditionalStatement(antecedent, consequent):
            return self.occurs(in: antecedent) || self.occurs(in: consequent)
        case let .negation(u), let .universalQuantification(_, u), let .negativeUniversalQuantification(_, u), let .existentialQuantification(_, u), let .negativeExistentialQuantification(_, u):
            return self.occurs(in: u)
        }
    }
    func occursFree(in x: Statement) -> Bool {
        switch x {
        case .variable:
            return false
        case .sentence, .negativeSentence:
            return self.occurs(in: x)
        case let .negation(u):
            return self.occursFree(in: u)
        case let .conjunction(u, v, w), let .disjunction(u, v, w):
            return w.reduce(self.occursFree(in: u) || self.occursFree(in: v)) {
                $0 || self.occursFree(in: $1)
            }
        case let .conditionalStatement(antecedent, consequent),
             let .negativeConditionalStatement(antecedent, consequent):
            return self.occursFree(in: antecedent) || self.occursFree(in: consequent)
        case let .universalQuantification(a, u), let .negativeUniversalQuantification(a, u), let .existentialQuantification(a, u), let .negativeExistentialQuantification(a, u):
            return a == self ? false : self.occursFree(in: u)
        }
    }
    func occursBound(in x: Statement) -> Bool {
        switch x {
        case .variable, .sentence, .negativeSentence:
            return false
        case let .negation(u):
            return self.occursBound(in: u)
        case let .conjunction(u, v, w), let .disjunction(u, v, w):
            return w.reduce(self.occursBound(in: u) || self.occursBound(in: v)) {
                $0 || self.occursBound(in: $1)
            }
        case let .conditionalStatement(antecedent, consequent),
             let .negativeConditionalStatement(antecedent, consequent):
            return self.occursBound(in: antecedent) || self.occursBound(in: consequent)
        case let .universalQuantification(a, u), let .negativeUniversalQuantification(a, u), let .existentialQuantification(a, u), let .negativeExistentialQuantification(a, u):
            return a == self ? self.occurs(in: u) : self.occursBound(in: u)
        }
    }
}

extension Term: Visualizable {
    var precedence: Precedence {
        switch self {
        case .variable:
            return .functionalPrecedence
        case let .predicate(p):
            return p.precedence
        case let .subject(a):
            return a.precedence
        }
    }
    var symbol: String {
        switch self {
        case let .variable(symbol):
            return symbol
        case let .predicate(p):
            return p.symbol
        case let .subject(a):
            return a.symbol
        }
    }
    func subexpressions() -> [Visualizable] {
        switch self {
        case .variable:
            return []
        case let .predicate(p):
            return p.subexpressions()
        case let .subject(a):
            return a.subexpressions()
        }
    }
}
