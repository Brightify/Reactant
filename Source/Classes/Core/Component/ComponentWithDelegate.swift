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
    
    public var action: Observable<ActionType> {
        return componentDelegate.action
    }
    
    public func invalidate() {
        componentDelegate.needsUpdate = true
    }
    
    public func perform(action: ActionType) {
        componentDelegate.perform(action: action)
    }
}

extension ComponentWithDelegate {
    
    public var actions: [Observable<ActionType>] {
        return []
    }
    
    public func resetActions() {
        componentDelegate.actions = actions
    }
}
