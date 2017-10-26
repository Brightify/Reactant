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
    public func onLast(_ element: E) {
        on(.next(element))
        on(.completed)
    }
}

public extension ObserverType where E == Void {
    public func onLast() {
        onLast(())
    }
}
