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
    fileprivate let defaultMessage: String?
    
    public init(defaultMessage: String? = nil) {
        self.defaultMessage = defaultMessage
        
        driver = variable.asDriver()
            .map { (loading: !$0.isEmpty, message: $0.flatMap { $0.message }.first) }
            .distinctUntilChanged { lhs, rhs in lhs.loading == rhs.loading && lhs.message == rhs.message }
    }
    
    public func trackActivity<O: ObservableConvertibleType>(of source: O, initialMessage: String?, messageProvider: @escaping (O.E) -> String?) -> Observable<O.E> {
        // self is intentionaly captured. It is released once the Observable is disposed.
        return Observable.create { subscriber in
            let observable = source.asObservable().shareReplay(1)
            let subscriptionDisposable = observable.subscribe(subscriber)
            
            let id = UUID()
            
            let messageChangeDisposable = observable.map(messageProvider)
                .startWith(initialMessage)
                .distinctUntilChanged()
                .subscribe(onNext: {
                    if let index = self.variable.value.index(where: { $0.id == id }) {
                        self.variable.value[index].message = $0
                    } else {
                        self.variable.value.append((id: id, message: $0))
                    }
                })
            
            return Disposables.create {
                subscriptionDisposable.dispose()
                messageChangeDisposable.dispose()
                
                if let index = self.variable.value.index(where: { $0.id == id }) {
                    self.variable.value.remove(at: index)
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

extension ActivityIndicator {
    
    public func trackActivity<O: ObservableConvertibleType>(of source: O) -> Observable<O.E> {
        return trackActivity(of: source, message: defaultMessage)
    }
    
    public func trackActivity<O: ObservableConvertibleType>(of source: O, message: String?) -> Observable<O.E> {
        return trackActivity(of: source, initialMessage: message, messageProvider: { _ in message })
    }
    
    public func trackActivity<O: ObservableConvertibleType>(of source: O, messageProvider: @escaping (O.E) -> String?) -> Observable<O.E> {
        return trackActivity(of: source, initialMessage: defaultMessage, messageProvider: messageProvider)
    }
}

extension ObservableConvertibleType {
    
    public func trackActivity(in activityIndicator: ActivityIndicator) -> Observable<E> {
        return activityIndicator.trackActivity(of: self, message: activityIndicator.defaultMessage)
    }
    
    public func trackActivity(in activityIndicator: ActivityIndicator, message: String?) -> Observable<E> {
        return activityIndicator.trackActivity(of: self, message: message)
    }
    
    public func trackActivity(in activityIndicator: ActivityIndicator, messageProvider: @escaping (E) -> String?) -> Observable<E> {
        return activityIndicator.trackActivity(of: self, initialMessage: activityIndicator.defaultMessage, messageProvider: messageProvider)
    }
    
    public func trackActivity(in activityIndicator: ActivityIndicator, initialMessage: String?, messageProvider: @escaping (E) -> String?) -> Observable<E> {
        return activityIndicator.trackActivity(of: self, initialMessage: initialMessage, messageProvider: messageProvider)
    }
}


