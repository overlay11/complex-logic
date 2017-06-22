protocol StatementProtocol {
    static prefix func ~ (x: Self) -> Self
    static prefix func ! (x: Self) -> Self
    static func || (x: Self, y: Self) -> Self
    static func && (x: Self, y: Self) -> Self
    static func --> (x: Self, y: Self) -> Self
    static func !--> (x: Self, y: Self) -> Self
}

extension StatementProtocol {
    static func ∨ (x: Self, y: Self) -> Self {
        return x || y
    }
    static func ∧ (x: Self, y: Self) -> Self {
        return x && y
    }
    static func ^^ (x: Self, y: Self) -> Self {
        return (x || y) && (~x || ~y)
    }
    static func ~~> (x: Self, y: Self) -> Self {
        return ~x || y
    }
    static func ~~> (x: [Self], y: Self) -> Self {
        return x.isEmpty ? y : (x.dropFirst().reduce(x.first!, &&) ~~> y)
    }
    static func <~~> (x: Self, y: Self) -> Self {
        return (x ~~> y) && (y ~~> x)
    }
    static func ?--> (x: Self, y: Self) -> Self {
        return ~(x --> y) && ~(x !--> y)
    }
    static func <--> (x: Self, y: Self) -> Self {
        return (x --> y) && (y --> x)
    }
    static func ** (x: Self, alpha: Bool) -> Self {
        return alpha ? x : ~x
    }
}

enum Statement: Hashable {
    case variable(String)

    case sentence(Subject, Predicate)
    case negativeSentence(Subject, Predicate)

    indirect case negation(Statement)
    indirect case conjunction(Statement, Statement, [Statement])
    indirect case disjunction(Statement, Statement, [Statement])
    indirect case conditionalStatement(antecedent: Statement, consequent: Statement)
    indirect case negativeConditionalStatement(antecedent: Statement, consequent: Statement)

    indirect case universalQuantification(Term, Statement)
    indirect case negativeUniversalQuantification(Term, Statement)
    indirect case existentialQuantification(Term, Statement)
    indirect case negativeExistentialQuantification(Term, Statement)

    init(_ symbol: String) {
        self = .variable(symbol)
    }

    static let xyz = (Statement("x"), Statement("y"), Statement("z"))
    static let uvw = (Statement("u"), Statement("v"), Statement("w"))

    static var knownStatements: [Statement: Bool] = [:]
}

extension Statement: Comparable {
    static func < (x: Statement, y: Statement) -> Bool {
        switch (x, y) {
        case (.variable, .variable):
            return "\(x)" < "\(y)"
        case (_, .variable):
            return false
        case (.variable, _):
            return true
        default:
            return "\(x)" < "\(y)"
        }
    }
}

extension Statement {
    var isSentence: Bool {
        switch self {
        case .sentence, .negativeSentence:
            return true
        default:
            return false
        }
    }
    var isConditionalStatement: Bool {
        switch self {
        case .conditionalStatement, .negativeConditionalStatement:
            return true
        default:
            return false
        }
    }

    func truthValue(under interpretation: Interpretation) -> Bool {
        switch self {
        case let .negation(x):
            return !x.truthValue(under: interpretation)
        case let .conjunction(x, y, z):
            return z.reduce(x.truthValue(under: interpretation) && y.truthValue(under: interpretation)) {
                $0 && $1.truthValue(under: interpretation)
            }
        case let .disjunction(x, y, z):
            return z.reduce(x.truthValue(under: interpretation) || y.truthValue(under: interpretation)) {
                $0 || $1.truthValue(under: interpretation)
            }
        default:
            return interpretation[self]!
        }
    }

