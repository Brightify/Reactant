//
//  Array+UtilsTest.swift
//  ReactantTests
//
//  Created by Matyáš Kříž on 17/11/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

class ArrayExtensionsTest: QuickSpec {
    override func spec() {
        describe("Array extension methods") {
            let emptyArray = [] as [String]
            let nonEmptyArray = [1, 2, 3, 4]
            describe("arrayByAppending using empty array returns original array") {
                expect(emptyArray.arrayByAppending()).to(equal(emptyArray))
                expect(emptyArray.arrayByAppending([])).to(equal(emptyArray))
                expect(nonEmptyArray.arrayByAppending()).to(equal(nonEmptyArray))
                expect(nonEmptyArray.arrayByAppending([])).to(equal(nonEmptyArray))
            }
            describe("arrayByAppending can append one element") {
                expect(emptyArray.arrayByAppending("testko")).to(equal(["testko"]))
                expect(emptyArray.arrayByAppending(["testko"])).to(equal(["testko"]))
                expect(nonEmptyArray.arrayByAppending(5)).to(equal([1, 2, 3, 4, 5]))
                expect(nonEmptyArray.arrayByAppending([5])).to(equal([1, 2, 3, 4, 5]))
            }
            describe("arrayByAppending can append arbitrary number of elements") {
                expect(emptyArray.arrayByAppending("testko", "otestovane")).to(equal(["testko", "otestovane"]))
                expect(emptyArray.arrayByAppending(["testko", "otestovane"])).to(equal(["testko", "otestovane"]))
                expect(nonEmptyArray.arrayByAppending(5, 6, 7)).to(equal([1, 2, 3, 4, 5, 6, 7]))
                expect(nonEmptyArray.arrayByAppending([5, 6, 7])).to(equal([1, 2, 3, 4, 5, 6, 7]))
            }
        }
    }
}
