//
//  UILabel+InitTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 18.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

class UILabelInitTest: QuickSpec {
    
    override func spec() {
        describe("UILabel init") {
            it("creates UILabel with text") {
                expect(UILabel(text: "text").text) == "text"
            }
        }
    }
}
