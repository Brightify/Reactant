//
//  Component.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 12/06/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

public enum ObservableStateEvent {
    case beforeUpdate
    case afterUpdate
}

public protocol Invalidable: class {
    /**
     * Used for manually calling **update()**. As opposed to `componentState = componentState` this preserves **previousComponentState**.
     * - NOTE: For most situations update called automatically by changing **componentState** should suffice. However if you're dealing with **reference type** as `componentState`, manually calling **invalidate()** lets you update manually.
     */
    func invalidate()
}

public protocol Component: Invalidable {

    associatedtype StateType
    associatedtype ActionType

    /**
     * Dispose bag for Observables, it disposes at Component's **deinit** and can be used for subscribing anywhere else but **update**.
     * - Note: For subscribing inside of update use **stateDisposeBag**.
     */
    var lifetimeDisposeBag: DisposeBag { get }

    /**
     * Dispose bag for Observables, it disposes before every **update()** call and is encouraged when subscribing in **update()**.
     * - NOTE: For subscribing outside of update use **lifetimeDisposeBag**.
     */
    var stateDisposeBag: DisposeBag { get }

    /**
     * `Observable` equivalent of the **componentState**.
     *
     * Should only be used for its value in `Observable` work, not for subscribing. For getting a **componentState** observable to subscribe to see **observeState(_:)**.
     * - NOTE: For more info, see [RxSwift](https://github.com/ReactiveX/RxSwift).
     * - WARNING: Do not use this in **update()** to avoid duplicite loading bugs.
     */
    var observableState: Observable<StateType> { get }

    /**
     * Every time **componentState** changes, its old value is saved into **previousComponentState**.
     * - NOTE: Its value is `nil` in first **update()** call and can be used for running code in the first update (beware if your componentState is `Optional`).
     */
    var previousComponentState: StateType? { get }

    /**
     * The recommended single point of mutation in the Reactant architecture. Usually a `Struct` containing multiple values, but it can be any **value type**, even **reference type**, though those are not suitable for **componentState**.
     *
     * Every time modified, **update()** is called if **needsUpdate** and **canUpdate** are `true`.
     *
     * You can control the conditions under which **update()** is called by overriding **needsUpdate** or **canUpdate**, both need to be **true** in order for `update()` to be called on next `componentState` change.
     * - WARNING: **Reference type** is not suitable as a `componentState` because there's no way to detect changes, using such a type is feasible by calling **invalidate()** manually. More info: [Components and everything about them](https://docs.reactant.tech/getting-started/quickstart.html#writing-components).
     */
    var componentState: StateType { get set }

    /**
     * The `Observable` into which all Component's actions and **perform(action:)** calls are merged.
     * - NOTE: When listening to Component's actions, using **action** is strongly recommended instead of **actions**. This is because **actions** contains only `Observable`s, so any **perform(action:)** will be ignored.
     */
    var action: Observable<ActionType> { get }

    /**
     * After overriding this method, it can be used for additional setup independent of **init**.
     *
     * Recommended setup inside this method is subscribing to all observables that you need subscribed only once; alternatively if the subscription is meant to last the whole existence of the Component. We recommend **lifetimeDisposeBag** as the `DisposeBag` of choice.
     *
     * As the name implies, this method is called only once after **init**.
     * - WARNING: **componentState** is not set in this method and trying to access it will result in a crash.
     */
    func afterInit()

    /**
     * Overriding this method lets you control whether **update** will be called on next **componentState** modification.
     */
    func needsUpdate() -> Bool

    /**
     * The **update()** method that gets called whenever **componentState** changes as long as **needsUpdate** and **canUpdate** are both `true`.
     *
     * Recommended usage of this method is updating UI and/or passing **componentState** to subviews.
     * - WARNING: This method is NOT to be called directly, if you need to, use **invalidate()** method.
     */
    func update()

    /**
     * Method that manually sends an `action` of type ACTION.
     *
     * Useful when dealing with something that is hard to make into an `Observable`.
     * - parameter action: ACTION model you wish to send
     * - NOTE: An `action` sent with this method gets merged with the **action** `Observable`. For more info, see [Component Action](https://docs.reactant.tech/getting-started/quickstart.html#component-action).
     */
    func perform(action: ActionType)

    /**
     * Recommended way of getting an `Observable` to subscribe to.
     * If you wish to get an `Observable` to use in **actions** or do other `Observable` work, see **observableState**.
     */
    func observeState(_ when: ObservableStateEvent) -> Observable<StateType>
}

extension Component {

    public var setComponentState: (StateType) -> Void {
        return { [unowned self] in
            self.componentState = $0
        }
    }

    /**
     * Method that lets you set initial **componentState** of the Component during initialization.
     * ## Example
     *     let component = AwesomeDateComponent(locale: Locale.US).with(state: Date.today)
     */
    public func with(state: StateType) -> Self {
        componentState = state
        return self
    }
}
