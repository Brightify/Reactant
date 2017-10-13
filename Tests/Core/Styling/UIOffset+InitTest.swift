//
//  UIOffset+InitTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 18.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

class UIOffsetInitTest: QuickSpec {
    
    override func spec() {
        describe("UIOffset init") {
            it("creates UIOffset") {
                expect(UIOffset(horizontal: 0, vertical: 0)) == UIOffset()
                expect(UIOffset(horizontal: 1, vertical: 1)) == UIOffset(1)
                expect(UIOffset(horizontal: 1, vertical: 0)) == UIOffset(horizontal: 1)
                expect(UIOffset(horizontal: 0, vertical: 1)) == UIOffset(vertical: 1)
            }
        }
    }
}
