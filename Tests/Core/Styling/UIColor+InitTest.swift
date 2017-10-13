//
//  UIColor+InitTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 18.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

class UIColorInitTest: QuickSpec {
    
    override func spec() {
        describe("UIColor init") {
            it("accept rgb hex as String") {
                expect(UIColor(hex: "#FFFFFF")) == UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            }
            it("accept rgba hex as String") {
                expect(UIColor(hex: "#00FFFF00")) == UIColor(red: 0, green: 1, blue: 1, alpha: 0)
            }
            it("accept rgb hex as Int") {
                expect(UIColor(rgb: 0xFFFFFF)) == UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            }
            it("accept rgba hex as Int") {
                expect(UIColor(rgba: 0x00FFFF00)) == UIColor(red: 0, green: 1, blue: 1, alpha: 0)
            }
        }
    }
}
