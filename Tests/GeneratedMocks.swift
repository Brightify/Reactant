import Cuckoo
@testable import Reactant

import RxSwift


public class MockComponentBase<STATE, ACTION>: ComponentBase<STATE, ACTION>, Cuckoo.ClassMock {
    
    public typealias MocksType = ComponentBase<STATE, ACTION>
    
    public typealias Stubbing = __StubbingProxy_ComponentBase
    public typealias Verification = __VerificationProxy_ComponentBase

    public let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: true)

    
    private var __defaultImplStub: ComponentBase<STATE, ACTION>?

    public func enableDefaultImplementation(_ stub: ComponentBase<STATE, ACTION>) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    
    
    
    public override var action: Observable<ACTION> {
        get {
            return cuckoo_manager.getter("action",
                superclassCall:
                    
                    super.action
                    ,
                defaultCall: __defaultImplStub!.action)
        }
        
    }
    
    
    
    public override var actions: [Observable<ACTION>] {
        get {
            return cuckoo_manager.getter("actions",
                superclassCall:
                    
                    super.actions
                    ,
                defaultCall: __defaultImplStub!.actions)
        }
        
    }
    

    

    
    
    
    public override func needsUpdate() -> Bool {
        
    return cuckoo_manager.call("needsUpdate() -> Bool",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                super.needsUpdate()
                ,
            defaultCall: __defaultImplStub!.needsUpdate())
        
    }
    
    
    
    public override func afterInit()  {
        
    return cuckoo_manager.call("afterInit()",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                super.afterInit()
                ,
            defaultCall: __defaultImplStub!.afterInit())
        
    }
    
    
    
    public override func update()  {
        
    return cuckoo_manager.call("update()",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                super.update()
                ,
            defaultCall: __defaultImplStub!.update())
        
    }
    
    
    
    public override func observeState(_ when: ObservableStateEvent) -> Observable<STATE> {
        
    return cuckoo_manager.call("observeState(_: ObservableStateEvent) -> Observable<STATE>",
            parameters: (when),
            escapingParameters: (when),
            superclassCall:
                
                super.observeState(when)
                ,
            defaultCall: __defaultImplStub!.observeState(when))
        
    }
    

	public struct __StubbingProxy_ComponentBase: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	    public init(manager: Cuckoo.MockManager) {
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
	        return .init(stub: cuckoo_manager.createStub(for: MockComponentBase.self, method: "needsUpdate() -> Bool", parameterMatchers: matchers))
	    }
	    
	    func afterInit() -> Cuckoo.ClassStubNoReturnFunction<()> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockComponentBase.self, method: "afterInit()", parameterMatchers: matchers))
	    }
	    
	    func update() -> Cuckoo.ClassStubNoReturnFunction<()> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockComponentBase.self, method: "update()", parameterMatchers: matchers))
	    }
	    
	    func observeState<M1: Cuckoo.Matchable>(_ when: M1) -> Cuckoo.ClassStubFunction<(ObservableStateEvent), Observable<STATE>> where M1.MatchedType == ObservableStateEvent {
	        let matchers: [Cuckoo.ParameterMatcher<(ObservableStateEvent)>] = [wrap(matchable: when) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockComponentBase.self, method: "observeState(_: ObservableStateEvent) -> Observable<STATE>", parameterMatchers: matchers))
	    }
	    
	}

	public struct __VerificationProxy_ComponentBase: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	    public init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
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
	    func needsUpdate() -> Cuckoo.__DoNotUse<(), Bool> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("needsUpdate() -> Bool", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func afterInit() -> Cuckoo.__DoNotUse<(), Void> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("afterInit()", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func update() -> Cuckoo.__DoNotUse<(), Void> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("update()", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func observeState<M1: Cuckoo.Matchable>(_ when: M1) -> Cuckoo.__DoNotUse<(ObservableStateEvent), Observable<STATE>> where M1.MatchedType == ObservableStateEvent {
	        let matchers: [Cuckoo.ParameterMatcher<(ObservableStateEvent)>] = [wrap(matchable: when) { $0 }]
	        return cuckoo_manager.verify("observeState(_: ObservableStateEvent) -> Observable<STATE>", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

public class ComponentBaseStub<STATE, ACTION>: ComponentBase<STATE, ACTION> {
    
    
    public override var action: Observable<ACTION> {
        get {
            return DefaultValueRegistry.defaultValue(for: (Observable<ACTION>).self)
        }
        
    }
    
    
    public override var actions: [Observable<ACTION>] {
        get {
            return DefaultValueRegistry.defaultValue(for: ([Observable<ACTION>]).self)
        }
        
    }
    

    

    
    public override func needsUpdate() -> Bool  {
        return DefaultValueRegistry.defaultValue(for: (Bool).self)
    }
    
    public override func afterInit()   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    public override func update()   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    public override func observeState(_ when: ObservableStateEvent) -> Observable<STATE>  {
        return DefaultValueRegistry.defaultValue(for: (Observable<STATE>).self)
    }
    
}

