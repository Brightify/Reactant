//
//  ComponentDelegateTest.swift
//  Reactant
//
//  Created by Matyáš Kříž on 16/11/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Quick
import Nimble
@testable import Reactant
import RxSwift
import Cuckoo

class ComponentDelegateTest: QuickSpec {
    override func spec() {
        // MARK:- Void Type Testing
        describe("ComponentDelegate<Void, ComponentTestAction>") {
            var mockComponent: MockComponentBase<Void, ComponentTestAction>!
            var delegate: ComponentDelegate<Void, ComponentTestAction>!
            beforeEach {
                mockComponent = MockComponentBase()
                delegate = ComponentDelegate(owner: mockComponent)
            }

            describe("componentState") {
                context("before first set") {
                    it("always has value of ()") {
                        expect(delegate.hasComponentState).to(beTrue())
                        expect(delegate.componentState).to(beVoid())
                    }
                }
            }
        }

        // MARK:- Primitive Type Testing
        describe("ComponentDelegate<Int>") {
            var mockComponent: MockComponentBase<Int, ComponentTestAction>!
            var delegate: ComponentDelegate<Int, ComponentTestAction>!

            beforeEach {
                mockComponent = MockComponentBase()
                delegate = ComponentDelegate(owner: mockComponent)
            }
            describe("observableState") {
                context("when componentState is never set") {
                    it("is empty") {
                        let recorded = recording(of: delegate.behavior.observableState) {
                            delegate = nil
                        }

                        expect(recorded.elements).to(beEmpty())
                        expect(recorded.didComplete).to(beTrue())
                    }
                }
                context("when componentState is set") {
                    it("emits single value of componentState") {
                        let recorded = recording(of: delegate.behavior.observableState) {
                            delegate.componentState = 42
                        }

                        expect(recorded.elements).to(equal([42]))
                    }
                }
            }

            describe("observeState(when: .beforeUpdate)") {

                beforeEach {
//                    mockComponent = MockComponentBase()
                }
                context("when componentState is never set") {
                    it("emits nothing") {
                        let recorded = recording(of: delegate.behavior.observeState(.beforeUpdate)) {
                            delegate = nil
                        }

                        expect(recorded.elements).to(beEmpty())
                        expect(recorded.didComplete).to(beTrue())
                        expect(recorded.didError).to(beFalse())
                    }
                }
                context("when componentState is set") {
                    it("emits a single value of componentState before update() is called") {
                        let recorded = recording(of: delegate.behavior.observeState(.beforeUpdate)) {
//                            delegate.ownerComponent = mockComponent
                            delegate.componentState = 42
                        }

                        expect(recorded.elements).to(equal([42]))
                    }
                }
            }

            describe("observeState(when: .afterUpdate)") {
//                var mockComponent: MockComponentBase<Int, ComponentTestAction>!

                beforeEach {
//                    mockComponent = MockComponentBase()
                }
                context("when componentState is never set") {
                    it("emits nothing") {
                        let recorded = recording(of: delegate.behavior.observeState(.afterUpdate)) {
                            delegate = nil
                        }

                        expect(recorded.elements).to(beEmpty())
                        expect(recorded.didComplete).to(beTrue())
                        expect(recorded.didError).to(beFalse())
                    }
                }
                context("when componentState is set") {
                    context("when canUpdate is true") {
                        it("emits a single value of componentState after update() is called") {
                            let recorded = recording(of: delegate.behavior.observeState(.afterUpdate)) {
//                                delegate.ownerComponent = mockComponent
                                delegate.componentState = 42
                                delegate.canUpdate = true
                            }

                            expect(recorded.elements).to(equal([42]))
                        }
                    }
                }
                context("when canUpdate is false regardless of needsUpdate value") {
                    it("emits nothing") {
                        let recorded = recording(of: delegate.behavior.observeState(.afterUpdate)) {
                            delegate.canUpdate = false
                            delegate.componentState = 42
                        }

                        expect(recorded.elements).to(beEmpty())
                    }
                }
                context("when needsUpdate is false regardless of canUpdate value") {
                    it("emits nothing") {
                        let recorded = recording(of: delegate.behavior.observeState(.afterUpdate)) {
                            let canUpdate = delegate.canUpdate
                            // we are locking update and then putting original value to `delegate.canUpdate`
                            delegate.canUpdate = false
                            delegate.componentState = 42
                            delegate.needsUpdate = false
                            delegate.canUpdate = canUpdate
                        }

                        expect(recorded.elements).to(beEmpty())
                    }
                }
            }

            describe("componentState") {
//                var mockComponent: MockComponentBase<Int, ComponentTestAction>!

                beforeEach {
//                    mockComponent = MockComponentBase()
                }
                context("after initialization") {
                    it("has no value") {
                        expect(delegate.hasComponentState).to(beFalse())
                        delegate.componentState = 0
                        expect(delegate.hasComponentState).to(beTrue())
                        expect(delegate.componentState).toNot(raiseException())
                    }
                    it("crashes when trying to read its value") {
                        expect(delegate.componentState).to(raiseException())
                    }
                }
                context("when accessed") {
                    it("contains the same value as last set") {
                        delegate.componentState = 12
                        expect(delegate.componentState).to(equal(12))
                        delegate.componentState = 14
                        expect(delegate.componentState).to(equal(14))
                    }
                    it("keeps last value regardless on how many values were set in the past") {
                        for i in -1337...1337 {
                            delegate.componentState = i
                            expect(delegate.componentState).to(equal(i))
                        }
                    }
                }
                context("when storing non-Void value") {
                    it("calls update") {
//                        delegate.ownerComponent = mockComponent
                        delegate.canUpdate = true

                        delegate.componentState = 1
                        delegate.componentState = 2
                        delegate.componentState = 1
                        delegate.componentState = 3

                        verify(mockComponent, times(4)).update()
                    }
                    it("does not call update on if canUpdate is false") {
                        delegate.canUpdate = false

                        delegate.componentState = 1
                        delegate.componentState = 2
                        delegate.componentState = 3
                        delegate.componentState = 4
                        verify(mockComponent, never()).update()
                    }
                }
                context("when assigning same value") {
                    it("calls update") {
//                        delegate.ownerComponent = mockComponent
                        delegate.canUpdate = true

                        delegate.componentState = 0
                        delegate.componentState = 0
                        delegate.componentState = 0
                        delegate.componentState = 0

                        verify(mockComponent, times(4)).update()
                    }
                }
            }

            describe("previousComponentState") {
                context("before first update") {
                    it("is nil") {
                        expect(delegate.previousComponentState).to(beNil())
                    }
                }
                context("after first update") {
                    it("is nil") {
                        delegate.componentState = 1
                        expect(delegate.previousComponentState).to(beNil())
                    }
                }
                context("after one or more updates") {
                    it("contains old componentState values") {
                        delegate.componentState = 1
                        delegate.componentState = 0
                        expect(delegate.previousComponentState).to(equal(1))
                        delegate.componentState = 100000
                        expect(delegate.previousComponentState).to(equal(0))
                    }
                }
            }

            describe("action") {
                it("subscribing to action catches perform(action:) calls") {
                    let recorded = recording(of: delegate.behavior.action) {
                        delegate.perform(action: .one)
                    }

                    expect(recorded.elements).to(equal([.one]))
                }
                it("subscribing to action catches actions events") {
                    let subject = PublishSubject<ComponentTestAction>()
                    delegate.actions = [subject]

                    let recorded = recording(of: delegate.behavior.action) {
                        subject.onNext(.one)
                    }

                    expect(recorded.elements).to(equal([.one]))
                }
            }

            describe("ownerComponent") {
//                var mockComponent: MockComponentBase<Int, ComponentTestAction>!

                beforeEach {
//                    mockComponent = MockComponentBase()
                }
                context("when componentState is set") {
                    context("and setting canUpdate to true") {
                        it("calls update") {
                            delegate.componentState = 1
//                            delegate.ownerComponent = mockComponent
                            delegate.canUpdate = true

                            verify(mockComponent).update()
                        }
                    }
                    context("and deallocating ownerComponent") {
                        it("throws NSException") {
                            mockComponent = nil

                            delegate.componentState = 0

                            expect(delegate.canUpdate = true).to(raiseException())
//                            verify(mockComponent, never()).update()
                        }
                    }
                }
            }
        }

        // MARK:- Value Type Testing
        describe("ComponentDelegate<Struct>") {
            var mockComponent: MockComponentBase<ComponentTestState, ComponentTestAction>!
            var delegate: ComponentDelegate<ComponentTestState, ComponentTestAction>!

            beforeEach {
                mockComponent = MockComponentBase()
                delegate = ComponentDelegate(owner: mockComponent)
            }

            describe("update") {
                beforeEach {
//                    mockComponent = MockComponentBase()
                }
                context("when setting first componentState value") {
                    it("gets called") {
//                        delegate.ownerComponent = mockComponent
                        delegate.canUpdate = true
                        let state = ComponentTestState(primitive: 0, tuple: ("hello", 1), classy: ComponentTestClass())
                        delegate.componentState = state

                        verify(mockComponent).update()
                    }
                }
                context("when changing value types") {
                    it("gets called") {
//                        delegate.ownerComponent = mockComponent
                        delegate.canUpdate = true
                        let state = ComponentTestState(primitive: 0, tuple: ("hello", 1), classy: ComponentTestClass())
                        delegate.componentState = state
                        reset(mockComponent) // resetting the update after `state` is set

                        delegate.componentState.tuple.0 = "Harry"
                        delegate.componentState.tuple.1 = 111

                        verify(mockComponent, times(2)).update()
                    }
                }
                context("when changing a field in reference type") {
                    it("does not get called") {
//                        delegate.ownerComponent = mockComponent
                        delegate.canUpdate = true

                        let state = ComponentTestState(primitive: 0, tuple: ("hello", 1), classy: ComponentTestClass())
                        delegate.componentState = state
                        reset(mockComponent) // resetting the update after `state` is set

                        delegate.componentState.classy?.tuple = ("put", 0)
                        delegate.componentState.classy?.tuple.0 = "lalala"
                        delegate.componentState.classy?.tuple.1 = 2

                        verify(mockComponent, never()).update()
                    }
                }
                context("when switching one value type for another") {
                    it("gets called") {
//                        delegate.ownerComponent = mockComponent
                        delegate.canUpdate = true

                        let state = ComponentTestState(primitive: 0, tuple: ("hello", 1), classy: ComponentTestClass())
                        delegate.componentState = state
                        reset(mockComponent) // resetting the update after `state` is set

                        delegate.componentState = ComponentTestState(primitive: 120, tuple: ("hell", 12323), classy: nil)
                        delegate.componentState = ComponentTestState(primitive: -666, tuple: ("lehh", 0), classy: ComponentTestClass())

                        verify(mockComponent, times(2)).update()
                    }
                }
                context("when assigning the same value as before") {
                    it("gets called every time") {
//                        delegate.ownerComponent = mockComponent
                        delegate.canUpdate = true

                        delegate.componentState = ComponentTestState(primitive: -666, tuple: ("lehh", 0), classy: ComponentTestClass())
                        delegate.componentState = ComponentTestState(primitive: -666, tuple: ("lehh", 0), classy: ComponentTestClass())
                        delegate.componentState = ComponentTestState(primitive: -666, tuple: ("lehh", 0), classy: ComponentTestClass())

                        verify(mockComponent, times(3)).update()
                    }
                }
            }

            describe("componentState") {
//                var mockComponent: MockComponentBase<ComponentTestState, ComponentTestAction>!

                beforeEach {
//                    mockComponent = MockComponentBase()
                }
                context("after initialization") {
                    it("has no value") {
                        expect(delegate.hasComponentState).to(beFalse())
                        delegate.componentState = ComponentTestState(primitive: 0, tuple: ("hello", 1), classy: ComponentTestClass())
                        expect(delegate.hasComponentState).to(beTrue())
                        expect(delegate.componentState).toNot(raiseException())
                    }
                    it("crashes when trying to read its value") {
                        expect(delegate.componentState).to(raiseException())
                    }
                }
                context("when accessed") {
                    it("contains the same value as last set") {
                        delegate.componentState = ComponentTestState(primitive: 0, tuple: ("hello", 1), classy: nil)
                        expect(delegate.componentState.primitive).to(equal(0))
                        delegate.componentState = ComponentTestState(primitive: 2, tuple: ("hello", 1), classy: nil)
                        expect(delegate.componentState.primitive).to(equal(2))
                    }
                    it("keeps last value regardless on how many times modified in the past") {
                        delegate.componentState = ComponentTestState(primitive: 0, tuple: ("hello", 1), classy: ComponentTestClass())
                        for i in -1337...1337 {
                            delegate.componentState.tuple.1 = i
                            expect(delegate.componentState.tuple.1).to(equal(i))
                        }
                    }
                }
                context("when storing non-Void value") {
                    context("canUpdate is true") {
                        it("calls update") {
//                            delegate.ownerComponent = mockComponent
                            delegate.canUpdate = true

                            delegate.componentState = ComponentTestState(primitive: 0, tuple: ("hello", 1), classy: ComponentTestClass())
                            delegate.componentState = ComponentTestState(primitive: 2, tuple: ("hello", 1), classy: ComponentTestClass())
                            delegate.componentState = ComponentTestState(primitive: 3, tuple: ("hello", 1), classy: ComponentTestClass())
                            delegate.componentState = ComponentTestState(primitive: 4, tuple: ("hello", 1), classy: ComponentTestClass())

                            verify(mockComponent, times(4)).update()
                        }
                    }
                    context("canUpdate is false") {
                        it("does not call update") {
                            delegate.canUpdate = false

                            delegate.componentState = ComponentTestState(primitive: 0, tuple: ("hello", 1), classy: ComponentTestClass())
                            delegate.componentState = ComponentTestState(primitive: 2, tuple: ("hello", 1), classy: ComponentTestClass())
                            delegate.componentState = ComponentTestState(primitive: 3, tuple: ("hello", 1), classy: ComponentTestClass())
                            delegate.componentState = ComponentTestState(primitive: 4, tuple: ("hello", 1), classy: ComponentTestClass())
                            verify(mockComponent, never()).update()
                        }
                    }
                }
            }

            describe("previousComponentState") {
                context("before first update") {
                    it("is nil") {
                        expect(delegate.previousComponentState).to(beNil())
                    }
                }
                context("after first update") {
                    it("is nil") {
                        delegate.componentState = ComponentTestState(primitive: 0, tuple: ("hello", 1), classy: ComponentTestClass())
                        expect(delegate.previousComponentState).to(beNil())
                    }
                }
                context("after one or more updates") {
                    it("contains old componentState values") {
                        delegate.componentState = ComponentTestState(primitive: 0, tuple: ("hello", 1), classy: ComponentTestClass())
                        delegate.componentState = ComponentTestState(primitive: 1, tuple: ("hello", 1), classy: ComponentTestClass())
                        expect(delegate.previousComponentState?.primitive).to(equal(0))
                        delegate.componentState = ComponentTestState(primitive: 2, tuple: ("hello", 1), classy: ComponentTestClass())
                        expect(delegate.previousComponentState?.primitive).to(equal(1))
                    }
                }
            }

            describe("ownerComponent") {
//                var mockComponent: MockComponentBase<ComponentTestState, ComponentTestAction>!

                beforeEach {
//                    mockComponent = MockComponentBase()
                }
                context("when componentState is set") {
                    context("and setting canUpdate to true") {
                        it("calls update") {
                            delegate.componentState = ComponentTestState(primitive: 0, tuple: ("hello", 1), classy: ComponentTestClass())
                            //                            delegate.ownerComponent = mockComponent
                            delegate.canUpdate = true

                            verify(mockComponent).update()
                        }
                    }
                    context("and deallocating ownerComponent") {
                        it("throws NSException") {
                            mockComponent = nil

                            delegate.componentState = ComponentTestState(primitive: 0, tuple: ("hello", 1), classy: ComponentTestClass())

                            expect(delegate.canUpdate = true).to(raiseException())
                        }
                    }
                }
            }
        }

        // MARK:- Reference Type Testing
        describe("ComponentDelegate<Class>") {
            var mockComponent: MockComponentBase<ComponentTestClass, ComponentTestAction>!
            var delegate: ComponentDelegate<ComponentTestClass, ComponentTestAction>!

            beforeEach {
                mockComponent = MockComponentBase()
                delegate = ComponentDelegate(owner: mockComponent)
            }

            describe("update") {
                beforeEach {

                }
                context("when setting componentState") {
                    it("gets called") {
//                        delegate.ownerComponent = mockComponent
                        delegate.canUpdate = true
                        delegate.componentState = ComponentTestClass(primitive: 0)

                        verify(mockComponent).update()
                    }
                }
                context("when changing value types") {
                    it("does not get called") {
//                        delegate.ownerComponent = mockComponent
                        delegate.canUpdate = true

                        delegate.componentState = ComponentTestClass(primitive: 0)
                        reset(mockComponent) // resetting the update after `state` is set

                        delegate.componentState.tuple.0 = "Harry"
                        delegate.componentState.tuple.1 = 111

                        verify(mockComponent, never()).update()
                    }
                }
                context("when changing a field in value type") {
                    it("does not get called") {
//                        delegate.ownerComponent = mockComponent
                        delegate.canUpdate = true

                        delegate.componentState = ComponentTestClass(primitive: 0, structy: true)
                        reset(mockComponent) // resetting the update after `state` is set

                        delegate.componentState.structy.tuple.0 = "lalala"
                        delegate.componentState.structy.tuple.1 = 2

                        verify(mockComponent, never()).update()
                    }
                }
                context("when switching one value type for another") {
                    it("gets called") {
//                        delegate.ownerComponent = mockComponent
                        delegate.canUpdate = true

                        delegate.componentState = ComponentTestClass(primitive: -1)
                        delegate.componentState = ComponentTestClass(primitive: 0)
                        delegate.componentState = ComponentTestClass(primitive: 1, structy: true)

                        verify(mockComponent, times(3)).update()
                    }
                }
                context("when assigning the same value as before") {
                    it("gets called every time") {
//                        delegate.ownerComponent = mockComponent
                        delegate.canUpdate = true

                        delegate.componentState = ComponentTestClass(primitive: 0)
                        delegate.componentState = ComponentTestClass(primitive: 0)
                        delegate.componentState = ComponentTestClass(primitive: 0)

                        verify(mockComponent, times(3)).update()
                    }
                }
            }

            describe("componentState") {
//                var mockComponent: MockComponentBase<ComponentTestClass, ComponentTestAction>!

                beforeEach {
//                    mockComponent = MockComponentBase()
                }
                context("after initialization") {
                    it("has no value") {
                        expect(delegate.hasComponentState).to(beFalse())
                        delegate.componentState = ComponentTestClass(primitive: 0)
                        expect(delegate.hasComponentState).to(beTrue())
                        expect(delegate.componentState).toNot(raiseException())
                    }
                    it("crashes when trying to read its value") {
                        expect(delegate.componentState).to(raiseException())
                    }
                }
                context("when accessed") {
                    it("contains the same value as last set") {
                        delegate.componentState = ComponentTestClass(primitive: 0)
                        expect(delegate.componentState.primitive).to(equal(0))
                        delegate.componentState = ComponentTestClass(primitive: 2)
                        expect(delegate.componentState.primitive).to(equal(2))
                    }
                    it("keeps last value regardless on how many times modified in the past") {
                        delegate.componentState = ComponentTestClass(primitive: 0)
                        for i in -1337...1337 {
                            delegate.componentState.tuple.1 = i
                            expect(delegate.componentState.tuple.1).to(equal(i))
                        }
                    }
                }
                context("when storing non-Void value") {
                    context("canUpdate is true") {
                        it("calls update") {
//                            delegate.ownerComponent = mockComponent
                            delegate.canUpdate = true

                            delegate.componentState = ComponentTestClass(primitive: 0)
                            delegate.componentState = ComponentTestClass(primitive: 1, structy: true)
                            delegate.componentState = ComponentTestClass(primitive: 2, structy: true)
                            delegate.componentState = ComponentTestClass(primitive: 3)

                            verify(mockComponent, times(4)).update()
                        }
                    }
                    context("canUpdate is false") {
                        it("does not call update") {
                            delegate.canUpdate = false

                            delegate.componentState = ComponentTestClass(primitive: 0)
                            delegate.componentState = ComponentTestClass(primitive: 1, structy: true)
                            delegate.componentState = ComponentTestClass(primitive: 2, structy: true)
                            delegate.componentState = ComponentTestClass(primitive: 3)
                            verify(mockComponent, never()).update()
                        }
                    }
                }
            }

            describe("previousComponentState") {
                context("before first update") {
                    it("is nil") {
                        expect(delegate.previousComponentState).to(beNil())
                    }
                }
                context("after first update") {
                    it("is nil") {
                        delegate.componentState = ComponentTestClass(primitive: 0)
                        expect(delegate.previousComponentState).to(beNil())
                    }
                }
                context("after one or more updates") {
                    it("contains old componentState values") {
                        delegate.componentState = ComponentTestClass(primitive: 0)
                        delegate.componentState = ComponentTestClass(primitive: 1, structy: true)
                        expect(delegate.previousComponentState?.primitive).to(equal(0))
                        delegate.componentState = ComponentTestClass(primitive: 3, structy: true)
                        expect(delegate.previousComponentState?.primitive).to(equal(1))
                    }
                }
            }

            describe("ownerComponent") {
//                var mockComponent: MockComponentBase<ComponentTestClass, ComponentTestAction>!

                beforeEach {
//                    mockComponent = MockComponentBase()
                }
                context("when componentState is set") {
                    context("and setting canUpdate to true") {
                        it("calls update") {
                            delegate.componentState = ComponentTestClass(primitive: 0)
                            //                            delegate.ownerComponent = mockComponent
                            delegate.canUpdate = true

                            verify(mockComponent).update()
                        }
                    }
                    context("and deallocating ownerComponent") {
                        it("throws NSException") {
                            mockComponent = nil

                            delegate.componentState = ComponentTestClass(primitive: 0)

                            expect(delegate.canUpdate = true).to(raiseException())
//                            verify(mockComponent, never()).update()
                        }
                    }
                }
            }
        }
    }
}
