//
//  ComponentDelegate.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

// COMPONENT cannot have restriction to StateType becaouse it is impossible then to use ComponentWithDelegate (associatedtype cannot be used with where).
public class ComponentDelegate<STATE, COMPONENT: Component> {
    
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
            needsUpdate = true
            // TODO Move to update?
            observableStateSubject.onNext(componentState)
        }
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
            needsUpdate = true
        }
    }
    
    private let observableStateSubject = ReplaySubject<STATE>.create(bufferSize: 1)
    
    private var stateStorage: STATE? = nil
    
    public init() {
        // If the model is Void, we set it so caller does not have to.
        if let voidState = Void() as? STATE {
            componentState = voidState
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
        stateDisposeBag = DisposeBag()
        #if DEBUG
            precondition(ownerComponent != nil, "Update called when ownerComponent is nil. Probably wasn't set in init of the component.")
        #endif
        ownerComponent?.componentStateDidChange()
    }
}
