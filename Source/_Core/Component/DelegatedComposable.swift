//
//  DelegatedComposable.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 12/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

public protocol DelegatedComposable: Composable {
    var composableDelegate: ComposableDelegate<Change, Action> { get }

    var submitBehavior: SubmitBehavior { get }
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
    func actionMapping(mapper: ActionMapper<Action>)

    func apply(change: Change)

    func shouldApply(change: Change) -> Bool
}

extension DelegatedComposable {
    public var submitBehavior: SubmitBehavior {
        return .sync
    }

    public func shouldApply(change: Change) -> Bool {
        return true
    }

    public func observeAction(observer: @escaping (Action) -> Void) -> ObservationToken {
        return composableDelegate.behavior.observeAction(observer: observer)
    }
}

extension DelegatedComposable {
    public func perform(action: Action) {
        composableDelegate.perform(action: action)
    }

    public func resetActionMapping() {
        composableDelegate.behavior.registerActionMapping(actionMapping)
    }
}

public protocol DelegatedStatefulComposable: DelegatedComposable, StatefulComposable {
    var state: State { get set }

    func update(previousState: State?, causedBy change: Change)

    static func setChange(for state: State) -> Change
}

extension DelegatedStatefulComposable {
    func mutateState(with mutation: (inout State) -> Void) {
        var mutableState = state
        mutation(&mutableState)
        submit(change: Self.setChange(for: mutableState))
    }
}
