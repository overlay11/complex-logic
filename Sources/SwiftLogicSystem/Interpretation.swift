typealias Interpretation = [Statement: Bool]

extension Dictionary where Key == Statement, Value == Bool {
    func isValid(under quantificationCondition: Statement?) -> Bool {
        for (statement, value) in self {
            switch statement {
            case let .conditionalStatement(antecedent, consequent):
                if let antivalue = self[antecedent !--> consequent], value && antivalue {
                    return false
                }
                if value {
                    let acceptedStatements = self.filter { $0.key != statement }.map { $0.key ** $0.value }
                    if (acceptedStatements ~~> antecedent && ~consequent).isTautology() {
                        return false
                    }
                } else {
                    if (antecedent ~~> consequent).isTautology() {
                        return false
                    }
                    let acceptedStatements = self.filter {
                        switch $0.key {
                        case .conditionalStatement:
                            return $0.value
                        case .negativeConditionalStatement:
                            return false
                        default:
                            return true
                        }
                    }.map { $0.key ** $0.value }
                    if acceptedStatements.contains(where: { $0.isConditionalStatement }) {
                        if !(acceptedStatements ~~> consequent).isTautology() && ((acceptedStatements + [antecedent]) ~~> consequent).isTautology() {
                            return false
                        }
                        if !(acceptedStatements ~~> ~antecedent).isTautology() && ((acceptedStatements + [~consequent]) ~~> ~antecedent).isTautology() {
                            return false
                        }
                    }
                }
            case let .negativeConditionalStatement(antecedent, consequent):
                if let antivalue = self[antecedent --> consequent], value && antivalue {
                    return false
                }
            case let .sentence(a, p):
                if let antivalue = self[a !<-- p], value && antivalue {
                    return false
                }
            case let .negativeSentence(a, p):
                if let antivalue = self[p[a]], value && antivalue {
                    return false
                }
            case let .universalQuantification(a, x):
                let acceptedStatements = self.filter { $0.key != statement }.map { $0.key ** $0.value }
                if a.occursFree(in: x) {
                    if value && (acceptedStatements ~~> ~x).isTautology(under: quantificationCondition) {
                        return false
                    }
                } else {
                    if (acceptedStatements ~~> (x ** !value)).isTautology(under: quantificationCondition) {
                        return false
                    }
                }
                if let u = quantificationCondition, // !a.occursFree(in: u),
                   (u ~~> x).isTautology(under: statement.occurs(in: u) ? nil : u) != value {
                    return false
                }
            case let .existentialQuantification(a, x):
                let acceptedStatements = self.filter { $0.key != statement }.map { $0.key ** $0.value }
                if a.occursFree(in: x) {
                    if !value && (acceptedStatements ~~> x).isTautology(under: quantificationCondition) {
                        return false
                    }
                } else {
                    if (acceptedStatements ~~> (x ** !value)).isTautology(under: quantificationCondition) {
                        return false
                    }
                }
                if let u = quantificationCondition, // !a.occursFree(in: u),
                   (u ~~> ~x).isTautology(under: statement.occurs(in: u) ? nil : u) == value {
                    return false
                }
            case let .negativeUniversalQuantification(a, x):
                if let antivalue = self[.universalQuantification(a, x)], value && antivalue {
                    return false
                }
            case let .negativeExistentialQuantification(a, x):
                if let antivalue = self[.existentialQuantification(a, x)], value && antivalue {
                    return false
                }
            default:
                continue
            }
        }
        return true
    }
}
