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
    
    public typealias E = (loading: Bool, message: String?)
    
    public let disposeBag = DisposeBag()
    
    private let variable: Variable<[(id: UUID, message: String)]> = Variable([])
    
    private let driver: Driver<E>
    
    public init() {
        driver = variable.asDriver().map { (loading: !$0.isEmpty, message: $0.first?.message) }
    }
    
    public func trackActivity<O: ObservableConvertibleType>(of source: O, message: String) -> Observable<O.E> {
        // No reference cycle.
        return Observable.create { subscriber in
            let disposable = source.asObservable().subscribe(subscriber)
            
            let id = UUID()
            self.variable.value.append((id: id, message: message))
            
            return Disposables.create {
                if let index = self.variable.value.index(where: { $0.id == id }) {
                    self.variable.value.remove(at: index)
                }
                
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
