@testable import SwiftLogicSystem

import XCTest

class TautologyTests: XCTestCase {
    func assertTautology(_ formula: Formula, line: UInt = #line) {
        XCTAssert(formula.isTautology(), line: line)
    }
    func assertNotTautology(_ formula: Formula, line: UInt = #line) {
        XCTAssertFalse(formula.isTautology(), line: line)
    }

    let (x, y, z) = Statement.xyz
    let (u, v, _) = Statement.uvw
    let (a, p) = (Subject("a"), Predicate("p"))

    func testconditionalSentences() {
        assertTautology([x, y] |- x ~~> y)
        assertNotTautology([x, y] |- x --> y)

        assertTautology(x ∧ y ~~> u ∨ v |- (x ~~> u) ∨ (y ~~> v))
        assertNotTautology(x ∧ y --> u ∨ v |- (x --> u) ∨ (y --> v))

        assertTautology(x ∧ y ~~> z |- (x ~~> z) ∨ (y ~~> z))
        assertNotTautology(x ∧ y --> z |- (x --> z) ∨ (y --> z))

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
    }

    func testPredication() {
        assertTautology(p[a] -||- ~(!p[a]) ∧ ~(a ?<-- p))
        assertTautology(!p[a] -||- ~p[a] ∧ ~(a ?<-- p))
        assertTautology(|-(p[a] ∨ !p[a] ∨ (a ?<-- p)))
        assertNotTautology(~(!p[a]) |- p[a])
        assertNotTautology(|-(p[a] ∨ !p[a]))
    }
}
