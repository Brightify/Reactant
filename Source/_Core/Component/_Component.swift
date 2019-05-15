//
//  Component.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 12/06/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public enum ObservableStateEvent {
    case beforeUpdate
    case afterUpdate
}

public protocol _Component: Invalidable {
    associatedtype StateType
    associatedtype ActionType

    /**
     * The recommended single point of mutation in the Reactant architecture. Usually a `Struct` containing multiple values,
     *  but it can be any **value type**, even **reference type**, though those are not suitable for `componentState`.
     *
     * Every time modified, `update()` is called if `ComponentDelegate.needsUpdate` and `ComponentDelegate.canUpdate` are `true`.
     *
     * You can control the conditions under which `update()` is called by overriding `needsUpdate()` or
     *  `ComponentDelegate.canUpdate`, both need to return **true** in order for `update()` to be called on next `componentState` change.
     * - WARNING: **Reference type** is not suitable as a `componentState` because there's no way to detect changes,
     *  using such a type is feasible by calling `Invalidable.invalidate()` manually.
     *  More info: [Components and everything about them](https://docs.reactant.tech/getting-started/quickstart.html#writing-components).
     */
    var componentState: StateType { get set }

    /**
     * After overriding this method, it can be used for additional setup independent of **init**.
     *
     * Recommended setup inside this method is subscribing to all observables that you need subscribed only once; 
     * alternatively if the subscription is meant to last the whole existence of the Component. We recommend `lifetimeDisposeBag` as the `DisposeBag` of choice.
     *
     * As the name implies, this method is called only once after **init**.
     * - WARNING: `componentState` is not set in this method and trying to access it will result in a crash.
     */
    func afterInit()

    /**
     * Overriding this method lets you control whether `update()` will be called on next `componentState` modification.
     */
    func needsUpdate(previousState: StateType?) -> Bool

    /**
     * The method that gets called whenever `componentState` changes as long as `ComponentDelegate.needsUpdate` and `ComponentDelegate.canUpdate` are both `true`.
     *
     * Recommended usage of this method is updating UI and/or passing `componentState` to subviews.
     * - WARNING: This method is NOT to be called directly, if you need to, use `Invalidable.invalidate()` method.
     */
    func update(previousState: StateType?)

    /**
     * Method that manually sends an `action` of type ACTION.
     *
     * Useful when dealing with something that is hard to make into an `Observable`.
     * - parameter action: ACTION model you wish to send
     * - NOTE: An action sent with this method gets merged with the `action` `Observable`.
     *  For more info, see [Component Action](https://docs.reactant.tech/getting-started/quickstart.html#component-action).
     */
    func perform(action: ActionType)

    // MARK: - Observing events
    var lifetimeTracking: ObservationTokenTracker { get }

    var stateTracking: ObservationTokenTracker { get }

    func observeAction(observer: @escaping (ActionType) -> Void) -> ObservationToken

    func observeState(_ when: ObservableStateEvent, observer: @escaping (StateType) -> Void) -> ObservationToken
}

extension _Component {

    /**
     * Closure letting you conveniently set component state through `Observable` subscription without memory leaks.
     * ## Example
     * ```
     * override func afterInit() {
     *   myImportantObservable
     *     .subscribe(onNext: setComponentState)
     *     .disposed(by: lifetimeDisposeBag)
     *
     *   // is equivalent to
     *
     *   myImportantObservable
     *     .subscribe(onNext: { [unowned self] newValue in
     *       self.componentState = newValue
     *     }
     *     .disposed(by: lifetimeDisposeBag)
     * }
     * ```
     */
    public var setComponentState: (StateType) -> Void {
        return { [unowned self] in
            self.componentState = $0
        }
    }

    /**
     * Method that lets you set initial `componentState` of the Component, usually during initialization.
     * ## Example
     * ```
     * let component = AwesomeDateComponent(locale: Locale.US).with(state: Date.today)
     * ```
     */
    public func with(state: StateType) -> Self {
        componentState = state
        return self
    }

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
    public func mutateState(_ mutation: (inout StateType) -> Void) {
        var mutableState = componentState
        mutation(&mutableState)
        componentState = mutableState
    }
}









