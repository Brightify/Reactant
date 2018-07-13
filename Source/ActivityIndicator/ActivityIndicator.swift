//
//  ActivityIndicator.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift
import RxCocoa

public final class ActivityIndicator<T>: ObservableConvertibleType {
    
    public typealias E = (loading: Bool, associatedValue: T?)
    
    public let disposeBag = DisposeBag()
    
    private let behaviorRelay: BehaviorRelay<[(id: UUID, associatedValue: T?)]> = BehaviorRelay(value: [])
    private let driver: Driver<E>
    private let equalFunction: (T?, T?) -> Bool
    fileprivate let defaultAssociatedValue: T?
    
    public init(defaultAssociatedValue: T? = nil, equalWhen equalFunction: @escaping (T, T) -> Bool) {
        self.defaultAssociatedValue = defaultAssociatedValue
        self.equalFunction = { lhs, rhs in
            if let lhs = lhs, let rhs = rhs {
                return equalFunction(lhs, rhs)
            } else {
                return lhs == nil && rhs == nil
            }
        }
        
        // `self` cannot be captured before all fields are initialized.
        let equal = self.equalFunction
        driver = behaviorRelay.asDriver()
            .map { (loading: !$0.isEmpty, associatedValue: $0.compactMap { $0.associatedValue }.first) }
            .distinctUntilChanged { lhs, rhs in lhs.loading == rhs.loading && equal(lhs.associatedValue, rhs.associatedValue) }
    }
    
    public func trackActivity<O: ObservableConvertibleType>(of source: O, initialAssociatedValue: T?,
                              associatedValueProvider: @escaping (O.E) -> T?) -> Observable<O.E> {
        // `self` is intentionally captured. It is released once the Observable is disposed.
        return Observable.create { subscriber in
            let observable = source.asObservable().share(replay: 1, scope: .forever)
            let subscriptionDisposable = observable.subscribe(subscriber)
            
            let id = UUID()
            
            let messageChangeDisposable = observable.map(associatedValueProvider)
                .startWith(initialAssociatedValue)
                .distinctUntilChanged(self.equalFunction)
                .subscribe(onNext: { associatedValue in
                    if let index = self.behaviorRelay.value.index(where: { $0.id == id }) {
                        self.behaviorRelay.mutate(using: {
                            $0[index].associatedValue = associatedValue
                        })
                    } else {
                        self.behaviorRelay.mutate(using: {
                            $0.append((id: id, associatedValue: associatedValue))
                        })
                    }
                })
            
            return Disposables.create {
                subscriptionDisposable.dispose()
                messageChangeDisposable.dispose()
                
                if let index = self.behaviorRelay.value.index(where: { $0.id == id }) {
                    self.behaviorRelay.mutate(using: {
                        $0.remove(at: index)
                    })
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

extension ActivityIndicator where T: Equatable {
    
    public convenience init(defaultAssociatedValue: T? = nil) {
        self.init(defaultAssociatedValue: defaultAssociatedValue, equalWhen: ==)
    }
}

extension ActivityIndicator {
    
    public func trackActivity<O: ObservableConvertibleType>(of source: O) -> Observable<O.E> {
        return trackActivity(of: source, associatedValue: defaultAssociatedValue)
    }
    
    public func trackActivity<O: ObservableConvertibleType>(of source: O, associatedValue: T?)
        -> Observable<O.E> {
        return trackActivity(of: source, initialAssociatedValue: associatedValue,
                             associatedValueProvider: { _ in associatedValue })
    }
    
    public func trackActivity<O: ObservableConvertibleType>(of source: O, associatedValueProvider: @escaping (O.E) -> T?)
        -> Observable<O.E> {
        return trackActivity(of: source, initialAssociatedValue: defaultAssociatedValue,
                             associatedValueProvider: associatedValueProvider)
    }
}

extension ObservableConvertibleType {
    
    public func trackActivity<T>(in activityIndicator: ActivityIndicator<T>) -> Observable<E> {
        return activityIndicator.trackActivity(of: self, associatedValue: activityIndicator.defaultAssociatedValue)
    }
    
    public func trackActivity<T>(in activityIndicator: ActivityIndicator<T>, associatedValue: T?) -> Observable<E> {
        return activityIndicator.trackActivity(of: self, associatedValue: associatedValue)
    }
    
    public func trackActivity<T>(in activityIndicator: ActivityIndicator<T>, associatedValueProvider: @escaping (E) -> T?)
        -> Observable<E> {
        return activityIndicator.trackActivity(of: self, initialAssociatedValue: activityIndicator.defaultAssociatedValue,
                                               associatedValueProvider: associatedValueProvider)
    }
    
    public func trackActivity<T>(in activityIndicator: ActivityIndicator<T>, initialAssociatedValue: T?,
                              associatedValueProvider: @escaping (E) -> T?) -> Observable<E> {
        return activityIndicator.trackActivity(of: self, initialAssociatedValue: initialAssociatedValue,
                                               associatedValueProvider: associatedValueProvider)
    }
}


