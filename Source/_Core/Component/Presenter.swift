//
//  Presenter.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 12/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

//open class Presenter<ProvidedChange, HandledAction>: Presenting {
//
//    public init() {
//
//    }
//
//    public final func observeChanges(observer: @escaping (Presenter.ProvidedChange) -> Void) -> ObservationToken {
//
//        fatalError()
//    }
//
//    open func handle(action: HandledAction) { }
//}
//
//public func present<C: Composable, P: Presenting>(component: C, with presenter: P) -> ObservationToken
//    where C.Change == P.ProvidedChange, C.Action == P.HandledAction
//{
//    return present(component: component, with: presenter, transformingChanges: { $0 }, transformingActions: { $0 })
//}
//
//public func present<C: Composable, P: Presenting>(
//    component: C,
//    with presenter: P,
//    transformingChanges: @escaping (P.ProvidedChange) -> C.Change) -> ObservationToken
//    where C.Action == P.HandledAction
//{
//    return present(component: component, with: presenter, transformingChanges: transformingChanges, transformingActions: { $0 })
//}
//
//public func present<C: Composable, P: Presenting>(
//    component: C,
//    with presenter: P,
//    transformingActions: @escaping (C.Action) -> P.HandledAction) -> ObservationToken
//    where C.Change == P.ProvidedChange
//{
//    return present(component: component, with: presenter, transformingChanges: { $0 }, transformingActions: transformingActions)
//}
//
//public func present<C: Composable, P: Presenting>(
//    component: C,
//    with presenter: P,
//    transformingChanges: @escaping (P.ProvidedChange) -> C.Change,
//    transformingActions: @escaping (C.Action) -> P.HandledAction) -> ObservationToken
//{
//    let inputToken = presenter.observeChanges { change in
//        component.submit(change:  transformingChanges(change))
//    }
//    let outputToken = component.observeAction { action in
//        presenter.handle(action: transformingActions(action))
//    }
//
//    return ObservationToken(tokens: inputToken, outputToken)
//}
