//
//  NSAttributedString+AttributeTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 18.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

class NSAttributedStringAttributeTest: QuickSpec {
    
    override func spec() {
        describe("AttributedString + AttributedString") {
            it("sums") {
                expect(NSAttributedString(string: "A") + NSAttributedString(string: "B")) == NSAttributedString(string: "AB")
            }
        }
        describe("String + AttributedString") {
            it("sums") {
                expect("A" + NSAttributedString(string: "B")) == NSAttributedString(string: "AB")
            }
        }
        describe("AttributedString + String") {
            it("sums") {
                expect(NSAttributedString(string: "A") + "B") == NSAttributedString(string: "AB")
            }
        }
        describe("attributed") {
            it("creates AttributedString") {
                let attributes = [Attribute.baselineOffset(1), Attribute.expansion(1)]
                let attributedString = NSAttributedString(string: "A", attributes: attributes.toDictionary())
                
                expect("A".attributed(attributes)) == attributedString
                expect("A".attributed(Attribute.baselineOffset(1), Attribute.expansion(1))) == attributedString
            }
        }
    }
}
