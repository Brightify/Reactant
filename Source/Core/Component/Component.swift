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
    associatedtype ActionType
    
    /// DisposeBag for one-time subscriptions made in init. It is reset just before deallocating.
    var lifetimeDisposeBag: DisposeBag { get }
    
    /// DisposeBag for actions in `update`. This is reset before each `update` call.
    var stateDisposeBag: DisposeBag { get }
    
    /// Observable with the current state of the component. Do not use this in `render` to avoid duplicite loading bugs
    var observableState: Observable<StateType> { get }
    
    var previousComponentState: StateType? { get }
    
    var componentState: StateType { get set }
    
    var action: Observable<ActionType> { get }
    
    /// Do not access componentState in this method.
    func afterInit()
    
    func needsUpdate() -> Bool
    
    func update()
    
    func invalidate()
    
    func perform(action: ActionType)
}

extension Component {
    
    public var setComponentState: (StateType) -> Void {
        return { [unowned self] in
            self.componentState = $0
        }
    }
    
    public func with(state: StateType) -> Self {
        componentState = state
        return self
    }
}
