//
//  UINavigationController+RxNavigation.swift
//  RxReactant
//
//  Created by Tadeas Kriz on 8/17/18.
//  Copyright © 2018 Brightify. All rights reserved.
//

import RxSwift

extension UINavigationController {
    public func push<C: UIViewController>(controller: Observable<C>, animated: Bool = true) {
        _ = controller
            .takeUntil(rx.deallocated)
            .subscribe(onNext: { [weak self] controller in
                self?.push(controller: controller, animated: animated)
            })
    }

    @discardableResult
    public func replace<C: UIViewController>(with controller: Observable<C>, animated: Bool = true) -> Observable<UIViewController?> {
        let replacedController = ReplaySubject<UIViewController?>.create(bufferSize: 1)
        _ = controller
            .takeUntil(rx.deallocated)
            .subscribe(
                onNext: { [weak self] controller in
                    guard let s = self else {
                        replacedController.onCompleted()
                        return
                    }
                    replacedController.onNext(s.replace(with: controller, animated: animated))
                },
                onDisposed: {
                    replacedController.onCompleted()
            })
        return replacedController
    }

    @discardableResult
    public func popAllAndReplace<C: UIViewController>(with controller: Observable<C>) -> Observable<[UIViewController]> {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .moveIn
        transition.subtype = .fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(transition, forKey: nil)

        return replaceAll(with: controller, animated: false)
    }

    @discardableResult
    public func replaceAll<C: UIViewController>(with controller: Observable<C>, animated: Bool = true) -> Observable<[UIViewController]> {
        let oldControllers = ReplaySubject<[UIViewController] >.create(bufferSize: 1)
        _ = controller
            .takeUntil(rx.deallocated)
            .subscribe(
                onNext: { [weak self] controller in
                    guard let s = self else {
                        oldControllers.onCompleted()
                        return
                    }
                    oldControllers.onNext(s.replaceAll(with: controller, animated: animated))
                },
                onDisposed: {
                    oldControllers.onCompleted()
            })

        return oldControllers
    }
}
