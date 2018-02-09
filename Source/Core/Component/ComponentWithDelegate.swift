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

    /**
     * Array of observables through which the Component communicates with outside world.
     * - ATTENTION: Each of the `Observable`s need to be *rewritten* or *mapped* to be of the correct type - the ACTION.
     * - `ObservableConvertibleType.rewrite` is used on the Observable if it's `Void` and `ObservableConvertibleType.map` if it carries a value
     * - a good idea is to create an `enum`, cases without value should be used with method
     *  `ObservableConvertibleType.rewrite` and cases with should be used with method `ObservableConvertibleType.map`
     * ## Example
     * ```
     * button.rx.tap.rewrite(with: MyRootViewAction.loginTapped)
     *
     * textField.rx.text.skip(1).map(MyRootViewAction.emailChanged)
     * ```
     *
     * For more info, see [Component Action](https://docs.reactant.tech/getting-started/quickstart.html#component-action)
     * - WARNING: When listening to Component's actions, subscribe to `Component.action` instead of this variable.
     *  `Component.action` includes `Component.perform(action:)` calls as well as `Observable`s defined in `actions`.
     */
    var actions: [Observable<ActionType>] { get }

    /**
     * Used to reset `actions` `Observable` array. Useful when you have a condition in `actions` based on which certain `Observable`s are included in the array.
     * ## Example
     * You decide to change the amount of active buttons based on device orientation. `actions` don't automatically change
     * based on the conditions that are in the computed variable, because this would be ineffective.
     * This is where you call `resetActions()` when orientation changes causing `actions` to update and the amount of active buttons is changed as well.
     */
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

extension ComponentWithDelegate {
    /**
     * Mutates the `componentState` only once using the closure provided.
     * Should be used if you're modifying more than one of the `componentState`'s fields.
     *
     * **Usage**:
     * ```
     * var mutableState = componentState
     * mutableState.name = newName
     * mutableState.password = randomPassword
     * mutableState.friends = [] as [User]
     * componentState = mutableState
     * ```
     * becomes
     * ```
     * mutateState { state in
     *   state.name = newName
     *   state.password = randomPassword
     *   state.friends = [] as [User]
     * }
     * ```
     *
     * - parameter mutation: closure to which the current componentState is passed to be mutated in certain ways
     */
    func mutateState(_ mutation: (inout StateType) -> Void) {
        var mutableState = componentState
        mutation(&mutableState)
        componentState = mutableState
    }
}