    func isTautology(under quantificationCondition: Statement? = nil) -> Bool {
        guard quantificationCondition == nil || !self.isTautology() else {
            return true
        }
        if let value = Statement.knownStatements[self], value || quantificationCondition == nil {
            return value
        }
        let interpretableStatements = self.interpretableStatements().sorted()
        for interpretationNumber in 0 ..< (1 << interpretableStatements.count) {
            let interpretation = Dictionary(
                uniqueKeysWithValues: zip(
                    interpretableStatements,
                    (0 ..< interpretableStatements.count).map {
                        interpretationNumber & (1 << $0) != 0
                    }
                )
            )
            if interpretation.isValid(under: quantificationCondition) && !self.truthValue(under: interpretation) {
                if quantificationCondition == nil {
                    Statement.knownStatements[self] = false
                }
                return false
            }
        }
        if quantificationCondition == nil {
            Statement.knownStatements[self] = true
        }
        return true
    }

    func elementaryStatements() -> Set<Statement> {
        switch self {
        case .variable, .sentence:
            return [self]
        case let .universalQuantification(_, x), let .negativeUniversalQuantification(_, x), let .existentialQuantification(_, x), let .negativeExistentialQuantification(_, x):
            return x.elementaryStatements()
        case let .negativeSentence(a, p):
            return [p[a]]
        case let .negation(x):
            return x.elementaryStatements()
        case let .conjunction(x, y, z), let .disjunction(x, y, z):
            return z.reduce(x.elementaryStatements().union(y.elementaryStatements())) {
                $0.union($1.elementaryStatements())
            }
        case let .conditionalStatement(x, y),
             let .negativeConditionalStatement(x, y):
            return x.elementaryStatements().union(y.elementaryStatements())
        }
    }

    func literals() -> Set<Statement> {
        switch self {
        case .variable,
             .sentence,
             .negativeSentence,
             .negation(.variable),
             .negation(.sentence),
             .negation(.negativeSentence):
            return [self]
        case let .negation(x):
            return x.literals()
        case let .universalQuantification(_, x), let .negativeUniversalQuantification(_, x), let .existentialQuantification(_, x), let .negativeExistentialQuantification(_, x):
            return x.literals()
        case let .conjunction(x, y, z), let .disjunction(x, y, z):
            return z.reduce(x.literals().union(y.literals())) {
                $0.union($1.literals())
            }
        case let .conditionalStatement(x, y),
             let .negativeConditionalStatement(x, y):
            return x.literals().union(y.literals())
        }
    }

    func controlLiterals() -> Set<Statement> {
        let literals = self.literals()
        return Set(literals.filter { literals.contains(~$0) }.map { ~$0 })
    }

    func interpretableStatements() -> Set<Statement> {
        switch self {
        case let .negation(x):
            return x.interpretableStatements()
        case let .conjunction(x, y, z), let .disjunction(x, y, z):
            return z.reduce(x.interpretableStatements().union(y.interpretableStatements())) {
                $0.union($1.interpretableStatements())
            }
        default:
            return [self]
        }
    }

    func occurs(in x: Statement) -> Bool {
        guard self != x else {
            return true
        }
        switch x {
        case let .negation(u), let .universalQuantification(_, u), let .negativeUniversalQuantification(_, u), let .existentialQuantification(_, u), let .negativeExistentialQuantification(_, u):
            return self.occurs(in: u)
        case let .conjunction(u, v, w), let .disjunction(u, v, w):
            return w.reduce(self.occurs(in: u) || self.occurs(in: v)) {
                $0 || self.occurs(in: $1)
            }
        case let .conditionalStatement(antecedent, consequent),
             let .negativeConditionalStatement(antecedent, consequent):
            return self.occurs(in: antecedent) || self.occurs(in: consequent)
        default:
            return false
        }
    }

    // Quantifier-free form
    static postfix func * (x: Statement) -> Statement {
        switch x {
        case let .negation(u), let .negativeUniversalQuantification(_, u), let .negativeExistentialQuantification(_, u):
            return .negation(u*)
        case let .conjunction(u, v, w):
            return w.map { $0* }.reduce(u* && v*, &&)
        case let .disjunction(u, v, w):
            return w.map { $0* }.reduce(u* || v*, ||)
        case let .conditionalStatement(u, v):
            return .conditionalStatement(antecedent: u*, consequent: v*)
        case let .negativeConditionalStatement(u, v):
            return .negativeConditionalStatement(antecedent: u*, consequent: v*)
        case let .universalQuantification(_, u), let .existentialQuantification(_, u):
            return u*
        default:
            return x
        }
    }

