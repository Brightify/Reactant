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
