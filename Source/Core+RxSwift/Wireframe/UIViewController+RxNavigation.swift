//
//  UIViewController+Navigation.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

extension UIViewController {

    /**
     * Presents a view controller and returns `Observable` that indicates when the view has been successfully presented.
     * - parameter controller: generic controller to present
     * - parameter animated: determines whether the view controller presentation should be animated, default is `true`
     */
    @discardableResult
    public func present<C: UIViewController>(controller: C, animated: Bool = true) -> Observable<C> {
        let replay = ReplaySubject<Void>.create(bufferSize: 1)
        present(controller, animated: animated, completion: { replay.onLast() })
        return replay.rewrite(with: controller)
    }

    /**
     * Dismisses topmost view controller and returns `Observable` that indicates when the view has been dismissed.
     * - parameter animated: determines whether the view controller dismissal should be animated, default is `true`
     */
    @discardableResult
    public func dismiss(animated: Bool = true) -> Observable<Void> {
        let replay = ReplaySubject<Void>.create(bufferSize: 1)
        dismiss(animated: animated, completion: { replay.onLast() })
        return replay
    }

    @discardableResult
    public func present<C: UIViewController>(controller: Observable<C>, animated: Bool = true) -> Observable<C> {
        let replay = ReplaySubject<C>.create(bufferSize: 1)
        _ = controller
            .takeUntil(rx.deallocated)
            .flatMapLatest { [weak self] controller in
                self?.present(controller: controller).rewrite(with: controller) ?? .empty()
            }
            .subscribe(
                onNext: { [weak self] controller in
                    guard self != nil else {
                        replay.onCompleted()
                        return
                    }
                    replay.onNext(controller)
                },
                onDisposed: {
                    replay.onCompleted()
            })
        return replay
    }
}
