precedencegroup EntailmentPrecedence {
    lowerThan: LogicalDisjunctionPrecedence, LogicalConjunctionPrecedence
}
precedencegroup ArrowPrecedence {
    higherThan: EntailmentPrecedence
    lowerThan: LogicalConjunctionPrecedence, LogicalDisjunctionPrecedence
}
precedencegroup LimitationPrecedence {
    higherThan: ArrowPrecedence, EntailmentPrecedence
    lowerThan: LogicalConjunctionPrecedence, LogicalDisjunctionPrecedence
}

// Operators of predication
infix operator <--: ArrowPrecedence
infix operator !<--: ArrowPrecedence
infix operator ?<--: ArrowPrecedence

// Dependence by value
infix operator --/: ArrowPrecedence
// Equivalence by value
infix operator /==/: ArrowPrecedence

// Operator of limitation
infix operator !!: LimitationPrecedence

// Operators of conditionality
infix operator -->: ArrowPrecedence
infix operator !-->: ArrowPrecedence
infix operator ?-->: ArrowPrecedence
infix operator <-->: ArrowPrecedence

// Material implication
infix operator ~~>: ArrowPrecedence
infix operator <~~>: ArrowPrecedence

// Strong logical entailment
infix operator |-: EntailmentPrecedence
infix operator -||-: EntailmentPrecedence
// Degenerate entailment
prefix operator |-
// Weakened entailment
infix operator >--: EntailmentPrecedence
// Maximal entailment
infix operator ||-: EntailmentPrecedence
// Converse entailment
infix operator >>--: EntailmentPrecedence
// Quasi-entailment
infix operator >-->: EntailmentPrecedence

// Weakened disjunction
infix operator ∨: LogicalDisjunctionPrecedence
// Strong disjunction
infix operator ^^: LogicalDisjunctionPrecedence
// Conjunction
infix operator ∧: LogicalConjunctionPrecedence

postfix operator *
postfix operator **
infix operator **