    // Pushing negations through
    static postfix func ** (x: Statement) -> Statement {
        switch x {
        case let .negation(.negation(u)):
            return u**
        case let .negation(.conjunction(u, v, w)):
            return w.map { (~$0)** }.reduce((~u)** || (~v)**, ||)
        case let .negation(.disjunction(u, v, w)):
            return w.map { (~$0)** }.reduce((~u)** && (~v)**, &&)
        case let .conjunction(u, v, w):
            return w.map { $0** }.reduce(u** && v**, &&)
        case let .disjunction(u, v, w):
            return w.map { $0** }.reduce(u** || v**, ||)
        default:
            return x
        }
    }

    // Substituting
    subscript(substitutions: [Statement: Statement]) -> Statement {
        if let substitution = substitutions[self] {
            return substitution
        }
        switch self {
        case let .negation(x):
            return .negation(x[substitutions])
        case let .conjunction(u, v, w):
            return w.map { $0[substitutions] }.reduce(u[substitutions] && v[substitutions], &&)
        case let .disjunction(u, v, w):
            return w.map { $0[substitutions] }.reduce(u[substitutions] || v[substitutions], ||)
        case let .conditionalStatement(u, v):
            return .conditionalStatement(antecedent: u[substitutions], consequent: v[substitutions])
        case let .negativeConditionalStatement(u, v):
            return .negativeConditionalStatement(antecedent: u[substitutions], consequent: v[substitutions])
        case let .universalQuantification(a, u):
            return .universalQuantification(a, u[substitutions])
        case let .existentialQuantification(a, u):
            return .existentialQuantification(a, u[substitutions])
        case let .negativeUniversalQuantification(a, u):
            return .negativeUniversalQuantification(a, u[substitutions])
        case let .negativeExistentialQuantification(a, u):
            return .negativeExistentialQuantification(a, u[substitutions])
        default:
            return self
        }
    }

    func containsQuantifiers() -> Bool {
        switch self {
        case .universalQuantification, .negativeUniversalQuantification, .existentialQuantification, .negativeExistentialQuantification:
            return true
        case let .negation(u):
            return u.containsQuantifiers()
        case let .conjunction(u, v, w), let .disjunction(u, v, w):
            return w.reduce(u.containsQuantifiers() || v.containsQuantifiers()) {
                $0 || $1.containsQuantifiers()
            }
        case let .conditionalStatement(antecedent, consequent),
             let .negativeConditionalStatement(antecedent, consequent):
            return antecedent.containsQuantifiers() || consequent.containsQuantifiers()
        case .sentence, .negativeSentence, .variable:
            return false
        }
    }
}

func forall(_ a: Subject, _ x: Statement) -> Statement {
    return .universalQuantification(Term(a), x)
}
func forall(_ p: Predicate, _ x: Statement) -> Statement {
    return .universalQuantification(Term(p), x)
}
func forall(_ a: Term, _ x: Statement) -> Statement {
    return .universalQuantification(a, x)
}

func exists(_ a: Subject, _ x: Statement) -> Statement {
    return .existentialQuantification(Term(a), x)
}
func exists(_ p: Predicate, _ x: Statement) -> Statement {
    return .existentialQuantification(Term(p), x)
}
func exists(_ a: Term, _ x: Statement) -> Statement {
    return .existentialQuantification(a, x)
}

func Ɐ(_ a: Subject, _ x: Statement) -> Statement {
    return forall(a, x)
}
func Ɐ(_ p: Predicate, _ x: Statement) -> Statement {
    return forall(p, x)
}
func Ɐ(_ a: Term, _ x: Statement) -> Statement {
    return forall(a, x)
}

