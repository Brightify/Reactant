//
//  AttributeTest.swift
//  Lipstick
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
                
                expect(attributes[NSBaselineOffsetAttributeName] as? Float) == 1
                expect(attributes[NSExpansionAttributeName] as? Float) == 2
            }
        }
    }
}
