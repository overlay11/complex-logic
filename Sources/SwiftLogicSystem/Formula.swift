enum Formula: Hashable {
    case strongEntailment(premise: Statement, conclusion: Statement)
    case reversibleStrongEntailment(Statement, Statement)
    case degenerateEntailment(Statement)
    case quasiEntailment(premise: Statement, conclusion: Statement)
    case weakEntailment(premise: Statement, conclusion: Statement)
    case maximalEntailment(premise: Statement, conclusion: Statement)
    case converseEntailment(premise: Statement, conclusion: Statement)
}

extension Formula {
    func isTautology() -> Bool {
        switch self {
        case let .reversibleStrongEntailment(x, y):
            return (x |- y).isTautology() && (y |- x).isTautology()
        case let .degenerateEntailment(x):
            return x.isTautology()
        case let .strongEntailment(premise, conclusion),
             let .weakEntailment(premise, conclusion),
             let .maximalEntailment(premise, conclusion),
             let .converseEntailment(premise, conclusion),
             let .quasiEntailment(premise, conclusion):
            guard self.containsQuantifiers() else {
                return (premise ~~> conclusion).isTautology()
            }
            return (premise ~~> conclusion).isTautology(under: premise) && (~conclusion ~~> ~premise).isTautology(under: ~conclusion)
        }
    }

    func isParadox() -> Bool {
        switch self {
        case let .strongEntailment(x, y), let .converseEntailment(y, x):
            return !x.elementaryStatements().isSuperset(of: y.elementaryStatements())
        case let .reversibleStrongEntailment(x, y), let .maximalEntailment(x, y):
            return x.elementaryStatements() != y.elementaryStatements()
        case .degenerateEntailment, .quasiEntailment:
            return false
        case let .weakEntailment(premise, conclusion):
            return premise.elementaryStatements().isDisjoint(with: conclusion.elementaryStatements())
        }
    }

    func isProvable() -> Bool {
        guard self.containsQuantifiers() else {
            return !self.isParadox() && self.isTautology()
        }
        guard self*.isProvable() else {
            return false
        }
        switch self {
        case let .reversibleStrongEntailment(x, y):
            return (x |- y).controlForm()!.isTautology() && (y |- x).controlForm()!.isTautology()
        default:
            return self.controlForm()!.isTautology()
        }
    }

    func controlPremiseAndConclusion() -> (premise: Statement, conclusion: Statement)? {
        switch self {
        case let .strongEntailment(premise, conclusion),
             let .weakEntailment(premise, conclusion),
             let .maximalEntailment(premise, conclusion),
             let .converseEntailment(premise, conclusion),
             let .quasiEntailment(premise, conclusion):
            guard (|-(~premise))*.isProvable() || (|-conclusion)*.isProvable() else {
                return (premise, conclusion)
            }
            let (x, y) = (premise**, conclusion**)
            let controlLiterals = x.controlLiterals().union(y.controlLiterals())
            let substitutions = Dictionary(uniqueKeysWithValues: controlLiterals.enumerated().map { ($0.1, Statement("\($0.0)")) })
            let assistiveLiterals = substitutions.values
            return (assistiveLiterals.reduce(x[substitutions], &&), assistiveLiterals.reduce(y[substitutions], &&))
        default:
            return nil
        }
    }

    func controlForm() -> Formula? {
        switch self {
        case .reversibleStrongEntailment:
            return nil
        case .degenerateEntailment:
            return self
        case .strongEntailment:
            let (x, y) = self.controlPremiseAndConclusion()!
            return .strongEntailment(premise: x, conclusion: y)
        case .weakEntailment:
            let (x, y) = self.controlPremiseAndConclusion()!
            return .weakEntailment(premise: x, conclusion: y)
        case .maximalEntailment:
            let (x, y) = self.controlPremiseAndConclusion()!
            return .maximalEntailment(premise: x, conclusion: y)
        case .converseEntailment:
            let (x, y) = self.controlPremiseAndConclusion()!
            return .converseEntailment(premise: x, conclusion: y)
        case .quasiEntailment:
            let (x, y) = self.controlPremiseAndConclusion()!
            return .quasiEntailment(premise: x, conclusion: y)
        }
    }

