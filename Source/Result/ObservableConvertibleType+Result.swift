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
    
    public func filterError() -> Observable<E.Value> {
        return asObservable().map { $0.value }.filterNil()
    }
    
    public func errorOnly() -> Observable<E.Error> {
        return asObservable().map { $0.error }.filterNil()
    }
    
    public func mapValue<T>(_ transform: @escaping (E.Value) -> T) -> Observable<Result<T, E.Error>> {
        return asObservable().map { $0.map(transform) }
    }
    
    public func mapError<T: Error>(_ transform: @escaping (E.Error) -> T) -> Observable<Result<E.Value, T>> {
        return asObservable().map { $0.mapError(transform) }
    }

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

    public func rewriteValue<T>(newValue: T) -> Observable<Result<T, E.Error>> {
        return mapValue { _ in newValue }
    }
    
    public func recover(_ value: E.Value) -> Observable<E.Value> {
        return asObservable().map { $0.value ?? value }
    }
    
    public func recoverWithNil() -> Observable<Self.E.Value?> {
        return asObservable().map { $0.value }
    }
}
