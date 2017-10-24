//
//  ObservableConvertibleType+Result.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift
import RxOptional
import Result

extension ObservableConvertibleType where E: ResultProtocol {

    /**
     * Filters `Observable` to block erroneous `Result`s while mapping the `Observable` to the value of `.success` that pass.
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
    public func filterError() -> Observable<E.Value> {
        return asObservable().map { $0.value }.filterNil()
    }

    /**
     * Filters `Observable` to block successful `Result`s while mapping the `Observable` to the error of `.failure` that pass.
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
    public func errorOnly() -> Observable<E.Error> {
        return asObservable().map { $0.error }.filterNil()
    }

    /**
     * Maps `Observable`'s value if the `Result` is `.success` while ignoring `Error` accompanied with `.failure`.
     * - parameter transform: prdel
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
    public func mapValue<T>(_ transform: @escaping (E.Value) -> T) -> Observable<Result<T, E.Error>> {
        return asObservable().map { $0.map(transform) }
    }

    /**
     * Maps `Observable`'s error if the `Result` is `.failure` while ignoring value accompanied with `.success`.
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
    public func mapError<T: Error>(_ transform: @escaping (E.Error) -> T) -> Observable<Result<E.Value, T>> {
        return asObservable().map { $0.mapError(transform) }
    }

    /**
     * `Result` equivalent of `Observable`'s `flatMap` only affecting `.success` value.
     * - NOTE: See `mapValue(_:)` and [FlatMap operator](http://reactivex.io/documentation/operators/flatmap.html).
     */
    public func flatMapValue<O>(_ selector: @escaping (E.Value) -> O) -> Observable<Result<O.E, E.Error>> where O : ObservableConvertibleType {
        return asObservable().flatMap { result -> Observable<Result<O.E, E.Error>> in
            result.analysis(
                ifSuccess: { value in
                    selector(value).asObservable().map(Result.success)
                },
                ifFailure: { error in
                    .just(.failure(error))
                })
        }
    }

    /**
     * `Result` equivalent of `Observable`'s `flatMapLatest` only affecting `.success` value.
     * - NOTE: See `mapValue(_:)` and [FlatMap operator](http://reactivex.io/documentation/operators/flatmap.html).
     */
    public func flatMapLatestValue<O>(_ selector: @escaping (E.Value) -> O) -> Observable<Result<O.E, E.Error>> where O : ObservableConvertibleType {
        return asObservable().flatMapLatest { result -> Observable<Result<O.E, E.Error>> in
            result.analysis(
                ifSuccess: { value in
                    selector(value).asObservable().map(Result.success)
                },
                ifFailure: { error in
                    .just(.failure(error))
                })
        }
    }

    /**
     * `Result` equivalent of `Observable`'s `flatMap` only affecting `.failure` error.
     * - NOTE: See `mapError(_:)` and [FlatMap operator](http://reactivex.io/documentation/operators/flatmap.html).
     */
    public func flatMapError<O>(_ selector: @escaping (E.Error) -> O) -> Observable<Result<E.Value, O.E>> where O : ObservableConvertibleType {
        return asObservable().flatMap { result -> Observable<Result<E.Value, O.E>> in
            result.analysis(
                ifSuccess: { value in
                    .just(.success(value))
                },
                ifFailure: { error in
                    selector(error).asObservable().map(Result.failure)
                })
        }
    }

    /**
     * `Result` equivalent of `Observable`'s `flatMap` only affecting `.failure` error.
     * - NOTE: See `mapError(_:)` and [FlatMap operator](http://reactivex.io/documentation/operators/flatmap.html).
     */
    public func flatMapLatestError<O>(_ selector: @escaping (E.Error) -> O) -> Observable<Result<E.Value, O.E>> where O : ObservableConvertibleType {
        return asObservable().flatMapLatest { result -> Observable<Result<E.Value, O.E>> in
            result.analysis(
                ifSuccess: { value in
                    .just(.success(value))
                },
                ifFailure: { error in
                    selector(error).asObservable().map(Result.failure)
                })
        }
    }

    /**
     * Convenience method equivalent to `Observable.rewrite(with:)`. Rewrites `.success` value with value passed to the method.
     */
    public func rewriteValue<T>(newValue: T) -> Observable<Result<T, E.Error>> {
        return mapValue { _ in newValue }
    }

    /**
     * If the `.success` value is `nil`, replace it with the value provided.
     * - parameter value: value to be used if `.success` value is `nil`
     */
    public func recover(_ value: E.Value) -> Observable<E.Value> {
        return asObservable().map { $0.value ?? value }
    }

    /**
     * Unwrap the value in `.success`, if it's `.failure`, `nil` will be sent instead.
     */
    public func recoverWithNil() -> Observable<Self.E.Value?> {
        return asObservable().map { $0.value }
    }
}
