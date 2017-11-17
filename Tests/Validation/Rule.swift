//
//  Rule.swift
//  Reactant
//
//  Created by Matyáš Kříž on 26/10/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant
import Result

class RuleTest: QuickSpec {
    override func spec() {
        describe("Rule Validation Tests") {
            let permissiveRule = Rule<String?, ValidationError> { _ in nil }
            let restrictiveRule = Rule<String?, ValidationError> { _ in .invalid }
            let divBy2StringLengthRule = Rule<String, ValidationError> { string in
                return string.count % 2 == 0 ? nil : .invalid
            }
            describe("anything should pass permissive rule") {
                expect(permissiveRule.test("value")).to(beTrue())
                expect(permissiveRule.test("")).to(beTrue())
                expect(permissiveRule.test(nil)).to(beTrue())

                if case .failure = permissiveRule.run("value") {
                    fail()
                }
                if case .failure = permissiveRule.run(nil) {
                    fail()
                }
            }
            describe("nothing should pass restrictive rule") {
                expect(restrictiveRule.test("value")).to(beFalse())
                expect(restrictiveRule.test("")).to(beFalse())
                expect(restrictiveRule.test(nil)).to(beFalse())

                if case .success = restrictiveRule.run("value") {
                    fail()
                }
                if case .success = restrictiveRule.run(nil) {
                    fail()
                }
            }
            describe("strings appropriate should pass \"div by 2 string length rule\" and others should not") {
                expect(divBy2StringLengthRule.test("")).to(beTrue())
                expect(divBy2StringLengthRule.test("nilu")).to(beTrue())
                expect(divBy2StringLengthRule.test("value")).to(beFalse())
                expect(divBy2StringLengthRule.test("valueueueueueueue")).to(beFalse())

                if case .failure = divBy2StringLengthRule.run("") {
                    fail()
                }
                if case .failure = divBy2StringLengthRule.run("valu") {
                    fail()
                }
                if case .success = divBy2StringLengthRule.run("value") {
                    fail()
                }
                if case .success = divBy2StringLengthRule.run("valueueueueueueue") {
                    fail()
                }
            }
        }
    }
}
