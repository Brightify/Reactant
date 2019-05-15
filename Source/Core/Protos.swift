//
//  Protos.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

public protocol PerformsNavigation {
    associatedtype NavigationRoute
}

public protocol HandlesActions {
    associatedtype HandledAction

    func handle(action: HandledAction)
}

public protocol ReceivesEvents {
    associatedtype Event

    func receive(event: Event)
}

public protocol SubmitsEvents {
    associatedtype Event
}

public protocol PerformsActions {
    associatedtype PerformedAction
}

public protocol DrivenPresenter: AnyObject, HandlesActions, SubmitsEvents {
    var driver: Drive<Self> { get }
}

public protocol DrivenController: AnyObject, ReceivesEvents, PerformsActions {
    var driver: Drive<Self> { get }
}
