//
//  ActivityIndicator.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift
import RxCocoa

public final class ActivityIndicator: ObservableConvertibleType {
    
    public typealias E = (loading: Bool, message: String?)
    
    public let disposeBag = DisposeBag()
    
    private let variable: Variable<[(id: UUID, message: String?)]> = Variable([])
    
    private let driver: Driver<E>
    
    public init() {
        driver = variable.asDriver()
            .map { (loading: !$0.isEmpty, message: $0.flatMap { $0.message }.first) }
            .distinctUntilChanged { lhs, rhs in lhs.loading == rhs.loading && lhs.message == rhs.message }
    }
    
    public func trackActivity<O: ObservableConvertibleType>(of source: O, message: String? = nil) -> Observable<O.E> {
        return trackActivity(of: source, initialMessage: message, messageProvider: { _ in message })
    }
    
    public func trackActivity<O: ObservableConvertibleType>(of source: O, initialMessage: String? = nil, messageProvider: @escaping (O.E) -> String?) -> Observable<O.E> {
        return Observable.create { [variable] subscriber in
            let observable = source.asObservable().shareReplay(1)
            let subscriptionDisposable = observable.subscribe(subscriber)
            
            let id = UUID()
            
            let messageChangeDisposable = observable.map(messageProvider)
                .startWith(initialMessage)
                .distinctUntilChanged()
                .subscribe(onNext: {
                    if let index = variable.value.index(where: { $0.id == id }) {
                        variable.value[index].message = $0
                    } else {
                        variable.value.append((id: id, message: $0))
                    }
                })
            
            return Disposables.create {
                subscriptionDisposable.dispose()
                messageChangeDisposable.dispose()
                
                if let index = variable.value.index(where: { $0.id == id }) {
                    variable.value.remove(at: index)
                }
            }
        }
    }
    
    public func asObservable() -> Observable<E> {
        return driver.asObservable()
    }
    
    public func asDriver() -> Driver<E> {
        return driver
    }
}

extension ObservableConvertibleType {
    
    public func trackActivity(in activityIndicator: ActivityIndicator, message: String? = nil) -> Observable<E> {
        return activityIndicator.trackActivity(of: self, message: message)
    }
    
    public func trackActivity(in activityIndicator: ActivityIndicator, initialMessage: String? = nil, messageProvider: @escaping (E) -> String?) -> Observable<E> {
        return activityIndicator.trackActivity(of: self, initialMessage: initialMessage, messageProvider: messageProvider)
    }
}
