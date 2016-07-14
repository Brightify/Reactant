//
//  Result+Utils.swift
//
//  Created by Tadeas Kriz on 19/03/16.
//

import RxSwift
import RxCocoa
import RxOptional
import Alamofire

public protocol ResultType {
    associatedtype ValueType
    associatedtype FailureType: ErrorType

    var isSuccess: Bool { get }

    var isFailure: Bool { get }

    var value: ValueType? { get }

    var error: FailureType? { get }

    func mapValue<T>(transform: ValueType -> T) -> Result<T, FailureType>

    func mapError<T: ErrorType>(transform: FailureType -> T) -> Result<ValueType, T>

    func map<T, U: ErrorType>(transformValue transformValue: ValueType -> T, transformError: FailureType -> U) -> Result<T, U>

    func emptied() -> Result<Void, FailureType>
}

extension Result: ResultType {
    public typealias ValueType = Value
    public typealias FailureType = Error

    public func mapValue<T>(transform: Value -> T) -> Result<T, Error> {
        switch self {
        case .Success(let value):
            return .Success(transform(value))
        case .Failure(let error):
            return .Failure(error)
        }
    }

    public func mapError<T: ErrorType>(transform: Error -> T) -> Result<Value, T> {
        switch self {
        case .Success(let value):
            return .Success(value)
        case .Failure(let error):
            return .Failure(transform(error))
        }
    }

    public func map<T, U: ErrorType>(transformValue transformValue: Value -> T, transformError: Error -> U) -> Result<T, U> {
        return mapValue(transformValue).mapError(transformError)
    }

    public func emptied() -> Result<Void, Error> {
        return mapValue { _ in }
    }
}

public extension ObservableConvertibleType where E: ResultType {

    public func filterError() -> Observable<E.ValueType> {
        return asObservable().map { $0.value }.filterNil()
    }

    public func errorOnly() -> Observable<E.FailureType> {
        return asObservable().map { $0.error }.filterNil()
    }

    public func mapValue<T>(transform: E.ValueType -> T) -> Observable<Result<T, E.FailureType>> {
        return asObservable().map { $0.mapValue(transform) }
    }

    public func mapError<T: ErrorType>(transform: E.FailureType -> T) -> Observable<Result<E.ValueType, T>> {
        return asObservable().map { $0.mapError(transform) }
    }

    public func rewriteValue<T>(newValue: T) -> Observable<Result<T, E.FailureType>> {
        return mapValue { _ in newValue }
    }

    public func replaceResultErrorWith(value: E.ValueType) -> Observable<E.ValueType> {
        return asObservable().map { $0.value ?? value }
    }

    public func map<T, U: ErrorType>(transformValue transformValue: E.ValueType -> T, transformError: E.FailureType -> U) -> Observable<Result<T, U>> {
        return asObservable().map { $0.map(transformValue: transformValue, transformError: transformError) }
    }

    public func emptied() -> Observable<Result<Void, E.FailureType>> {
        return asObservable().map { $0.emptied() }
    }
}
