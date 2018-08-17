//
//  Wireframe+RxSwift.swift
//  RxReactant
//
//  Created by Tadeas Kriz on 8/17/18.
//  Copyright © 2018 Brightify. All rights reserved.
//

import RxSwift

extension Wireframe {
    /**
     * Method used for convenient creating **UIViewController** with Observable containing result value from the controller
     * Usage is very similar to the create<T> method, except now there are two closure parameters in create.
     * - returns: Tuple containg the requested **UIViewController** and Observable with the type of the result.
     */
    public func create<T, U>(factory: (FutureControllerProvider<T>, AnyObserver<U>) -> T) -> (T, Observable<U>) {
        let futureControllerProvider = FutureControllerProvider<T>()
        let subject = PublishSubject<U>()
        let controller = factory(futureControllerProvider, subject.asObserver())
        futureControllerProvider.controller = controller
        return (controller, subject.takeUntil(controller.rx.deallocated))
    }
}
