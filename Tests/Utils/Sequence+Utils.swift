//
//  Sequence+Utils.swift
//  Reactant
//
//  Created by Matyáš Kříž on 26/10/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

enum TestingEnum {
    case withValue(Int)
    case noValue

    var value: Int? {
        switch self {
        case .withValue(let value):
            return value
        case .noValue:
            return nil
        }
    }
}

extension Sequence where Iterator.Element == TestingEnum {
    func testEquality(to other: [TestingEnum]) {
        for element in self {
            expect(other.contains { $0.value == element.value }).to(beTrue())
        }
        for element in other {
            expect(self.contains { $0.value == element.value }).to(beTrue())
        }
    }
}

class SequenceExtensionsTest: QuickSpec {
    override func spec() {
        describe("Sequence extension methods") {
            describe("take(until:)") {
                it("takes nothing from an empty array") {
                    expect([Int]().prefix(while: { _ in false })).to(beEmpty())
                }
                it("takes correct elements from a positive integer array") {
                    let integerArray = Array(1...42)

                    let limit = 13
                    let takenArray = integerArray.prefix(while: { $0 != limit })
                    for integer in 1...(limit - 1) {
                        expect(takenArray).to(contain(integer))
                    }
                    expect(takenArray.last).to(equal(limit - 1))
                }
                it("takes nothing with falsy closure") {
                    let array = ["Doesn't", "Really", "Matter"]
                    let takenArray = array.prefix(while: { _ in false })
                    expect(takenArray).to(beEmpty())
                }
                it("takes everything with truthy closure") {
                    let array = ["Doesn't", "Really", "Matter"]
                    let takenArray = Array(array.prefix(while: { _ in true }))
                    expect(takenArray).to(equal(array))
                }
            }
            describe("all(predicate:)") {
                it("returns true for an empty array") {
                    let array = [] as [Int]
                    expect(array.allSatisfy { _ in false }).to(beTrue())
                    expect(array.allSatisfy { $0 % 42 == 0 }).to(beTrue())
                    expect(array.allSatisfy { _ in true }).to(beTrue())
                }
                it("returns false for predicate that doesn't match the array") {
                    let array = Array(1...42) as [Int]
                    expect(array.allSatisfy { $0 % 2 == 0 }).to(beFalse())
                    expect(array.allSatisfy { $0 % 3 == 0 }).to(beFalse())
                    expect(array.allSatisfy { $0 % 4 == 0 }).to(beFalse())
                    expect(array.allSatisfy { $0 % 5 == 0 }).to(beFalse())
                    expect(array.allSatisfy { $0 == 5 }).to(beFalse())
                }
                it("returns true for predicate that matches the array") {
                    let array = [1, 3, 5, 7, 9, 11]
                    expect(array.allSatisfy { $0 % 2 != 0 }).to(beTrue())
                }
            }
            describe("any(predicate:)") {
                it("returns false for an empty array, no element that could fit the predicate") {
                    let array = [] as [Int]
                    expect(array.contains { _ in false }).to(beFalse())
                    expect(array.contains { $0 % 42 == 0 }).to(beFalse())
                    expect(array.contains { _ in true }).to(beFalse())
                }
                it("returns true for predicate that matches only one element of the array") {
                    let array = Array(1...42)

                    for integer in array {
                        expect(array.contains { $0 == integer }).to(beTrue())
                    }
                }
                it("returns true for predicate that matches some of the elements of the array") {
                    let array = Array(1...42)

                    expect(array.contains { $0 % 2 == 0 }).to(beTrue())
                    expect(array.contains { $0 % 3 == 0 }).to(beTrue())
                    expect(array.contains { $0 % 4 == 0 }).to(beTrue())
                    expect(array.contains { $0 % 5 == 0 }).to(beTrue())
                }
                it("returns true for predicate that matches all elements of the array") {
                    let array = Array(1...42)

                    expect(array.contains { $0 % 1 == 0 }).to(beTrue())
                    expect(array.contains { _ in true }).to(beTrue())
                }
            }
            describe("distinct(comparator:)") {
                it("returns an empty array if called on empty array") {
                    let array = [] as [TestingEnum]
                    let distinctArray = [] as [TestingEnum]

                    array.testEquality(to: distinctArray)
                }
                it("returns the same array if array was distinct to begin with") {
                    let array = [.withValue(1), .withValue(2), .withValue(3)] as [TestingEnum]
                    let distinctArray = array.distinct(where: { $0.value == $1.value })
                    array.testEquality(to: distinctArray)
                }
                it("returns distinct array if the array has duplicites appended") {
                    let array = [.withValue(1), .withValue(2), .withValue(3), .withValue(4), .withValue(5)] as [TestingEnum]

                    var dupeArray = array
                    for number in 1...5 {
                        dupeArray.append(.withValue(number))
                        let distinctArray = dupeArray.distinct(where: { $0.value == $1.value })

                        array.testEquality(to: distinctArray)
                    }
                }
            }
            describe("distinct()") {
                it("returns an empty array if called on empty array") {
                    let array = [] as [Int]

                    expect(array.distinct()) == array
                }
                it("returns the same array if array was distinct to begin with") {
                    let array = [2, 3, 5, 7, 11, 13, 17] as [Int]

                    expect(array.distinct()) == array
                }
                it("returns distinct array if the array has duplicites appended") {
                    let array = [10, 2, 6, 1, 3, 4, 9, 5, 8, 7]
                    var dupeArray = array
                    for number in 1...10 {
                        dupeArray.append(number)
                        expect(dupeArray.distinct()).to(equal(array))
                    }
                }
            }
        }
    }
}
