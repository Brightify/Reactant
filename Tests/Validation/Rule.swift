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
            describe("anything should pass permissive rule") {
                expect(permissiveRule.test("value")).to(beTruthy())
                expect(permissiveRule.test("")).to(beTruthy())
                expect(permissiveRule.test(nil)).to(beTruthy())

                if case .success = permissiveRule.run("value") {
                } else {
                    fail()
                }
                if case .success = permissiveRule.run(nil) {
                } else {
                    fail()
                }
            }
            describe("nothing should pass restrictive rule") {
                expect(restrictiveRule.test("value")).to(beFalsy())
                expect(restrictiveRule.test("")).to(beFalsy())
                expect(restrictiveRule.test(nil)).to(beFalsy())

                if case .success = restrictiveRule.run("value") {
                } else {
                    fail()
                }
                if case .success = restrictiveRule.run(nil) {
                } else {
                    fail()
                }
            }
        }
    }
}
