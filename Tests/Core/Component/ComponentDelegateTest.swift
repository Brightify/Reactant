//
//  ComponentDelegateTest.swift
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

class ComponentDelegateTest: QuickSpec {
    override func spec() {
        let mockComponent = MockComponentBase<Int, ComponentTestAction>()
        var delegate: ComponentDelegate<Int, ComponentTestAction, MockComponentBase<Int, ComponentTestAction>>!
        var delegateVoidState: ComponentDelegate<Void, ComponentTestAction, MockComponentBase<Void, ComponentTestAction>>!
        var testDisposeBag: DisposeBag!
        beforeEach {
            delegate = ComponentDelegate<Int, ComponentTestAction, MockComponentBase<Int, ComponentTestAction>>()
            delegateVoidState = ComponentDelegate<Void, ComponentTestAction, MockComponentBase<Void, ComponentTestAction>>()
            testDisposeBag = DisposeBag()
        }
        describe("observableState tests") {
            it("contains componentState when set") {
                var received = false

                delegate.observableState.subscribe(onNext: { state in
                    received = state == 42
                })
                .disposed(by: testDisposeBag)

                delegate.componentState = 42
                expect(received).to(beTrue())
            }
            it("can observe componentState before or after update") {
                var received = ComponentTestAction.none

                delegate.observeState(.beforeUpdate).subscribe(onNext: { state in
                    guard state == 42 else { return }
                    received = .one
                })
                .disposed(by: testDisposeBag)

                delegate.observeState(.afterUpdate).subscribe(onNext: { state in
                    guard state == 42 else { return }
                    received = .two
                })
                .disposed(by: testDisposeBag)

                delegate.ownerComponent = mockComponent
                delegate.componentState = 42
                expect(received).to(equal(ComponentTestAction.one))
                delegate.canUpdate = true
                expect(received).to(equal(ComponentTestAction.two))
            }
        }
        describe("componentState existence") {
            it("delegate with Void componentState type always has componentState") {
                expect(delegateVoidState.hasComponentState).to(beTrue())
            }
            it("has no componentState to begin with") {
                expect(delegate.hasComponentState).to(beFalse())
                delegate.componentState = 0
                expect(delegate.hasComponentState).to(beTrue())
            }
            it("crashes when there's no componentState") {
                expect(delegate.componentState).to(raiseException())
            }
        }
    }
}
