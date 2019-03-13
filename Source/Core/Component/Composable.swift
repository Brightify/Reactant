//
//  Composable.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 12/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

public protocol Changeable: AnyObject {
    associatedtype Change

    func submit(change: Change)
}

public protocol ProvidesActions: AnyObject {
    associatedtype Action

    func observeAction(observer: @escaping (Action) -> Void) -> ObservationToken
}

public protocol Stateful: AnyObject {
    associatedtype State

    func set(state: State)
}

public protocol Composable: Changeable, ProvidesActions {
}

public protocol StatefulComposable: Composable, Stateful {

}


