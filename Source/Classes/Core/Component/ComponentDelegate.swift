//
//  ComponentDelegate.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

// COMPONENT and ACTION cannot have restriction to StateType because it is impossible then to use ComponentWithDelegate (associatedtype cannot be used with where).
public final class ComponentDelegate<STATE, ACTION, COMPONENT: Component> {
    
    public var stateDisposeBag = DisposeBag()
    
    public var observableState: Observable<STATE> {
        return observableStateSubject
    }
    
    // TODO Check for memory corruption on 32 bit system.
    public var previousComponentState: STATE? = nil
    
    public var componentState: STATE {
        get {
            if let state = stateStorage {
                return state
            } else {
                preconditionFailure("ComponentState accessed before stored!")
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
    
    public var needsUpdate: Bool = false {
        didSet {
            if needsUpdate && canUpdate {
                let componentStateBeforeUpdate = componentState
                update()
                observableStateAfterUpdate.onNext(componentStateBeforeUpdate)
            }
        }
    }
    
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
    
    public var actions: [Observable<ACTION>] = [] {
        didSet {
            actionsDisposeBag = DisposeBag()
            Observable.from(actions).merge().subscribe(onNext: perform).addDisposableTo(actionsDisposeBag)
        }
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
                preconditionFailure("ComponentState not set before needsUpdate and canUpdate were set! ComponentState \(STATE.self), component \(type(of: ownerComponent))")
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
