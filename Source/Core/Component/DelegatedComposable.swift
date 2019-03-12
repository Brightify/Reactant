//
//  DelegatedComposable.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 12/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

public protocol DelegatedComposable: Composable {
    //    var composableDelegate: ComponentDelegate

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
}
