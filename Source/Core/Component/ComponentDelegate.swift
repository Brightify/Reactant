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
                fatalError("ComponentState accessed before stored!")
            }
        }
        set {
            previousComponentState = stateStorage
            stateStorage = newValue
            needsUpdate = true
            observableStateSubject.onNext(componentState)
        }
    }
    
    public var action: Observable<ACTION> {
        return actionSubject
    }
    
    public var needsUpdate: Bool = false {
        didSet {
            if needsUpdate && canUpdate {
                update()
            }
        }
    }
    
    public var canUpdate: Bool = false {
        didSet {
            if canUpdate && needsUpdate {
                update()
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
    private let actionSubject = ReplaySubject<ACTION>.create(bufferSize: 1)
    
    private var stateStorage: STATE? = nil
    
    private var actionsDisposeBag = DisposeBag()
    
    public init() {
        // If the model is Void, we set it so caller does not have to.
        if let voidState = Void() as? STATE {
            componentState = voidState
        }
    }
    
    public func perform(action: ACTION) {
        actionSubject.onNext(action)
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