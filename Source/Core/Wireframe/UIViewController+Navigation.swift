//
//  UIViewController+Navigation.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

#if os(iOS)
extension ViewController {
    
    @discardableResult
    public func present<C: ViewController>(controller: C, animated: Bool = true) -> Observable<C> {
        let replay = ReplaySubject<Void>.create(bufferSize: 1)
        present(controller, animated: animated, completion: { replay.onLast() })
        return replay.rewrite(with: controller)
    }
    
    @discardableResult
    public func dismiss(animated: Bool = true) -> Observable<Void> {
        let replay = ReplaySubject<Void>.create(bufferSize: 1)
        dismiss(animated: animated, completion: { replay.onLast() })
        return replay
    }
}
#endif
