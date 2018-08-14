//
//  ComponentBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 08.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

open class ComponentBase<STATE, ACTION>: ComponentWithDelegate {
    
    public typealias StateType = STATE
    public typealias ActionType = ACTION

    #if ENABLE_RXSWIFT
    public let lifetimeDisposeBag = DisposeBag()
    #else
    public let lifetimeTracking = ObservationTokenTracker()
    #endif

//    public let componentDelegate: ComponentDelegate<ComponentBase<STATE, ACTION>>


    /**
     * Collection of Component's `Observable`s which are merged into `Component.action`.
     * - Note: When listening to Component's actions, using `action` is preferred to `actions`.
     */
    open var actions: [Observable<ACTION>] {
        return []
    }

    open func needsUpdate() -> Bool {
        return true
    }

    public init(canUpdate: Bool = true) {
        
//        componentDelegate.ownerComponent = self

        #if ENABLE_RXSWIFT
        resetActions()
        #else
        resetActionMapping()
        #endif
        
        afterInit()
        
        componentDelegate.canUpdate = canUpdate
    }

    open func afterInit() {
    }

    open func update() {
    }

//    public func observeState(_ when: ObservableStateEvent) -> Observable<STATE> {
//        return componentDelegate.behavior.observeState(when)
//    }
}