func Ǝ(_ a: Subject, _ x: Statement) -> Statement {
    return exists(a, x)
}
func Ǝ(_ p: Predicate, _ x: Statement) -> Statement {
    return exists(p, x)
}
func Ǝ(_ a: Term, _ x: Statement) -> Statement {
    return exists(a, x)
}

extension Statement: StatementProtocol {
    static prefix func ~ (x: Statement) -> Statement {
        return .negation(x)
    }
    static prefix func ! (x: Statement) -> Statement {
        switch x {
        case let .sentence(a, p):
            return .negativeSentence(a, p)
        case let .universalQuantification(a, u):
            return .negativeUniversalQuantification(a, u)
        case let .existentialQuantification(a, u):
            return .negativeExistentialQuantification(a, u)
        case let .conditionalStatement(u, v):
            return .negativeConditionalStatement(antecedent: u, consequent: v)
        default:
            fatalError()
        }
    }
    static func || (x: Statement, y: Statement) -> Statement {
        switch (x, y) {
        case (let .disjunction(x1, x2, x3), let .disjunction(y1, y2, y3)):
            return .disjunction(x1, x2, x3 + [y1, y2] + y3)
        case (let .disjunction(x1, x2, x3), _):
            return .disjunction(x1, x2, x3 + [y])
        case (_, let .disjunction(y1, y2, y3)):
            return .disjunction(x, y1, [y2] + y3)
        default:
            return .disjunction(x, y, [])
        }
    }
    static func && (x: Statement, y: Statement) -> Statement {
        switch (x, y) {
        case (let .conjunction(x1, x2, x3), let .conjunction(y1, y2, y3)):
            return .conjunction(x1, x2, x3 + [y1, y2] + y3)
        case (let .conjunction(x1, x2, x3), _):
            return .conjunction(x1, x2, x3 + [y])
        case (_, let .conjunction(y1, y2, y3)):
            return .conjunction(x, y1, [y2] + y3)
        default:
            return .conjunction(x, y, [])
        }
    }
    static func --> (x: Statement, y: Statement) -> Statement {
        return .conditionalStatement(antecedent: x, consequent: y)
    }
    static func !--> (x: Statement, y: Statement) -> Statement {
        return .negativeConditionalStatement(antecedent: x, consequent: y)
    }
}

extension Statement: Visualizable {
    var precedence: Precedence {
        switch self {
        case .variable, .universalQuantification, .negativeUniversalQuantification, .existentialQuantification, .negativeExistentialQuantification:
            return .functionalPrecedence
        case .sentence, .negativeSentence, .conditionalStatement, .negativeConditionalStatement:
            return .arrowPrecedence
        case .conjunction:
            return .conjunctionPrecedence
        case .disjunction:
            return .disjunctionPrecedence
        case .negation:
            return .prefixPrecedence
        }
    }
    func subexpressions() -> [Visualizable] {
        switch self {
        case .variable:
            return []
        case let .negation(x):
            return [x]
        case let .conjunction(x, y, z), let .disjunction(x, y, z):
            return [x, y] + z
        case let .conditionalStatement(x, y), let .negativeConditionalStatement(x, y):
            return [x, y]
        case let .universalQuantification(a, x), let .negativeUniversalQuantification(a, x), let .existentialQuantification(a, x), let .negativeExistentialQuantification(a, x):
            return [a, x]
        case let .sentence(a, p), let .negativeSentence(a, p):
            return [a, p]
        }
    }
    var symbol: String {
        switch self {
        case let .variable(symbol):
            return symbol
        case .negation:
            return "~"
        case .disjunction:
            return "∨"
        case .conjunction:
            return "∧"
        case .conditionalStatement:
            return "-->"
        case .negativeConditionalStatement:
            return "!-->"
        case .universalQuantification:
            return "Ɐ"
        case .negativeUniversalQuantification:
            return "(!Ɐ)"
        case .existentialQuantification:
            return "Ǝ"
        case .negativeExistentialQuantification:
            return "(!Ǝ)"
        case .sentence:
            return "<--"
        case .negativeSentence:
            return "!<--"
        }
    }
}