    // Quantifier-free form
    static postfix func * (f: Formula) -> Formula {
        switch f {
        case let .degenerateEntailment(x):
            return .degenerateEntailment(x*)
        case let .strongEntailment(x, y):
            return .strongEntailment(premise: x*, conclusion: y*)
        case let .weakEntailment(x, y):
            return .weakEntailment(premise: x*, conclusion: y*)
        case let .maximalEntailment(x, y):
            return .maximalEntailment(premise: x*, conclusion: y*)
        case let .converseEntailment(x, y):
            return .converseEntailment(premise: x*, conclusion: y*)
        case let .quasiEntailment(x, y):
            return .quasiEntailment(premise: x*, conclusion: y*)
        case let .reversibleStrongEntailment(x, y):
            return .reversibleStrongEntailment(x*, y*)
        }
    }

    func containsQuantifiers() -> Bool {
        switch self {
        case let .strongEntailment(x, y),
             let .weakEntailment(x, y),
             let .maximalEntailment(x, y),
             let .converseEntailment(x, y),
             let .quasiEntailment(x, y),
             let .reversibleStrongEntailment(x, y):
            return x.containsQuantifiers() || y.containsQuantifiers()
        case let .degenerateEntailment(x):
            return x.containsQuantifiers()
        }
    }
}

func |- (x: Statement, y: Statement) -> Formula {
    return .strongEntailment(premise: x, conclusion: y)
}
func |- (x: [Statement], y: Statement) -> Formula {
    return x.isEmpty ? |-y : (x.dropFirst().reduce(x.first!, &&) |- y)
}

func -||- (x: Statement, y: Statement) -> Formula {
    return .reversibleStrongEntailment(x, y)
}

func >-- (x: Statement, y: Statement) -> Formula {
    return .weakEntailment(premise: x, conclusion: y)
}
func >-- (x: [Statement], y: Statement) -> Formula {
    return x.isEmpty ? |-y : (x.dropFirst().reduce(x.first!, &&) >-- y)
}

func ||- (x: Statement, y: Statement) -> Formula {
    return .maximalEntailment(premise: x, conclusion: y)
}
func ||- (x: [Statement], y: Statement) -> Formula {
    return x.isEmpty ? |-y : (x.dropFirst().reduce(x.first!, &&) ||- y)
}

func >>-- (x: Statement, y: Statement) -> Formula {
    return .converseEntailment(premise: x, conclusion: y)
}
func >>-- (x: [Statement], y: Statement) -> Formula {
    return x.isEmpty ? |-y : (x.dropFirst().reduce(x.first!, &&) >>-- y)
}

func >--> (x: Statement, y: Statement) -> Formula {
    return .quasiEntailment(premise: x, conclusion: y)
}
func >--> (x: [Statement], y: Statement) -> Formula {
    return x.isEmpty ? |-y : (x.dropFirst().reduce(x.first!, &&) >--> y)
}

prefix func |- (x: Statement) -> Formula {
    return .degenerateEntailment(x)
}

extension Formula: Visualizable {
    var precedence: Precedence {
        switch self {
        case .degenerateEntailment:
            return .prefixPrecedence
        default:
            return .entailmentPrecedence
        }
    }
    func subexpressions() -> [Visualizable] {
        switch self {
        case let .degenerateEntailment(x):
            return [x]
        case let .strongEntailment(x, y),
             let .weakEntailment(x, y),
             let .maximalEntailment(x, y),
             let .converseEntailment(x, y),
             let .quasiEntailment(x, y),
             let .reversibleStrongEntailment(x, y):
            return [x, y]
        }
    }
    var symbol: String {
        switch self {
        case .degenerateEntailment, .strongEntailment:
            return "|-"
        case .weakEntailment:
            return ">--"
        case .maximalEntailment:
            return "||-"
        case .converseEntailment:
            return ">>--"
        case .quasiEntailment:
            return ">-->"
        case .reversibleStrongEntailment:
            return "-||-"
        }
    }
}
