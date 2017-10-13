//
//  CGSize+InitTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 18.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

class CGSizeInitTest: QuickSpec {
    
    override func spec() {
        describe("CGSize init") {
            it("creates CGSize") {
                expect(CGSize(width: 0 as CGFloat, height: 0 as CGFloat)) == CGSize()
                expect(CGSize(width: 0, height: 0)) == CGSize()
                expect(CGSize(width: 1, height: 1)) == CGSize(1)
                expect(CGSize(width: 1, height: 0)) == CGSize(width: 1)
                expect(CGSize(width: 0, height: 1)) == CGSize(height: 1)
            }
        }
    }
}
