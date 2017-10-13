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

    public let lifetimeDisposeBag = DisposeBag()

    public let componentDelegate = ComponentDelegate<STATE, ACTION, ComponentBase<STATE, ACTION>>()

    open var action: Observable<ACTION> {
        return componentDelegate.action
    }

    /**
    Collection of Component's `Observable`s which are merged into `Component.action`.
    - Note: When listening to Component's actions, using `action` is preferred to `actions`.
    */
    open var actions: [Observable<ACTION>] {
        return []
    }

    open func needsUpdate() -> Bool {
        return true
    }

    public init(canUpdate: Bool = true) {
        componentDelegate.ownerComponent = self
        
        resetActions()
        
        afterInit()
        
        componentDelegate.canUpdate = canUpdate
    }

    open func afterInit() {
    }

    open func update() {
    }

    public func observeState(_ when: ObservableStateEvent) -> Observable<STATE> {
        return componentDelegate.observeState(when)
    }
}
