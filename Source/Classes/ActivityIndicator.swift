//
//  ActivityIndicator.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa

open struct ActivityToken<E> : ObservableConvertibleType, Disposable {
    private let _source: Observable<E>
    private let _dispose: Cancelable

    open init(source: Observable<E>, disposeAction: @escaping () -> ()) {
        _source = source
        _dispose = Disposables.create(with: disposeAction)
    }

    open func dispose() {
        _dispose.dispose()
    }

    open func asObservable() -> Observable<E> {
        return _source
    }
}

/**
 Enables monitoring of sequence computation.

 If there is at least one sequence computation in progress, `true` will be sent.
 When all activities complete `false` will be sent.
 */
open class ActivityIndicator: DriverConvertibleType {
    open let disposeBag = DisposeBag()
    open typealias E = (loading: Bool, message: String)

    private let _lock = NSRecursiveLock()
    private let _variable = Variable(0)
    private let _lastMessage = Variable<String>("")
    private let _loading: Driver<Bool>

    open init() {
        _loading = _variable.asObservable()
            .map { $0 > 0 }
            .distinctUntilChanged()
            .asDriver { (error: Error) -> Driver<Bool> in
                _ = assert(false, "Loader can't fail")
                return Driver.empty()
        }
    }

    open func trackActivity<O: ObservableConvertibleType>(of source: O, message: String) -> Observable<O.E> {
        return Observable.using({ () -> ActivityToken<O.E> in
            self.increment(message: message)
            return ActivityToken(source: source.asObservable(), disposeAction: self.decrement)
        }) { t in
            return t.asObservable()
        }
    }

    private func increment(message: String) {
        _lock.lock()
        _lastMessage.value = message
        _variable.value = _variable.value + 1
        _lock.unlock()
    }

    private func decrement() {
        _lock.lock()
        _variable.value = _variable.value - 1
        _lock.unlock()
    }

    open func asDriver() -> Driver<E> {
        return _loading.withLatestFrom(_lastMessage.asDriver()) { (loading: $0, message: $1) }
    }
}

extension ObservableConvertibleType {
    open func trackActivity(in activityIndicator: ActivityIndicator, message: String? = nil) -> Observable<E> {
        return activityIndicator.trackActivity(of: self,
                                               message: message ?? ReactantConfiguration.global.defaultLoadingMessage)
    }
}
