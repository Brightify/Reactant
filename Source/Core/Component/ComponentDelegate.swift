//
//  ComponentDelegate.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

// COMPONENT and ACTION cannot have restriction to StateType because then it is impossible to use ComponentWithDelegate (associatedtype cannot be used with where).
public final class ComponentDelegate<STATE, ACTION, COMPONENT: Component> {

    /**
    Dispose bag for Observables, it disposes before every **update** call and should be used when subscribing in **update**.
    - Note: For subscribing outside of update use **lifetimeDisposeBag**.
    */
    public var stateDisposeBag = DisposeBag()

    /// `Observable` equivalent of the **componentState**.
    /// - Note: For more info, see [RxSwift](https://github.com/ReactiveX/RxSwift).
    public var observableState: Observable<STATE> {
        return observableStateSubject
    }
    
    // TODO Check for memory corruption on 32 bit system.
    /**
     Every time **componentState** changes, its old value is saved into **previousComponentState**.
     - Note: Its value is `nil` in first **update** call and can be used for running code only once.
    */
    public var previousComponentState: STATE? = nil

    /**
     Every time its value changes, **update** function is called.

     You can regulate under which conditions **update** is called by overriding **needsUpdate** or **canUpdate**, both need to be **true** in order for `update` to be called on next `componentState` change.
     - Warning: A **class** is not suitable as a `componentState` because there's no way to see if it changed. More info: [Components and everything about them](https://docs.reactant.tech/getting-started/quickstart.html#writing-components).
    */
    public var componentState: STATE {
        get {
            if let state = stateStorage {
                return state
            } else {
                fatalError("ComponentState accessed before stored!")
            }
        }
        set {
            previousComponentState = stateStorage
            stateStorage = newValue

            observableStateBeforeUpdate.onNext(newValue)
            needsUpdate = true
            observableStateSubject.onNext(newValue)
        }
    }
    
    public var action: Observable<ACTION> {
        return actionSubject
    }

    /// Variable which is used internally by Reactant to call **update**
    /// - Note: See **canUpdate**.
    /// - Warning: This variable shouldn't be changed by hand, it's used for syncing Reactant and calling **update**.
    public var needsUpdate: Bool = false {
        didSet {
            if needsUpdate && canUpdate {
                let componentStateBeforeUpdate = componentState
                update()
                observableStateAfterUpdate.onNext(componentStateBeforeUpdate)
            }
        }
    }

    /// Variable which controls whether the **update** function is called when **componentState** is changed.
    public var canUpdate: Bool = false {
        didSet {
            if canUpdate && needsUpdate {
                let componentStateBeforeUpdate = componentState
                update()
                observableStateAfterUpdate.onNext(componentStateBeforeUpdate)
            }
        }
    }
    
    public weak var ownerComponent: COMPONENT? {
        didSet {
            needsUpdate = stateStorage != nil
        }
    }

    /** 
    Array of observables through which the Component communicates with outside world.
    - Attention: Each of the `Observable`s need to be *rewritten* or *mapped* to be of the correct type - the ACTION.
    - **rewrite** is used on the Observable if it's `Void` and **map** if it carries a value
    - a good idea is to create an `enum`, cases without value should be used with function **rewrite** and cases with should be used with function **map**
    # Example
     button.rx.tap.rewrite(with: MyRootViewAction.loginTapped)

     textField.rx.text.skip(1).map(MyRootViewAction.emailChanged)
     
    For more info, see [Component Action](https://docs.reactant.tech/getting-started/quickstart.html#component-action)
    */
    public var actions: [Observable<ACTION>] = [] {
        didSet {
            actionsDisposeBag = DisposeBag()
            Observable.from(actions).merge().subscribe(onNext: perform).disposed(by: actionsDisposeBag)
        }
    }

    /**
    Get-only variable through which you can safely check whether `componentState` is set.
    
    Good for guarding `componentState` read when not in `update`
    */
    public var hasComponentState: Bool {
        return stateStorage != nil
    }
    
    private let observableStateSubject = ReplaySubject<STATE>.create(bufferSize: 1)
    private let observableStateBeforeUpdate = PublishSubject<STATE>()
    private let observableStateAfterUpdate = PublishSubject<STATE>()
    private let actionSubject = PublishSubject<ACTION>()
    
    private var stateStorage: STATE? = nil
    
    private var actionsDisposeBag = DisposeBag()
    
    public init() {
        // If the model is Void, we set it so caller does not have to.
        if let voidState = Void() as? STATE {
            componentState = voidState
        }
    }

    deinit {
        observableStateSubject.onCompleted()
        actionSubject.onCompleted()
        observableStateBeforeUpdate.onCompleted()
        observableStateAfterUpdate.onCompleted()
    }

    /**
    Function that manually sends an `action` of type ACTION, although the preferred way is to use `Observable`s in the `actions` array.
    - parameter action: ACTION model you wish to send
    - Note: An `action` sent with this function gets merged with the `action` `Observable`. For more info, see [Component Action](https://docs.reactant.tech/getting-started/quickstart.html#component-action).
    */
    public func perform(action: ACTION) {
        actionSubject.onNext(action)
    }

    
    public func observeState(_ when: ObservableStateEvent) -> Observable<STATE> {
        switch when {
        case .beforeUpdate:
            return observableStateBeforeUpdate
        case .afterUpdate:
            return observableStateAfterUpdate
        }
    }
    
    private func update() {
        guard stateStorage != nil else {
            #if DEBUG
                fatalError("ComponentState not set before needsUpdate and canUpdate were set! ComponentState \(STATE.self), component \(type(of: ownerComponent))")
            #else
                print("WARNING: ComponentState not set before needsUpdate and canUpdate were set. This is usually developer error by not calling `setComponentState` on Component that needs non-Void componentState. ComponentState \(STATE.self), component \(type(of: ownerComponent))")
                return
            #endif
        }
        
        needsUpdate = false
        
        #if DEBUG
            precondition(ownerComponent != nil, "Update called when ownerComponent is nil. Probably wasn't set in init of the component.")
        #endif
        if ownerComponent?.needsUpdate() == true {
            stateDisposeBag = DisposeBag()
            ownerComponent?.update()
        }
    }
}
