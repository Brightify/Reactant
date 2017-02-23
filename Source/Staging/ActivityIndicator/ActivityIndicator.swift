//
//  ActivityIndicator.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift
import RxCocoa

/**
 Enables monitoring of sequence computation.
 
 If there is at least one sequence computation in progress, `true` will be sent.
 When all activities complete `false` will be sent.
 */
public final class ActivityIndicator: ObservableConvertibleType {
    
    public typealias E = (loading: Bool, message: String)
    
    public let disposeBag = DisposeBag()
    
    private let lastMessage = Variable("")
    private let variable = Variable(0)
    
    private let driver: Driver<E>
    
    public init() {
        driver = variable.asDriver()
            .map { $0 > 0 }
            .distinctUntilChanged()
            .withLatestFrom(lastMessage.asDriver()) { (loading: $0, message: $1) }
    }
    
    public func trackActivity<O: ObservableConvertibleType>(of source: O, message: String) -> Observable<O.E> {
        // No reference cycle.
        return Observable.create { subscriber in
            self.lastMessage.value = message
            self.variable.value += 1
            let disposable = source.asObservable().subscribe(subscriber)
            
            return Disposables.create {
                self.variable.value -= 1
                disposable.dispose()
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
    
    public func trackActivity(in activityIndicator: ActivityIndicator, message: String) -> Observable<E> {
        return activityIndicator.trackActivity(of: self, message: message)
    }
}
