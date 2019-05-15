//
//  PlainStatefulComponent.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 12/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

open class PlainStatefulComponent<State, Action>: StatefulComponent<PlainStatefulComponent.StateChange, State, Action> {
    public enum StateChange {
        case invalidate
        case set(State)
        case update(updates: [StateUpdate])

        public struct StateUpdate {
            let keyPath: PartialKeyPath<State>
            private let _perform: (inout State) -> Void

            public init<Value>(keyPath: WritableKeyPath<State, Value>, value: Value) {
                _perform = { state in
                    state[keyPath: keyPath] = value
                }

                self.keyPath = keyPath
            }

            func perform(on state: inout State) {
                _perform(&state)
            }
        }
    }

    open override func apply(change: PlainStatefulComponent<State, Action>.StateChange) {
        super.apply(change: change)

        switch change {
        case .invalidate:
            break
        case .set(let newState):
            state = newState
        case .update(let updates):
            var mutableState = state
            updates.forEach {
                $0.perform(on: &mutableState)
            }
            state = mutableState
        }
    }
}
