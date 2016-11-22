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
    
    var componentDelegate: ComponentDelegate<StateType, ComponentType> { get }
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
    
    public func afterInit() {
    }
    
    public func update() {
    }
    
    public func invalidate() {
        componentDelegate.needsUpdate = true
    }
}
