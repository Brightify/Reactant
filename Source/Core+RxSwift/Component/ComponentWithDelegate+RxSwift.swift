//
//  ComponentWithDelegate+RxSwift.swift
//  RxReactant
//
//  Created by Tadeas Kriz on 8/17/18.
//  Copyright © 2018 Brightify. All rights reserved.
//

import RxSwift

extension ComponentWithDelegate {

    public var action: Observable<ActionType> {
        return componentDelegate.rxBehavior.action
    }

    public var stateDisposeBag: DisposeBag {
        return componentDelegate.rxBehavior.stateDisposeBag
    }

    public var observableState: Observable<StateType> {
        return componentDelegate.rxBehavior.observableState
    }

    public func observeState(_ when: ObservableStateEvent) -> Observable<StateType> {
        return componentDelegate.rxBehavior.observeState(when)
    }
}
