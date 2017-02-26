//
//  PropertyTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 26.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

class PropertyTest: QuickSpec {
    
    override func spec() {
        describe("Property") {
            describe("init") {
                it("assigns unique id") {
                    let property1 = Property<Int>(defaultValue: 0)
                    let property2 = Property<Int>(defaultValue: 0)
                    
                    expect(property1.id) != property2.id
                }
                it("sets defaultValue") {
                    let property = Property<Int>(defaultValue: 1)
                    
                    expect(property.defaultValue) == 1
                }
                it("sets defaultValue to nil for Optional types") {
                    let property = Property<Int?>()
                    
                    expect(property.defaultValue).to(beNil())
                }
            }
        }
    }
}
