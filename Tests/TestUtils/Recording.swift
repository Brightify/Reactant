//
//  Recording.swift
//  ReactantTests
//
//  Created by Tadeas Kriz on 18/08/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import Reactant

typealias Recordable<Element> = (@escaping (Element) -> Void) -> ObservationToken

func record<Element>(_ observe: Recordable<Element>, do work: () throws -> Void) rethrows -> [Element] {
    var elements = [] as [Element]
    let token = observe {
        elements.append($0)
    }
    defer { token.stopObserving() }

    try work()
    return elements
}
