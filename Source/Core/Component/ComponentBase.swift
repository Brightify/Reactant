//
//  ComponentBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 08.11.16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import RxSwift

open class ComponentBase<STATE, ACTION>: ComponentWithDelegate {
    
    public typealias StateType = STATE
    public typealias ActionType = ACTION

    /**
    Dispose bag for Observables, it disposes only at **deinit** and can be used for subscribing anywhere else but **update**.
    - Note: For subscribing inside of update use **stateDisposeBag**.
    */
    public let lifetimeDisposeBag = DisposeBag()

    public let componentDelegate = ComponentDelegate<STATE, ACTION, ComponentBase<STATE, ACTION>>()

    /**
    The `Observable` into which all Component's actions are merged.
    - Note: When listening to Component's actions, using **action** is preferred to **actions**.
    */
    open var action: Observable<ACTION> {
        return componentDelegate.action
    }

    /**
    Collection of Component's `Observable`s which are merged into **action**.
    - Note: When listening to Component's actions, using **action** is preferred to **actions**.
    */
    open var actions: [Observable<ACTION>] {
        return []
    }

    /**
    Overriding this function lets you control whether **update** will be called on next **componentState** change.
    */
    open func needsUpdate() -> Bool {
        return true
    }

    public init(canUpdate: Bool = true) {
        componentDelegate.ownerComponent = self
        
        resetActions()
        
        afterInit()
        
        componentDelegate.canUpdate = canUpdate
    }

    /**
    After overriding this function, it can be used for additional setting up independently of **init**.

    As the name implies, this function is called after **init**.
    */
    open func afterInit() {
    }

    /**
    The **update** function that gets called whenever **componentState** changes.

    After overriding this function, it can be used to update UI and/or pass **componentState** to subviews.
    - Warning: This function is NOT to be called directly, if you need to, use **invalidate** function.
    */
    open func update() {
    }

    public func observeState(_ when: ObservableStateEvent) -> Observable<STATE> {
        return componentDelegate.observeState(when)
    }
}
