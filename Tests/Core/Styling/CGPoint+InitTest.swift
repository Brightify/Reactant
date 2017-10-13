//
//  CGPoint+InitTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 18.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

class CGPointInitTest: QuickSpec {
    
    override func spec() {
        describe("CGPoint init") {
            it("creates CGPoint") {
                expect(CGPoint(x: 0, y: 0)) == CGPoint()
                expect(CGPoint(x: 1, y: 1)) == CGPoint(1)
                expect(CGPoint(x: 1, y: 0)) == CGPoint(x: 1)
                expect(CGPoint(x: 0, y: 1)) == CGPoint(y: 1)
            }
        }
    }
}
