//
//  ActionMapper.swift
//  Reactant
//
//  Created by Tadeas Kriz on 18/08/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

public final class ActionMapper<ACTION> {
    private let performAction: (ACTION) -> Void
    internal var tokens: [ObservationToken] = []

    public init(performAction: @escaping (ACTION) -> Void) {
        self.performAction = performAction
    }

    public func map<C: Component>(from component: C, using mapping: @escaping (C.ActionType) -> ACTION) {
        let token = component.observeAction { [performAction] action in
            performAction(mapping(action))
        }

        track(token: token)
    }

    public func passthrough<C: Component>(from component: C) where C.ActionType == ACTION {
        let token = component.observeAction { [performAction] action in
            performAction(action)
        }

        track(token: token)
    }

    internal func track(token: ObservationToken) {
        tokens.append(token)
    }
}
