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

                if let error = permissiveRule.run("value") {
                    fail("Validation shouldn't fail with \(error)")
                }
                if let error = permissiveRule.run(nil) {
                    fail("Validation shouldn't fail with \(error)")
                }
            }
            describe("nothing should pass restrictive rule") {
                expect(restrictiveRule.test("value")).to(beFalse())
                expect(restrictiveRule.test("")).to(beFalse())
                expect(restrictiveRule.test(nil)).to(beFalse())

                if restrictiveRule.run("value") == nil {
                    fail("Validation should fail")
                }
                if restrictiveRule.run(nil) == nil {
                    fail("Validation should fail")
                }
            }
            describe("strings appropriate should pass \"div by 2 string length rule\" and others should not") {
                expect(divBy2StringLengthRule.test("")).to(beTrue())
                expect(divBy2StringLengthRule.test("nilu")).to(beTrue())
                expect(divBy2StringLengthRule.test("value")).to(beFalse())
                expect(divBy2StringLengthRule.test("valueueueueueueue")).to(beFalse())

                if let error = divBy2StringLengthRule.run("") {
                    fail("Validation shouldn't fail with \(error)")
                }
                if let error = divBy2StringLengthRule.run("valu") {
                    fail("Validation shouldn't fail with \(error)")
                }
                if divBy2StringLengthRule.run("value") == nil {
                    fail("Validation should fail")
                }
                if divBy2StringLengthRule.run("valueueueueueueue") == nil {
                    fail("Validation should fail")
                }
            }
        }
    }
}
