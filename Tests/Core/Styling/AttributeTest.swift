//
//  AttributeTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 18.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

class AttributeTest: QuickSpec {
    
    override func spec() {
        describe("toDictionary") {
            it("creates dictionary from array of attributes") {
                let attributes = [Attribute.baselineOffset(1), Attribute.expansion(2)].toDictionary()
                
                expect(attributes[NSAttributedString.Key.baselineOffset] as? Float) == 1
                expect(attributes[NSAttributedString.Key.expansion] as? Float) == 2
            }
        }
    }
}
