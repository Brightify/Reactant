//
//  MockComponentBase.swift
//  ReactantTests
//
//  Created by Matyáš Kříž on 16/11/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

@testable import Reactant
import RxSwift
import Cuckoo

class MockComponentBase<STATE, ACTION>: ComponentBase<STATE, ACTION>, Cuckoo.ClassMock {
    typealias MocksType = ComponentBase<STATE, ACTION>
    typealias Stubbing = __StubbingProxy_MockComponentBase
    typealias Verification = __VerificationProxy_MockComponentBase
    let cuckoo_manager = Cuckoo.MockManager(hasParent: true)

    override init(initialState: STATE, canUpdate: Bool = true) {
        cuckoo_manager.enableSuperclassSpy()

        super.init(initialState: initialState, canUpdate: canUpdate)
    }

    var action: Observable<ACTION> {
        get {
            return cuckoo_manager.getter("action", superclassCall: MockManager.crashOnProtocolSuperclassCall())
        }
    }

//    override var actions: [Observable<ACTION>] {
//        get {
//            return cuckoo_manager.getter("actions", superclassCall: super.actions)
//        }
//    }

    override func needsUpdate(previousState: STATE?) -> Bool {
        return cuckoo_manager.call("needsUpdate() -> Bool",
                                   parameters: (),
                                   superclassCall: super.needsUpdate(previousState: previousState)
        )
    }

    override func afterInit() {
        return cuckoo_manager.call("afterInit()",
                                   parameters: (),
                                   superclassCall: super.afterInit()
        )
    }

    override func update(previousState: STATE?) {
        return cuckoo_manager.call("update()",
                                   parameters: (),
                                   superclassCall: super.update(previousState: previousState)
        )
    }

    func observeState(_ when: ObservableStateEvent) -> Observable<STATE> {
        return cuckoo_manager.call("observeState(_ when: ObservableStateEvent) -> Observable<STATE>",
                                   parameters: (when),
                                   superclassCall: MockManager.crashOnProtocolSuperclassCall()
        )
    }

    struct __StubbingProxy_MockComponentBase: Cuckoo.StubbingProxy {
        private let cuckoo_manager: Cuckoo.MockManager

        init(manager: Cuckoo.MockManager) {
            self.cuckoo_manager = manager
        }

        var action: Cuckoo.ClassToBeStubbedReadOnlyProperty<MockComponentBase, Observable<ACTION>> {
            return .init(manager: cuckoo_manager, name: "action")
        }

        var actions: Cuckoo.ClassToBeStubbedReadOnlyProperty<MockComponentBase, [Observable<ACTION>]> {
            return .init(manager: cuckoo_manager, name: "actions")
        }

        func needsUpdate() -> Cuckoo.ClassStubFunction<(), Bool> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return .init(stub: cuckoo_manager.createStub(for: MockComponentBase.self, method: "needsUpdate()", parameterMatchers: matchers))
        }

        func afterInit() -> Cuckoo.ClassStubNoReturnFunction<()> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return .init(stub: cuckoo_manager.createStub(for: MockComponentBase.self, method: "afterInit()", parameterMatchers: matchers))
        }

        func update() -> Cuckoo.ClassStubNoReturnFunction<()> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return .init(stub: cuckoo_manager.createStub(for: MockComponentBase.self, method: "update()", parameterMatchers: matchers))
        }

        func observeState<M1: Cuckoo.Matchable>(_ when: M1) -> Cuckoo.ClassStubFunction<ObservableStateEvent, Observable<STATE>> where M1.MatchedType == ObservableStateEvent {
            let matchers: [Cuckoo.ParameterMatcher<ObservableStateEvent>] = [wrap(matchable: when) { $0 }]
            return .init(stub: cuckoo_manager.createStub(for: MockComponentBase.self, method: "observeState(_ when: ObservableStateEvent) -> Observable<STATE>", parameterMatchers: matchers))
        }
    }

    struct __VerificationProxy_MockComponentBase: Cuckoo.VerificationProxy {
        private let cuckoo_manager: Cuckoo.MockManager
        private let callMatcher: Cuckoo.CallMatcher
        private let sourceLocation: Cuckoo.SourceLocation

        init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
            self.cuckoo_manager = manager
            self.callMatcher = callMatcher
            self.sourceLocation = sourceLocation
        }

        var action: Cuckoo.VerifyReadOnlyProperty<Observable<ACTION>> {
            return .init(manager: cuckoo_manager, name: "action", callMatcher: callMatcher, sourceLocation: sourceLocation)
        }

        var actions: Cuckoo.VerifyReadOnlyProperty<[Observable<ACTION>]> {
            return .init(manager: cuckoo_manager, name: "actions", callMatcher: callMatcher, sourceLocation: sourceLocation)
        }

        @discardableResult
        func needsUpdate() -> Cuckoo.__DoNotUse<Bool> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return cuckoo_manager.verify("needsUpdate() -> Bool", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
        }

        @discardableResult
        func afterInit() -> Cuckoo.__DoNotUse<()> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return cuckoo_manager.verify("afterInit()", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
        }

        @discardableResult
        func update() -> Cuckoo.__DoNotUse<()> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return cuckoo_manager.verify("update()", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
        }
    }
}
