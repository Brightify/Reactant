//
//  UITableView+InitTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 18.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

class UITableViewInitTest: QuickSpec {
    
    override func spec() {
        describe("UITableView init") {
            it("creates UITableView with zero CGRect") {
                let view = UITableView(style: .plain)
                
                expect(view.frame) == CGRect.zero
                expect(view.style) == UITableView.Style.plain
            }
        }
    }
}
