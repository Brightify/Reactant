//
//  ComponentBase.swift
//  Reactant
//
//  Created by Matyáš Kříž on 16/11/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant
import RxSwift
import Cuckoo

class ComponentBaseTest: QuickSpec {
    override func spec() {
        describe("ComponentBase") {
            it("constructs successfully") {
                _ = MockComponentBase<Void, Void>(initialState: (), canUpdate: false)
                _ = MockComponentBase<Int, Void>(initialState: 0, canUpdate: true)
                _ = MockComponentBase<[String], String>(initialState: [], canUpdate: true)
                _ = MockComponentBase<Void, [Int]>(initialState: (), canUpdate: false)
                _ = MockComponentBase<[Int], [Int]>(initialState: [], canUpdate: false)
            }
            it("calls update on init only once when componentState is Void") {
                let componentWithUpdate = MockComponentBase<Void, ComponentTestAction>(initialState: (), canUpdate: true)
                let componentNoUpdate = MockComponentBase<Void, ComponentTestAction>(initialState: (), canUpdate: false)

                verify(componentWithUpdate).update()
                verify(componentNoUpdate, never()).update()
            }
            it("does not call update on init when componentState is not Void") {
                let componentWithUpdate = MockComponentBase<Int, ComponentTestAction>(initialState: 0, canUpdate: true)
                let componentNoUpdate = MockComponentBase<Int, ComponentTestAction>(initialState: 0, canUpdate: false)

                verify(componentWithUpdate).update()
                verify(componentNoUpdate, never()).update()
            }
            it("calls afterInit on init only once") {
                let componentWithUpdate = MockComponentBase<Int, ComponentTestAction>(initialState: 0, canUpdate: true)
                let componentNoUpdate = MockComponentBase<Int, ComponentTestAction>(initialState: 0, canUpdate: false)

                verify(componentWithUpdate).afterInit()
                verify(componentNoUpdate).afterInit()
            }
        }
    }
}
