//
//  PercentUtilsTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 18.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

class PercentUtilsTest: QuickSpec {
    
    override func spec() {
        describe("%") {
            it("returns percents") {
                expect(35%).to(beCloseTo(0.35, within: 0.35.ulp))
            }
            it("handles edge cases") {
                expect(0%).to(beCloseTo(0.0, within: 0.0.ulp))
                expect(100%).to(beCloseTo(1.0, within: Double.ulpOfOne))
                expect(-20%).to(beCloseTo(-0.2, within: 0.2.ulp))
                expect(1058%).to(beCloseTo(10.58, within: 10.58.ulp))
            }
        }
    }
}
