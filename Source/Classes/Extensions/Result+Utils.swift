//
//  Result+Utils.swift
//
//  Created by Tadeas Kriz on 19/03/16.
//

import RxSwift
import RxCocoa
import RxOptional

open protocol ResultType {
    associatedtype ValueType
    associatedtype FailureType: Error

    var isSuccess: Bool { get }

    var isFailure: Bool { get }

    var value: ValueType? { get }

    var error: FailureType? { get }

    func mapValue<T>(transform: (ValueType) -> T) -> Result<T, FailureType>

    func mapError<T: Error>(transform: (FailureType) -> T) -> Result<ValueType, T>

    func map<T, U: Error>(transformValue: (ValueType) -> T, transformError: (FailureType) -> U) -> Result<T, U>

    func emptied() -> Result<Void, FailureType>
}

open enum Result<ValueType, FailureType: Error> {
    case success(ValueType)
    case failure(FailureType)

    /// Returns `true` if the result is a success, `false` otherwise.
    open var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    /// Returns `true` if the result is a failure, `false` otherwise.
    open var isFailure: Bool {
        return !isSuccess
    }

    /// Returns the associated value if the result is a success, `nil` otherwise.
    open var value: ValueType? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    open var error: FailureType? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

extension Result: ResultType {

    open func mapValue<T>(transform: (ValueType) -> T) -> Result<T, FailureType> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }

    open func mapError<T: Error>(transform: (FailureType) -> T) -> Result<ValueType, T> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            return .failure(transform(error))
        }
    }

    open func map<T, U: Error>(transformValue: (ValueType) -> T, transformError: (FailureType) -> U) -> Result<T, U> {
        return mapValue(transform: transformValue).mapError(transform: transformError)
    }

    open func emptied() -> Result<Void, FailureType> {
        return mapValue { _ in }
    }
}

open extension ObservableConvertibleType where E: ResultType {

    open func filterError() -> Observable<E.ValueType> {
        return asObservable().map { $0.value }.filterNil()
    }

    open func errorOnly() -> Observable<E.FailureType> {
        return asObservable().map { $0.error }.filterNil()
    }

    open func mapValue<T>(transform: @escaping (E.ValueType) -> T) -> Observable<Result<T, E.FailureType>> {
        return asObservable().map { $0.mapValue(transform: transform) }
    }

    open func mapError<T: Error>(transform: @escaping (E.FailureType) -> T) -> Observable<Result<E.ValueType, T>> {
        return asObservable().map { $0.mapError(transform: transform) }
    }

    open func rewriteValue<T>(newValue: T) -> Observable<Result<T, E.FailureType>> {
        return mapValue { _ in newValue }
    }

    open func replaceResultError(with value: E.ValueType) -> Observable<E.ValueType> {
        return asObservable().map { $0.value ?? value }
    }

    open func replaceResultErrorWithNil() -> RxSwift.Observable<Self.E.ValueType?> {
        return asObservable().map { $0.value }
    }

    open func map<T, U: Error>(transformValue: @escaping (E.ValueType) -> T, transformError: @escaping (E.FailureType) -> U) -> Observable<Result<T, U>> {
        return asObservable().map { $0.map(transformValue: transformValue, transformError: transformError) }
    }

    open func emptied() -> Observable<Result<Void, E.FailureType>> {
        return asObservable().map { $0.emptied() }
    }
}
