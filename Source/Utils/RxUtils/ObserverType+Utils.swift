//
//  ObserverType+Utils.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

public extension ObserverType {
    
    /**
     * Convenience method equivalent to `on(.Next(element: E))` and `on(.Completed)`
     * - parameter element: Next element to send to observer(s)
     */
    func onLast(_ element: Element) {
        on(.next(element))
        on(.completed)
    }
}

public extension ObserverType where Element == Void {
    func onLast() {
        onLast(())
    }
}
