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
     * Used for manually calling `Component.update()`. As opposed to `componentState = componentState` this preserves `previousComponentState`.
     * - NOTE: For most situations update called automatically by changing `Component.componentState` should suffice.
     *  However if you're dealing with **reference type** as `componentState`, manually calling `invalidate()` lets you update manually.
     */
    func invalidate()
}

//public struct ComponentAction<C: Component> {
//    public let component: C
//    public let action: C.ActionType
//}

//// FIXME Rename to ComponentDelegate? (would break API!)
//public protocol _ComponentDelegate {
//    func componentStateWillChange<C: Component>(_ component: C, newState: C.StateType)
//
//    func componentStateDidChange<C: Component>(_ component: C, oldState: C.StateType?)
//
//    func componentPerformedAction<C: Component>(_ componentAction: ComponentAction<C>)
//}
//
//public extension _ComponentDelegate {
//    func componentStateWillChange<C: Component>(_ component: C, newState: C.StateType) { }
//
//    func componentStateDidChange<C: Component>(_ component: C, oldState: C.StateType?) { }
//
//    func componentPerformedAction<C: Component>(_ componentAction: ComponentAction<C>) { }
//}

#if ENABLE_RXSWIFT
//#error("Not implemented")
#elseif ENABLE_PROMISEKIT
#error("Not implemented")
#else
public final class ObservationToken: Hashable, Equatable {
    private let onStop: () -> Void

    public init(onStop: @escaping () -> Void) {
        self.onStop = onStop
    }

    public func stopObserving() {
        onStop()
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    public static func ==(lhs: ObservationToken, rhs: ObservationToken) -> Bool {
        return lhs === rhs
    }

    public func track(in tracker: ObservationTokenTracker) {
        tracker.track(token: self)
    }
}

public final class ObservationTokenTracker {

    private var tokens = Set<ObservationToken>()

    public init() {

    }

    public func track(token: ObservationToken) {
        tokens.insert(token)
    }

    public func track<S: Sequence>(tokens: S) where S.Element == ObservationToken {
        self.tokens.formUnion(tokens)
    }

    deinit {
        for token in tokens {
            token.stopObserving()
        }
    }
}
#endif

public protocol Component: Invalidable {
    associatedtype StateType
    associatedtype ActionType

    /**
     * Every time `componentState` changes, its old value is saved into this get-only variable.
     * - NOTE: Its value is `nil` in first `update()` call and can be used for running code in the first update (beware if your componentState is `Optional`).
     */
    var previousComponentState: StateType? { get }

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
    func needsUpdate() -> Bool

    /**
     * The method that gets called whenever `componentState` changes as long as `ComponentDelegate.needsUpdate` and `ComponentDelegate.canUpdate` are both `true`.
     *
     * Recommended usage of this method is updating UI and/or passing `componentState` to subviews.
     * - WARNING: This method is NOT to be called directly, if you need to, use `Invalidable.invalidate()` method.
     */
    func update()

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
    // MARK: RxSwift observing
    #if ENABLE_RXSWIFT
    /**
     * This `DisposeBag` gets disposed at `Component`'s **deinit** and should be used
     * to dispose subscriptions outside of `update()`.
     *
     * **Usage**:
     * ```
     * // inside afterInit()
     *
     * friendService.defaultFriends
     *   .subscribe(onNext: { friends in
     *     componentState = friends
     *   }
     *   .disposed(by: lifetimeDisposeBag)
     * ```
     *
     * - WARNING: It's strongly discouraged to use this `DisposeBag` in the `update()` method.
     * Use the `stateDisposeBag` for that.
     */
    var lifetimeDisposeBag: DisposeBag { get }

    /**
     * This `DisposeBag` gets disposed after every `update()` call and should be used
     * to dispose subscriptions inside `update()`.
     *
     * **Usage**:
     * ```
     * // inside update()
     *
     * friendService.newFriends
     *   .subscribe(onNext: { friends in
     *     rootView.componentState = .items(friends)
     *   }
     *   .disposed(by: stateDisposeBag)
     * ```
     *
     * - WARNING: It's strongly discouraged to use this `DisposeBag` anywhere else than in the `update()` method.
     * Use the `lifetimeDisposeBag` for that.
     */
    var stateDisposeBag: DisposeBag { get }

    /**
     * `Observable` equivalent of the `componentState`.
     *
     * Should only be used for its value in `Observable` work, not for subscribing. For getting a `componentState` observable to subscribe to see `observeState(_:)`.
     * - NOTE: For more info, see [RxSwift](https://github.com/ReactiveX/RxSwift).
     * - WARNING: Do not use this in `update()` to avoid duplicite loading bugs.
     */
    var observableState: Observable<StateType> { get }

    /**
     * The `Observable` into which all Component's actions and `perform(action:)` calls are merged.
     * - NOTE: When listening to Component's actions, using `action` is strongly recommended instead of `actions`.
     *  This is because `ComponentBase.actions` contains only `Observable`s, so any `perform(action:)` will be ignored.
     */
    var action: Observable<ActionType> { get }

    /**
     * Recommended way of getting an `Observable` to subscribe to.
     * If you wish to get an `Observable` to use in `actions` or do other `Observable` work, see `observableState`.
     */
    func observeState(_ when: ObservableStateEvent) -> Observable<StateType>

    // MARK: PromiseKit observing
    #elseif ENABLE_PROMISEKIT

    // MARK: Listener closure observing
    #else
    var lifetimeTracking: ObservationTokenTracker { get }

    var stateTracking: ObservationTokenTracker { get }

    func observeAction(observer: @escaping (ActionType) -> Void) -> ObservationToken

    func observeState(_ when: ObservableStateEvent, observer: @escaping (StateType) -> Void) -> ObservationToken
    #endif
}

#if !ENABLE_RXSWIFT
private var lifetimeTrackingKey = 0 as UInt8
private var stateTrackingKey = 0 as UInt8

extension Component {
//    public var lifetimeTracking: ObservationTokenTracker {
//        return associatedObject(self, key: &lifetimeTrackingKey) {
//            return ObservationTokenTracker()
//        }
//    }
}
#endif

extension Component {

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

