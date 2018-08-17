//
//  Component+RxSwift.swift
//  RxReactant
//
//  Created by Tadeas Kriz on 8/17/18.
//  Copyright © 2018 Brightify. All rights reserved.
//

import Foundation

import RxSwift

private var lifetimeDisposeBagKey = 0 as UInt8
private var stateDisposeBagKey = 0 as UInt8
private extension Component {
    var lifetimeDisposeBag: DisposeBag {
        return associatedObject(self, key: &lifetimeDisposeBagKey) {
            DisposeBag()
        }
    }

    var stateDisposeBag: DisposeBag {
        return associatedObject(self, key: &stateDisposeBagKey, policy: .assign) {
            let disposeBag = DisposeBag()
            let token = ObservationToken {
                withExtendedLifetime(disposeBag) { }
            }
            stateTracking.track(token: token)
            return disposeBag
        }
    }
}

extension Reactive where Base: Component {
    /**
     * This `DisposeBag` gets disposed at `Component`'s **deinit** and should be used
     * to dispose subscriptions outside of `update()`.
     *
     * **Usage**:
     * ```
     * // inside afterInit()
     *
     * friendService.defaultFriends
     *   .subscribe(onNext: { friends in
     *     componentState = friends
     *   }
     *   .disposed(by: lifetimeDisposeBag)
     * ```
     *
     * - WARNING: It's strongly discouraged to use this `DisposeBag` in the `update()` method.
     * Use the `stateDisposeBag` for that.
     */
    public var lifetimeDisposeBag: DisposeBag {
        return base.lifetimeDisposeBag
    }

    /**
     * This `DisposeBag` gets disposed after every `update()` call and should be used
     * to dispose subscriptions inside `update()`.
     *
     * **Usage**:
     * ```
     * // inside update()
     *
     * friendService.newFriends
     *   .subscribe(onNext: { friends in
     *     rootView.componentState = .items(friends)
     *   }
     *   .disposed(by: stateDisposeBag)
     * ```
     *
     * - WARNING: It's strongly discouraged to use this `DisposeBag` anywhere else than in the `update()` method.
     * Use the `lifetimeDisposeBag` for that.
     */
    public var stateDisposeBag: DisposeBag {
        return base.stateDisposeBag
    }

    /**
     * `Observable` equivalent of the `componentState`.
     *
     * Should only be used for its value in `Observable` work, not for subscribing. For getting a `componentState` observable to subscribe to see `observeState(_:)`.
     * - NOTE: For more info, see [RxSwift](https://github.com/ReactiveX/RxSwift).
     * - WARNING: Do not use this in `update()` to avoid duplicite loading bugs.
     */
    public var state: Observable<Base.StateType> {
        return Observable.create { [weak base] observer in
            let token = base?.observeState(.afterUpdate) { action in
                observer.onNext(action)
            }

            return Disposables.create {
                token?.stopObserving()
            }
            }.takeUntil(deallocated)
    }

    /**
     * The `Observable` into which all Component's actions and `perform(action:)` calls are merged.
     * - NOTE: When listening to Component's actions, using `action` is strongly recommended instead of `actions`.
     *  This is because `ComponentBase.actions` contains only `Observable`s, so any `perform(action:)` will be ignored.
     */
    public var action: Observable<Base.ActionType> {
        return Observable.create { [weak base] observer in
            let token = base?.observeAction { action in
                observer.onNext(action)
            }

            return Disposables.create {
                token?.stopObserving()
            }
        }.takeUntil(deallocated)
    }

    /**
     * Recommended way of getting an `Observable` to subscribe to.
     * If you wish to get an `Observable` to use in `actions` or do other `Observable` work, see `observableState`.
     */
    func observeState(_ when: ObservableStateEvent) -> Observable<Base.StateType> {
        return Observable.create { [weak base] observer in
            let token = base?.observeState(when) { action in
                observer.onNext(action)
            }

            return Disposables.create {
                token?.stopObserving()
            }
            }.takeUntil(deallocated)
    }
}
