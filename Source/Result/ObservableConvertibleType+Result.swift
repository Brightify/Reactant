//
//  ObservableConvertibleType+Result.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift
import RxOptional

public protocol ResultConvertible {
    associatedtype Success
    associatedtype Failure: Swift.Error

    func asResult() -> Result<Success, Failure>
}

extension Swift.Result: ResultConvertible {
    public func asResult() -> Result<Success, Failure> {
        return self
    }
}

internal extension Result {
    var value: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    var error: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

public extension ObservableConvertibleType where Element: ResultConvertible {

    /**
     * Filters `Observable` to block erroneous `Result`s while mapping the `Observable` to the value of `.success` that pass.
     * - returns: `Observable` of type `Result` and its `.failure` `Result`s filtered out
     * ## Example
     * ```
     * httpObservable.filterError()
     *   .do(onNext: { response in
     *     // no need to create a switch to check whether Result is .success or .failure
     *   }
     * ```
     *
     * - NOTE: It's considered good practice to error-handle properly (using a switch), but in combination with `errorOnly()` it can be used for simple and elegant error-handling.
     */
    func filterError() -> Observable<Element.Success> {
        return asObservable().compactMap { $0.asResult().value }
    }

    /**
     * Filters `Observable` to block successful `Result`s while mapping the `Observable` to the error of `.failure` that pass.
     * - returns: `Observable` of type `Result` and its `.success` `Result`s filtered out
     * ## Example
     * ```
     * httpObservable.errorOnly()
     *   .do(onNext: { error in
     *     // no need to create a switch to check whether Result is .success or .failure
     *   }
     * ```
     *
     * - NOTE: It's considered good practice to error-handle properly (using a switch), but in combination with `filterError()` it can be used for simple and elegant error-handling.
     */
    func errorOnly() -> Observable<Element.Failure> {
        return asObservable().compactMap { $0.asResult().error }
    }

    /**
     * Maps `Observable`'s value if the `Result` is `.success` while ignoring `Error` accompanied with `.failure`.
     * - parameter transform: closure to use when transforming value
     * - returns: `Observable` of type `Result` and its `.success` values transformed using the passed closure
     * ## Example
     * ```
     * httpObservable.mapValue { response in
     *   return modifyResponse(response)
     * }
     * .do(onNext: { result in
     *   switch result {
     *   case .success(let modifiedResponse):
     *     // value here is modified using the closure passed to mapValue()
     *   case .failure(let error):
     *     // error is untouched by the closure
     *   }
     * }
     * ```
     *
     * - NOTE: For mapping error on `.failure`, see `mapError(_:)`.
     */
    func mapValue<T>(_ transform: @escaping (Element.Success) -> T) -> Observable<Result<T, Element.Failure>> {
        return asObservable().map { $0.asResult().map(transform) }
    }

    /**
     * Maps `Observable`'s error if the `Result` is `.failure` while ignoring value accompanied with `.success`.
     * - parameter transform: closure to use when transforming error
     * - returns: `Observable` of type `Result` and its `.failure` errors transformed using the passed closure
     * ## Example
     * ```
     * httpObservable.mapError { error in
     *   return modifyError(error)
     * }
     * .do(onNext: { result in
     *   switch result {
     *   case .success(let response):
     *     // value is untouched by the closure
     *   case .failure(let modifiedError):
     *     // error here is modified using the closure passed to mapError()
     *   }
     * }
     * ```
     *
     * - NOTE: For mapping value on `.success`, see `mapValue(_:)`.
     */
    func mapError<T: Error>(_ transform: @escaping (Element.Failure) -> T) -> Observable<Result<Element.Success, T>> {
        return asObservable().map { $0.asResult().mapError(transform) }
    }

    /**
     * `Result` equivalent of `Observable`'s `flatMap` only affecting `.success` value.
     * - parameter selector: closure to use when transforming value into `Observable`
     * - returns: `Observable` of type `Result` and its `.success` values transformed using the passed closure
     * - NOTE: See `mapValue(_:)` and [FlatMap operator](http://reactivex.io/documentation/operators/flatmap.html).
     */
    func flatMapValue<O>(_ selector: @escaping (Element.Success) -> O) -> Observable<Result<O.Element, Element.Failure>> where O : ObservableConvertibleType {
        return asObservable().flatMap { result -> Observable<Result<O.Element, Element.Failure>> in
            switch result.asResult() {
            case .success(let value):
                return selector(value).asObservable().map(Result.success)
            case .failure(let error):
                return .just(.failure(error))
            }
        }
    }

