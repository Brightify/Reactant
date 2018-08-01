//
//  ObservableConvertibleType+Utils.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

public extension ObservableConvertibleType {

    /**
     * Creates an `Observable` tuple `(previous, current)`, both are of the same type, `previous` is `Optional`,
     * because the first value has no predecessor.
     * - returns: `Observable` tuple with current value and its `Optional` predecessor
     */
    public func lag() -> Observable<(previous: E?, current: E)> {
        return asObservable().scan((previous: nil as E?, current: nil as E?)) { ($0.current, current: $1) }
            .filter { $0.current != nil }
            .map { ($0, $1!) }
    }

    /**
     * Creates an observable erasing the original type and replacing its value with Void()
     * - returns: `Observable` with Void value
     */
    public func rewrite() -> Observable<Void> {
        return asObservable().rewrite(with: Void())
    }

    /**
     * Remap the value of the `Observable` without caring about the value it had beforehand.
     * - parameter value: value to rewrite `Observable` with
     * - returns: `Observable` with remapped value
     */
    public func rewrite<T>(with value: T) -> Observable<T> {
        return asObservable().map { _ in value }
    }

    /**
     * Combines current `Observable` with another creating a tuple where the passed `Observable` will be on the right side.
     * - parameter second: `Observable` to be added to the right side
     * - returns: `Observable` tuple containing the passed `Observable` on the right
     */
    public func withLatestFrom<O: ObservableConvertibleType>(right second: O) -> Observable<(E, O.E)> {
        return asObservable().withLatestFrom(second) { ($0, $1) }
    }

    /**
     * Combines current `Observable` with another creating a tuple where the passed `Observable` will be on the left side.
     * - parameter second: `Observable` to be added to the left side
     * - returns: `Observable` tuple containing the passed `Observable` on the left
     */
    public func withLatestFrom<O: ObservableConvertibleType>(left second: O) -> Observable<(O.E, E)> {
        return asObservable().withLatestFrom(second) { ($1, $0) }
    }

    /**
     * Creates an `Observable` from passed value and combines it with the current `Observable` using the passed closure.
     * - parameter value: generic parameter denoting the value of the second `Observable`-to-be
     * - parameter resultSelector: determines how the value and current `Observable` will be arranged
     * - returns: `Observable` tuple containing the passed value depending on how it was arranged in the closure
     * ## Example
     * ```
     * // this will put the value to the right, $0 is current Observable, $1 is the value
     * httpRequest.with(authToken) { ($0, $1) }
     *
     * // equivalent to:
     * httpRequest.with(right: authToken)
     * ```
     *
     */
    public func with<T, U>(_ value: T, resultSelector: @escaping (E, T) -> U) -> Observable<U> {
        return asObservable().withLatestFrom(Observable.just(value), resultSelector: resultSelector)
    }

    /**
     * See `with(_:resultSelector:)`, this method places the value on the right side of the tuple.
     * - parameter value: generic parameter denoting the value of the second `Observable`-to-be
     * - returns: `Observable` tuple with the passed value on the right
     */
    public func with<T>(right value: T) -> Observable<(E, T)> {
        return asObservable().with(value) { ($0, $1) }
    }

    /**
     * See `with(_:resultSelector:)`, this method places the value on the left side of the tuple.
     * - parameter value: generic parameter denoting the value of the second `Observable`-to-be
     * - returns: `Observable` tuple with the passed value on the left
     */
    public func with<T>(left value: T) -> Observable<(T, E)> {
        return asObservable().with(value) { ($1, $0) }
    }

    /**
     * Reforms `Error`s into `nil`.
     * - returns: `Observable` with `Optional` value, `nil` if it was erroneous
     */
    public func nilOnError() -> Observable<E?> {
        return asObservable().map(Optional.init).catchErrorJustReturn(nil)
    }

    /**
     * Similar to startWith, but does not resolve the value until it is subscribed to.
     * - parameter source:
     * - returns: `Observable` containing the `source`
     */
    public func startWithWhenSubscribed(source: @escaping () -> E) -> Observable<E> {
        return asObservable().map { value in { value } }.startWith(source).map { $0() }
    }
}
