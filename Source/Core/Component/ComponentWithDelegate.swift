//
//  ComponentWithDelegate.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

public protocol ComponentWithDelegate: Component {
    
    associatedtype ComponentType: Component
    
    var componentDelegate: ComponentDelegate<StateType, ActionType, ComponentType> { get }
    
    var actions: [Observable<ActionType>] { get }
    
    func resetActions()
}

extension ComponentWithDelegate {
    
    public var stateDisposeBag: DisposeBag {
        return componentDelegate.stateDisposeBag
    }

    public var observableState: Observable<StateType> {
        return componentDelegate.observableState
    }

    public var previousComponentState: StateType? {
        return componentDelegate.previousComponentState
    }

    public var componentState: StateType {
        get {
            return componentDelegate.componentState
        }
        set {
            componentDelegate.componentState = newValue
        }
    }

    /**
    Prepares everything needed and calls **update**.
    - Note: Should be used sparingly, for most situations update called automatically by changing **componentState** should suffice.
    */
    public func invalidate() {
        if componentDelegate.hasComponentState {
            componentDelegate.needsUpdate = true
        }
    }
    
    public func perform(action: ActionType) {
        componentDelegate.perform(action: action)
    }
}

extension ComponentWithDelegate {

    public func resetActions() {
        componentDelegate.actions = actions
    }
}
