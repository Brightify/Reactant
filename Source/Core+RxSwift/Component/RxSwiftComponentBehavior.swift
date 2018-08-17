//
//  RxSwiftComponentBehavior.swift
//  RxReactant
//
//  Created by Tadeas Kriz on 8/17/18.
//  Copyright © 2018 Brightify. All rights reserved.
//

import RxSwift

internal final class RxSwiftComponentBehavior<STATE, ACTION>: ComponentBehavior {
    public var stateDisposeBag = DisposeBag()

    public var observableState: Observable<STATE> {
        return observableStateSubject
    }

    public var action: Observable<ACTION> {
        return actionSubject
    }

    public var actions: [Observable<ACTION>] = [] {
        didSet {
            actionsDisposeBag = DisposeBag()
            Observable.from(actions).merge().subscribe(onNext: { [weak self] in
                self?.componentPerformedAction($0)
            }).disposed(by: actionsDisposeBag)
        }
    }

    private let observableStateSubject = ReplaySubject<STATE>.create(bufferSize: 1)
    private let observableStateBeforeUpdate = PublishSubject<STATE>()
    private let observableStateAfterUpdate = PublishSubject<STATE>()
    private let actionSubject = PublishSubject<ACTION>()

    private var actionsDisposeBag = DisposeBag()

    func componentStateWillChange(from previousState: STATE?, to state: STATE) {
        observableStateBeforeUpdate.onNext(state)
        observableStateSubject.onNext(state)
    }

    func componentStateDidChange(from previousState: STATE?, to state: STATE) {
        observableStateAfterUpdate.onNext(state)
    }

    func componentPerformedAction(_ action: ACTION) {
        actionSubject.onNext(action)
    }

    func observeState(_ when: ObservableStateEvent) -> Observable<STATE> {
        switch when {
        case .beforeUpdate:
            return observableStateBeforeUpdate
        case .afterUpdate:
            return observableStateAfterUpdate
        }
    }

    deinit {
        observableStateSubject.onCompleted()
        actionSubject.onCompleted()
        observableStateBeforeUpdate.onCompleted()
        observableStateAfterUpdate.onCompleted()
    }

}
