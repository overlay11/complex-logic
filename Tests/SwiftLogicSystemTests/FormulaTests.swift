@testable import SwiftLogicSystem

import XCTest

class FormulaTests: XCTestCase {
    func testProvability() {
        func assertProvable(_ formula: Formula, line: UInt = #line) {
            XCTAssert(formula.isProvable(), line: line)
        }
        func assertNotProvable(_ formula: Formula, line: UInt = #line) {
            XCTAssertFalse(formula.isProvable(), line: line)
        }

        let (x, y, z) = Statement.xyz
        let (a, b, p, q) = (Subject("a"), Subject("b"), Predicate("p"), Predicate("q"))

        // Strong entailment

        assertProvable(x -||- ~(~x))
        assertProvable([x, y] |- x)
        assertProvable([x, y] |- y ∧ x)
        assertProvable(~(x ^^ y) -||- x ∧ y ^^ ~x ∧ ~y)
        assertProvable(x ∧ z ^^ y ∧ z -||- (x ^^ y) ∧ z)
        assertProvable((x ^^ y) ∧ z |- x ∧ z ^^ y)

        assertProvable(x ^^ y |- y ^^ x)
        assertProvable(x -||- x ^^ x ∧ ~x)
        assertProvable(x ^^ y -||- x ∧ ~y ^^ ~x ∧ y)
        assertProvable(x -||- x ∧ (x ^^ ~x))
        assertProvable(x ∧ z ^^ y |- (x ∧ z ^^ y) ∧ (x ^^ ~x))
        assertProvable([x ^^ y, x] |- ~y)

        assertNotProvable(x |- y ^^ ~y)
        assertNotProvable([~x, x] |- y)
        assertNotProvable(x |- ~(~y ∧ y))
        assertNotProvable(x |- y ~~> x)
        assertNotProvable(x |- ~x ~~> y)
        assertNotProvable(x |- y ∨ ~y)

        assertProvable(x ∧ ~x ^^ x ∧ y -||- x ∧ y)
        assertProvable(x ∧ ~x ∧ z ^^ y |- y)

        assertProvable([x ∨ y, z] |- x ∧ z ∨ y)
        assertProvable((x ∧ z) ∨ (y ∧ z) -||- (x ∨ y) ∧ z)
        assertProvable(~(x ∧ y) -||- ~x ∨ ~y)
        assertProvable(x ∧ y ∨ z |- (x ∧ y ∨ z) ∧ (y ∨ ~y))
        assertProvable(x ∨ (y ∧ ~y ∧ z) |- x)
        assertProvable(x ^^ y -||- x ∧ ~y ∨ ~x ∧ y)
        assertProvable(x ~~> y -||- ~x ∨ y)

        assertProvable(x ∧ y ∨ z -||- (x ∨ z) ∧ (y ∨ z))
        assertProvable(~(x ∨ y) -||- ~x ∧ ~y)
        assertProvable(x ∨ ~y ∧ y |- x)

        assertProvable(x |- x ^^ ~x)
        assertProvable(x |- x ∨ ~x)
        assertProvable([x, ~x] |- x)

        // Weakened entailment

        assertProvable(~x >-- ~(x ∧ y))

        assertNotProvable([~x, x] >-- y)
        assertNotProvable(x >-- y ^^ ~y)
        assertNotProvable(x >-- y ∨ ~y)
        assertNotProvable(x >-- ~(~y ∧ y))

        assertProvable(x >-- x ∧ (y ^^ ~y))
        assertProvable([x, y ^^ ~y] >-- x)

        // Maximal entailment

        assertProvable((x ^^ y) ∧ z ||- x ∧ z ^^ y ∧ z)

        // Converse entailment

        assertProvable(~x >>-- ~(x ∧ y))
        assertProvable(x >>-- x ∧ (y ^^ ~y))
        assertProvable(x >>-- x ∨ y)
        assertProvable(x >>-- x ∧ (y ∨ ~y))

        // Degenerate entailment

        assertProvable(|-(~(x ∧ ~x)))
        assertProvable(|-(x ∨ ~x))

        // Theory of quantifiers

        assertProvable(Ɐ(a, x) |- x)
        assertProvable(Ɐ(a, p[a]) |- p[a])

        assertProvable(x |- Ǝ(a, x))
        assertProvable(p[a] |- Ǝ(a, p[a]))

        assertProvable(Ɐ(a, x) ∧ Ǝ(a, y) |- Ǝ(a, x ∧ y))
        assertProvable(Ɐ(a, p[a]) ∧ Ǝ(a, q[a]) |- Ǝ(a, p[a] ∧ q[a]))

        assertProvable(Ɐ(a, x ∨ y) |- Ɐ(a, x) ∨ Ǝ(a, y))
        assertProvable(Ɐ(a, p[a] ∨ q[a]) |- Ɐ(a, p[a]) ∨ Ǝ(a, q[a]))

        assertProvable(Ǝ(a, x) |- Ɐ(a, x))
        assertNotProvable(Ǝ(a, p[a]) |- Ɐ(a, p[a]))

        assertProvable(Ɐ(a, x) -||- ~Ǝ(a, ~x))
        assertProvable(Ɐ(a, p[a]) -||- ~Ǝ(a, ~p[a]))

        assertNotProvable(Ɐ(a, p[a]) |- p[b])
        assertNotProvable(p[b] |- Ǝ(a, p[a]))

        assertProvable(~Ɐ(a, p[a]) |- Ǝ(a, ~p[a]))
        assertProvable(Ǝ(a, ~p[a]) |- ~Ɐ(a, p[a]))

        // K(a, p[a,b]) ∧ K(b, p[a,b]) |- K(a, K(b, p[a,b]))
        assertProvable(Ɐ(a, p[a] ∧ q[b]) ∧ Ɐ(b, p[a] ∧ q[b]) |- Ɐ(a, Ɐ(b, p[a] ∧ q[b])))
        assertProvable(Ɐ(a, p[a] ∧ q[b]) ∧ Ɐ(b, p[a] ∧ q[b]) |- Ɐ(a, Ǝ(b, p[a] ∧ q[b])))
        assertProvable(Ɐ(a, p[a] ∧ q[b]) ∧ Ǝ(b, p[a] ∧ q[b]) |- Ɐ(a, Ǝ(b, p[a] ∧ q[b])))
        assertProvable(Ǝ(a, p[a] ∧ q[b]) ∧ Ɐ(b, p[a] ∧ q[b]) |- Ǝ(a, Ɐ(b, p[a] ∧ q[b])))
        assertProvable(Ǝ(a, p[a] ∧ q[b]) ∧ Ǝ(b, p[a] ∧ q[b]) |- Ǝ(a, Ǝ(b, p[a] ∧ q[b])))

        // K(a, K(b, p[a,b])) |- K(b, K(a, p[a,b]))
        assertProvable(Ɐ(a, Ɐ(b, p[a] ∧ q[b])) |- Ɐ(b, Ɐ(a, p[a] ∧ q[b])))
        assertProvable(Ǝ(a, Ɐ(b, p[a] ∧ q[b])) |- Ɐ(b, Ǝ(a, p[a] ∧ q[b])))
        assertProvable(Ǝ(a, Ǝ(b, p[a] ∧ q[b])) |- Ǝ(b, Ǝ(a, p[a] ∧ q[b])))
        assertProvable(Ǝ(a, Ɐ(b, p[a] ∧ q[b])) |- Ǝ(b, Ǝ(a, p[a] ∧ q[b])))
        assertProvable(Ɐ(a, Ɐ(b, p[a] ∧ q[b])) |- Ɐ(b, Ǝ(a, p[a] ∧ q[b])))
        assertProvable(Ɐ(a, Ɐ(b, p[a] ∧ q[b])) |- Ǝ(b, Ɐ(a, p[a] ∧ q[b])))
        assertProvable(Ɐ(a, Ɐ(b, p[a] ∧ q[b])) |- Ǝ(b, Ǝ(a, p[a] ∧ q[b])))
        assertProvable(Ɐ(a, Ǝ(b, p[a] ∧ q[b])) |- Ǝ(b, Ǝ(a, p[a] ∧ q[b])))
        assertNotProvable(Ɐ(a, Ǝ(b, p[a] ∧ q[b])) |- Ǝ(b, Ɐ(a, p[a] ∧ q[b])))

        assertProvable(x |- Ɐ(a, x))
        assertNotProvable(p[a] |- Ɐ(a, p[a]))

        assertProvable(Ǝ(a, x) |- x)
        assertNotProvable(Ǝ(a, p[a]) |- p[a])

        assertProvable(Ɐ(a, p[a]) |- Ǝ(a, p[a]))

        // K(a, p[a] * q[a]) |- K(a, p[a]) * K(a, q[a])
        assertProvable(Ǝ(a, p[a] ∧ q[a]) |- Ǝ(a, p[a]) ∧ Ǝ(a, q[a]))
        assertProvable(Ɐ(a, p[a] ∧ q[a]) |- Ɐ(a, p[a]) ∧ Ǝ(a, q[a]))
        assertProvable(Ɐ(a, p[a] ∧ q[a]) |- Ǝ(a, p[a]) ∧ Ǝ(a, q[a]))
        assertProvable(Ɐ(a, p[a] ∨ q[a]) |- Ǝ(a, p[a]) ∨ Ɐ(a, q[a]))
        assertProvable(Ɐ(a, p[a] ∨ q[a]) |- Ǝ(a, p[a]) ∨ Ǝ(a, q[a]))
        assertNotProvable(Ɐ(a, p[a] ∨ q[a]) |- Ɐ(a, p[a]) ∨ Ɐ(a, q[a]))

        // K(a, p[a] * q[a]) -||- K(a, p[a]) * K(a, q[a])
        assertProvable(Ǝ(a, p[a] ∨ q[a]) -||- Ǝ(a, p[a]) ∨ Ǝ(a, q[a]))
        assertProvable(Ɐ(a, p[a] ∧ q[a]) -||- Ɐ(a, p[a]) ∧ Ɐ(a, q[a]))

        // K(a, p[a]) * K(a, q[a]) |- K(a, p[a] * q[a])
        assertProvable(Ɐ(a, p[a]) ∧ Ɐ(a, q[a]) |- Ǝ(a, p[a] ∧ q[a]))
        assertProvable(Ǝ(a, p[a]) ∧ Ɐ(a, q[a]) |- Ǝ(a, p[a] ∧ q[a]))
        assertProvable(Ɐ(a, p[a]) ∨ Ɐ(a, q[a]) |- Ɐ(a, p[a] ∨ q[a]))
        assertProvable(Ɐ(a, p[a]) ∨ Ǝ(a, q[a]) |- Ǝ(a, p[a] ∨ q[a]))
        assertProvable(Ɐ(a, p[a]) ∨ Ɐ(a, q[a]) |- Ǝ(a, p[a] ∨ q[a]))
        assertNotProvable(Ǝ(a, p[a]) ∧ Ǝ(a, q[a]) |- Ǝ(a, p[a] ∧ q[a]))
        assertNotProvable(Ɐ(a, p[a]) ∨ Ǝ(a, q[a]) |- Ɐ(a, p[a] ∨ q[a]))
    }

