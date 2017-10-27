//
//  UIColor+ModificatorsTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 18.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

class UIColorModificatorsTest: QuickSpec {
    
    override func spec() {
        describe("UIColor") {
            let color = UIColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 0.5)
            let grey = UIColor(white: 0.5, alpha: 0.5)
            describe("darker") {
                it("works with rgb") {
                    self.assert(UIColor(red: 0.25, green: 0.05, blue: 0.05, alpha: 0.5), color.darker(by: 50%))
                }
                it("works with greyscale") {
                    self.assert(UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 0.5), grey.darker(by: 50%))
                }
            }
            describe("lighter") {
                it("works with rgb") {
                    self.assert(UIColor(red: 0.75, green: 0.15, blue: 0.15, alpha: 0.5), color.lighter(by: 50%))
                }
                it("works with greyscale") {
                    self.assert(UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.5), grey.lighter(by: 50%))
                }
            }
            describe("saturated") {
                it("works with rgb") {
                    self.assert(UIColor(red: 0.5, green: 0, blue: 0, alpha: 0.5), color.saturated(by: 50%))
                }
                it("works with greyscale") {
                    self.assert(UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5), grey.saturated(by: 50%))
                }
            }
            describe("desaturated") {
                it("works with rgb") {
                    self.assert(UIColor(red: 0.5, green: 0.3, blue: 0.3, alpha: 0.5), color.desaturated(by: 50%))
                }
                it("works with greyscale") {
                    self.assert(UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5), grey.desaturated(by: 50%))
                }
            }
            describe("fadedIn") {
                it("works with rgb") {
                    self.assert(UIColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 0.75), color.fadedIn(by: 50%))
                }
                it("works with greyscale") {
                    self.assert(UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.75), grey.fadedIn(by: 50%))
                }
            }
            describe("fadedOut") {
                it("works with rgb") {
                    self.assert(UIColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 0.25), color.fadedOut(by: 50%))
                }
                it("works with greyscale") {
                    self.assert(UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.25), grey.fadedOut(by: 50%))
                }
            }
        }
    }
    
    private func assert(_ expected: UIColor, _ actual: UIColor, file: StaticString = #file, line: UInt = #line) {
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        var a2: CGFloat = 0
        
        expected.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        actual.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let accuracy = CGFloat.ulpOfOne
        let message = "\(expected) is not equal to \(actual)"
        XCTAssertEqual(r1, r2, accuracy: accuracy, message, file: file, line: line)
        XCTAssertEqual(g1, g2, accuracy: accuracy, message, file: file, line: line)
        XCTAssertEqual(b1, b2, accuracy: accuracy, message, file: file, line: line)
        XCTAssertEqual(a1, a2, accuracy: accuracy, message, file: file, line: line)
    }
}
