//
//  Component.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 12/06/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

public protocol Component: class {
    
    associatedtype StateType
    
    /// DisposeBag for one-time subscriptions made in init. It is reset just before deallocating.
    var lifetimeDisposeBag: DisposeBag { get }
    
    /// DisposeBag for actions in `update`. This is reset before each `update` call.
    var stateDisposeBag: DisposeBag { get }
    
    /// Observable with the current state of the component. Do not use this in `render` to avoid duplicite loading bugs
    var observableState: Observable<StateType> { get }
    
    var previousComponentState: StateType? { get }
    
    var componentState: StateType { get set }
    
    // Do not access componentState.
    func afterInit()
    
    func needsUpdate() -> Bool
    
    func update()
    
    func invalidate()
}

extension Component {
    
    public var setComponentState: (StateType) -> Void {
        return { [weak self] in
            self?.componentState = $0
        }
    }
    
    public func with(state: StateType) -> Self {
        componentState = state
        return self
    }
}

extension Component {
    
    public func needsUpdate() -> Bool {
        return true
    }
}

extension Component where StateType: Equatable {
    
    public func needsUpdate() -> Bool {
        return componentState != previousComponentState
    }
}
