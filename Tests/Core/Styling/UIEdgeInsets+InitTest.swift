//
//  UIEdgeInsets+InitTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 18.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

class UIEdgeInsetsInitTest: QuickSpec {
    
    override func spec() {
        describe("UIEdgeInsets init") {
            it("creates UIEdgeInsets") {
                expect(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) == UIEdgeInsets()
                expect(UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)) == UIEdgeInsets(1)
                expect(UIEdgeInsets(top: 2, left: 1, bottom: 2, right: 1)) == UIEdgeInsets(horizontal: 1, vertical: 2)
                
                expect(UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)) == UIEdgeInsets(horizontal: 1)
                expect(UIEdgeInsets(top: 2, left: 1, bottom: 0, right: 1)) == UIEdgeInsets(horizontal: 1, top: 2)
                expect(UIEdgeInsets(top: 0, left: 1, bottom: 2, right: 1)) == UIEdgeInsets(horizontal: 1, bottom: 2)
                expect(UIEdgeInsets(top: 2, left: 1, bottom: 3, right: 1)) == UIEdgeInsets(horizontal: 1, top: 2, bottom: 3)
                
                expect(UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)) == UIEdgeInsets(vertical: 1)
                expect(UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 0)) == UIEdgeInsets(vertical: 1, left: 2)
                expect(UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 2)) == UIEdgeInsets(vertical: 1, right: 2)
                expect(UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 3)) == UIEdgeInsets(vertical: 1, left: 2, right: 3)
                
                expect(UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)) == UIEdgeInsets(top: 1)
                expect(UIEdgeInsets(top: 1, left: 1, bottom: 0, right: 0)) == UIEdgeInsets(top: 1, left: 1)
                expect(UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)) == UIEdgeInsets(top: 1, bottom: 1)
                expect(UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 1)) == UIEdgeInsets(top: 1, right: 1)
                expect(UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 0)) == UIEdgeInsets(top: 1, left: 1, bottom: 1)
                expect(UIEdgeInsets(top: 1, left: 1, bottom: 0, right: 1)) == UIEdgeInsets(top: 1, left: 1, right: 1)
                expect(UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 1)) == UIEdgeInsets(top: 1, bottom: 1, right: 1)
                
                expect(UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)) == UIEdgeInsets(left: 1)
                expect(UIEdgeInsets(top: 0, left: 1, bottom: 1, right: 0)) == UIEdgeInsets(left: 1, bottom: 1)
                expect(UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)) == UIEdgeInsets(left: 1, right: 1)
                expect(UIEdgeInsets(top: 0, left: 1, bottom: 1, right: 1)) == UIEdgeInsets(left: 1, bottom: 1, right: 1)
                
                expect(UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)) == UIEdgeInsets(bottom: 1)
                expect(UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 1)) == UIEdgeInsets(bottom: 1, right: 1)
                
                expect(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 1)) == UIEdgeInsets(right: 1)
            }
        }
    }
}