    func testTautology() {
        func assertTautology(_ formula: Formula, line: UInt = #line) {
            XCTAssert(formula.isTautology(), line: line)
        }
        func assertNotTautology(_ formula: Formula, line: UInt = #line) {
            XCTAssertFalse(formula.isTautology(), line: line)
        }

        let (x, y, z) = Statement.xyz
        let (u, v, _) = Statement.uvw
        let (a, p) = (Subject("a"), Predicate("p"))

        // General theory

        assertTautology([x, y] |- x ~~> y)
        assertNotTautology([x, y] |- x --> y)

        assertTautology(x ∧ y ~~> u ∨ v |- (x ~~> u) ∨ (y ~~> v))
        assertNotTautology(x ∧ y --> u ∨ v |- (x --> u) ∨ (y --> v))

        assertTautology(x ∧ y ~~> z |- (x ~~> z) ∨ (y ~~> z))
        assertNotTautology(x ∧ y --> z |- (x --> z) ∨ (y --> z))

        // Theory of conditional sentences

        assertTautology([x --> y, x] |- y)
        assertTautology(x --> y |- ~y --> ~x)
        assertTautology(|-(x ∧ y --> ~(x --> ~y)))
        assertTautology(|-((x --> y) --> (x ~~> y)))
        assertTautology(|-(~(x ~~> y) --> ~(x --> y)))
        assertNotTautology(y |- x --> y)
        assertTautology(|-(x ∧ y --> x))
        assertTautology([x --> y, y --> z] |- x --> z)

        assertTautology(x --> y -||- ~(x !--> y) ∧ ~(x ?--> y))
        assertTautology(x !--> y -||- ~(x --> y) ∧ ~(x ?--> y))
        assertNotTautology(~(x !--> y) |- x --> y)
        assertNotTautology(~(x --> y) |- x !--> y)

        assertTautology(x --> y ∧ z |- (x --> y) ∧ (x --> z))
        assertTautology(x ∧ y --> z -||- x --> (y --> z))
        assertTautology([x --> y, u --> v] |- x ∧ u --> y ∧ v)
        assertTautology((x --> y) ∨ (u --> v) |- x ∧ u --> y ∨ v)

        assertTautology([x ∧ y --> z, x] |- y --> z)
        assertTautology(x ∨ y --> z |- (x --> z) ∧ (y --> z))
        assertTautology(~y --> (x --> z) |- x --> y ∨ z)
        assertTautology([x --> y, u --> v] |- x ∨ u --> y ∨ v)

        assertTautology(x --> y >-- x ∧ z --> y)
        assertTautology(x --> y >-- x --> y ∨ z)

        assertTautology(|-((x --> y) ∧ (y --> z) --> (x --> y)))

        // Theory of predication

        assertTautology(p[a] -||- ~(!p[a]) ∧ ~(a ?<-- p))
        assertTautology(!p[a] -||- ~p[a] ∧ ~(a ?<-- p))
        assertTautology(|-(p[a] ∨ !p[a] ∨ (a ?<-- p)))
        assertNotTautology(~(!p[a]) |- p[a])
        assertNotTautology(|-(p[a] ∨ !p[a]))
    }
}
