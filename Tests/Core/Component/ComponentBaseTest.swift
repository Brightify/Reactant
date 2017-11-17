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
                _ = MockComponentBase<Void, Void>(canUpdate: false)
                _ = MockComponentBase<Int, Void>(canUpdate: true)
                _ = MockComponentBase<[String], String>(canUpdate: true)
                _ = MockComponentBase<Void, [Int]>(canUpdate: false)
                _ = MockComponentBase<[Int], [Int]>(canUpdate: false)
            }
            it("calls update on init only once when componentState is Void") {
                let componentWithUpdate = MockComponentBase<Void, ComponentTestAction>(canUpdate: true)
                let componentNoUpdate = MockComponentBase<Void, ComponentTestAction>(canUpdate: false)

                verify(componentWithUpdate).update()
                verify(componentNoUpdate, never()).update()
            }
            it("does not call update on init when componentState is not Void") {
                let componentWithUpdate = MockComponentBase<Int, ComponentTestAction>(canUpdate: true)
                let componentNoUpdate = MockComponentBase<Int, ComponentTestAction>(canUpdate: false)

                verify(componentWithUpdate, never()).update()
                verify(componentNoUpdate, never()).update()
            }
            it("calls afterInit on init only once") {
                let componentWithUpdate = MockComponentBase<Int, ComponentTestAction>(canUpdate: true)
                let componentNoUpdate = MockComponentBase<Int, ComponentTestAction>(canUpdate: false)

                verify(componentWithUpdate).afterInit()
                verify(componentNoUpdate).afterInit()
            }
        }
    }
}
