//
//  StatefulComponent.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 12/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

open class StatefulComponent<Change, State, Action>: Component<Change, Action>, Stateful {
    private var stateStorage: State

    /**
     State of this component. Don't edit this from outside of the class, instead submit a change to this component.
     */
    public var state: State {
        get {
            return stateStorage
        }
        set {
            assert(composableDelegate.isApplyingChange, "Changing state from outside of `apply(change:)` is forbidden!")

            let oldValue = stateStorage
            stateStorage = newValue

            update(previousState: oldValue)
        }
    }

    public init(initialState: State) {
        stateStorage = initialState

        super.init()

        update(previousState: nil)
    }

    open func update(previousState: State?) { }

    public func set(state: State) {
        self.state = state
    }
}
