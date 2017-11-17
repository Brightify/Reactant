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
            describe("initialization") {
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

            describe("componentState tests") {
                var componentWithState: MockComponentBase<Int, ComponentTestAction>!
                var componentNoState: MockComponentBase<Int, ComponentTestAction>!
                var componentNoUpdate: MockComponentBase<Int, ComponentTestAction>!

                beforeEach {
                    componentWithState = MockComponentBase<Int, ComponentTestAction>().with(state: 41)
                    componentNoState = MockComponentBase<Int, ComponentTestAction>()
                    componentNoUpdate = MockComponentBase<Int, ComponentTestAction>(canUpdate: false)
                }
                it("has a settable componentState") {
                    componentWithState.componentState = 0
                    componentNoState.componentState = 1
                    componentNoUpdate.componentState = 2
                }
                it("keeps its componentState") {
                    for i in -137...137 {
                        componentWithState.componentState = i
                        expect(componentWithState.componentState).to(equal(i))
                    }

                    for i in -137...137 {
                        componentNoState.componentState = i
                        expect(componentNoState.componentState).to(equal(i))
                    }

                    for i in -137...137 {
                        componentNoUpdate.componentState = i
                        expect(componentNoUpdate.componentState).to(equal(i))
                    }
                }
                it("throws exception when reading before a value is set") {
                    expect(componentNoState.componentState).to(raiseException())
                    expect(componentNoState.componentState).to(raiseException())
                    componentNoState.componentState = 0
                    expect(componentNoState.componentState).toNot(raiseException())
                }
            }

            describe("update tests") {
                var componentWithUpdate: MockComponentBase<Int, ComponentTestAction>!
                var componentNoUpdate: MockComponentBase<Int, ComponentTestAction>!

                beforeEach {
                    componentWithUpdate = MockComponentBase<Int, ComponentTestAction>(canUpdate: true).with(state: 41)
                    componentNoUpdate = MockComponentBase<Int, ComponentTestAction>(canUpdate: false)
                    // clearing update calls on init – these are tested higher ^
                    reset(componentWithUpdate)
                    reset(componentNoUpdate)
                }
                it("calls update on componentState modification if canUpdate is on") {
                    componentWithUpdate.componentState = 50
                    componentWithUpdate.componentState = 50
                    componentWithUpdate.componentState = 49
                    componentWithUpdate.componentState = 51

                    verify(componentWithUpdate, times(4)).update()
                }
                it("does not call update on componentState modification if canUpdate is off") {
                    componentNoUpdate.componentState = 1
                    componentNoUpdate.componentState = 2
                    componentNoUpdate.componentState = 3
                    componentNoUpdate.componentState = 4
                    verify(componentWithUpdate, never()).update()
                }
            }

            describe("action/actions tests") {
                var component: MockComponentBase<Int, ComponentTestAction>!
                var testDisposeBag: DisposeBag!

                beforeEach {
                    component = MockComponentBase<Int, ComponentTestAction>(canUpdate: true).with(state: 41)
                    testDisposeBag = DisposeBag()
                }
                it("subscribing to action catches perform(action:) calls") {
                    var received = false

                    component.action.subscribe(onNext: { action in
                        if case .one = action {
                            received = true
                        }
                    })
                    .disposed(by: testDisposeBag)

                    component.perform(action: .one)
                    expect(received).to(beTrue())
                }
                it("subscribing to action catches actions publications") {
                    var received = false

                    let subject = PublishSubject<ComponentTestAction>()

                    stub(component) { mock in
                        when(mock.actions.get).thenReturn([subject])
                    }

                    component.resetActions()

                    component.action.subscribe(onNext: { action in
                        if case .one = action {
                            received = true
                        }
                    })
                    .disposed(by: testDisposeBag)

                    subject.onNext(.one)
                    expect(received).to(beTrue())
                }
                
            }
        }
    }
}
