//
//  CGAffineTransform+ShortcutTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 18.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

class CGAffineTransformShortcutTest: QuickSpec {
    
    override func spec() {
        describe("rotate") {
            it("creates CGAffineTransform") {
                expect(rotate()) == CGAffineTransform(rotationAngle: 0)
                expect(rotate(10)) == CGAffineTransform(rotationAngle: 10)
            }
        }
        describe("translate") {
            it("creates CGAffineTransform") {
                expect(translate()) == CGAffineTransform(translationX: 0, y: 0)
                expect(translate(x: 1)) == CGAffineTransform(translationX: 1, y: 0)
                expect(translate(y: 1)) == CGAffineTransform(translationX: 0, y: 1)
                expect(translate(x: 1, y: 1)) == CGAffineTransform(translationX: 1, y: 1)
            }
        }
        describe("scale") {
            it("creates CGAffineTransform") {
                expect(scale()) == CGAffineTransform(scaleX: 1, y: 1)
                expect(scale(x: 2)) == CGAffineTransform(scaleX: 2, y: 1)
                expect(scale(y: 2)) == CGAffineTransform(scaleX: 1, y: 2)
                expect(scale(x: 2, y: 2)) == CGAffineTransform(scaleX: 2, y: 2)
            }
        }
        describe("+") {
            it("sums vectors") {
                expect(translate(x: 5) + translate(y: 3)) == translate(x: 5, y: 3)
            }
        }
    }
}