    /**
     * `Result` equivalent of `Observable`'s `flatMapLatest` only affecting `.success` value.
     * - parameter selector: closure to use when transforming value into `Observable`
     * - returns: `Observable` of type `Result` and its `.success` values transformed using the passed closure
     * - NOTE: See `mapValue(_:)` and [FlatMap operator](http://reactivex.io/documentation/operators/flatmap.html).
     */
    func flatMapLatestValue<O>(_ selector: @escaping (Element.Success) -> O) -> Observable<Result<O.Element, Element.Failure>> where O : ObservableConvertibleType {
        return asObservable().flatMapLatest { result -> Observable<Result<O.Element, Element.Failure>> in
            switch result.asResult() {
            case .success(let value):
                return selector(value).asObservable().map(Result.success)
            case .failure(let error):
                return .just(.failure(error))
            }
        }
    }

    /**
     * `Result` equivalent of `Observable`'s `flatMap` only affecting `.failure` error.
     * - parameter selector: closure to use when transforming error into `Observable`
     * - returns: `Observable` of type `Result` and its `.failure` errors transformed using the passed closure
     * - NOTE: See `mapError(_:)` and [FlatMap operator](http://reactivex.io/documentation/operators/flatmap.html).
     */
    func flatMapError<O>(_ selector: @escaping (Element.Failure) -> O) -> Observable<Result<Element.Success, O.Element>> where O : ObservableConvertibleType {
        return asObservable().flatMap { result -> Observable<Result<Element.Success, O.Element>> in
            switch result.asResult() {
            case .success(let value):
                return .just(.success(value))
            case .failure(let error):
                return selector(error).asObservable().map(Result.failure)
            }
        }
    }

    /**
     * `Result` equivalent of `Observable`'s `flatMap` only affecting `.failure` error.
     * - parameter selector: closure to use when transforming error into `Observable`
     * - returns: `Observable` of type `Result` and its `.failure` errors transformed using the passed closure
     * - NOTE: See `mapError(_:)` and [FlatMap operator](http://reactivex.io/documentation/operators/flatmap.html).
     */
    func flatMapLatestError<O>(_ selector: @escaping (Element.Failure) -> O) -> Observable<Result<Element.Success, O.Element>> where O : ObservableConvertibleType {
        return asObservable().flatMapLatest { result -> Observable<Result<Element.Success, O.Element>> in
            switch result.asResult() {
            case .success(let value):
                return .just(.success(value))
            case .failure(let error):
                return selector(error).asObservable().map(Result.failure)
            }
        }
    }

    /**
     * Convenience method equivalent to `Observable.rewrite(with:)`. Rewrites `.success` value with value passed to the method.
     * - parameter newValue: the value you wish to rewrite `Observable` values with
     * - returns: `Observable` with `Result`'s `.success` values rewritten with provided parameter
     */
    func rewriteValue<T>(newValue: T) -> Observable<Result<T, Element.Failure>> {
        return mapValue { _ in newValue }
    }

    /**
     * If the `.success` value is `nil`, replace it with the value provided.
     * - parameter value: value to be used if `.success` value is `nil`
     * - returns: `Observable` where `nil` values as well as `.failure` errors are rewritten by provided value
     */
    func recover(_ value: Element.Success) -> Observable<Element.Success> {
        return asObservable().map { $0.asResult().value ?? value }
    }

    /**
     * Unwrap the value in `.success`, if it's `.failure`, `nil` will be sent instead.
     * - returns: `Observable` with errors rewritten with `nil`
     * - NOTE: If you want to have purely errorless `Observable` and don't care about `nil`s, consider using `filterError()`.
     */
    func recoverWithNil() -> Observable<Element.Success?> {
        return asObservable().map { $0.asResult().value }
    }
}
