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
                _ = ComponentBase<Void, Void>(canUpdate: false)
                _ = ComponentBase<Int, Void>(canUpdate: true)
                _ = ComponentBase<[String], String>(canUpdate: true)
                _ = ComponentBase<Void, [Int]>(canUpdate: false)
                _ = ComponentBase<[Int], [Int]>(canUpdate: false)
            }
            it("calls update on init only once when componentState is Void") {
                let componentWithUpdate = ComponentBase<Void, ComponentTestAction>.spy(canUpdate: true)
                let componentNoUpdate = ComponentBase<Void, ComponentTestAction>.spy(canUpdate: false)

                verify(componentWithUpdate).update()
                verify(componentNoUpdate, never()).update()
            }
            it("does not call update on init when componentState is not Void") {
                let componentWithUpdate = ComponentBase<Int, ComponentTestAction>.spy(canUpdate: true)
                let componentNoUpdate = ComponentBase<Int, ComponentTestAction>.spy(canUpdate: false)

                verify(componentWithUpdate, never()).update()
                verify(componentNoUpdate, never()).update()
            }
            it("calls afterInit on init only once") {
                let componentWithUpdate = ComponentBase<Int, ComponentTestAction>.spy(canUpdate: true)
                let componentNoUpdate = ComponentBase<Int, ComponentTestAction>.spy(canUpdate: false)

                verify(componentWithUpdate).afterInit()
                verify(componentNoUpdate).afterInit()
            }
        }
    }
}
