//
//  ActionPublisher.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

public class ActionPublisher<Action> {
    private var listeners: [(Action) -> Void] = []

    public init(publisher: @escaping (Action) -> Void) {
        listeners.append(publisher)
    }

    public init() { }

    public func publish(action: Action) {
        for listener in listeners {
            listener(action)
        }
    }

    public func publisher<Value>(_ mapping: @escaping (Value) -> Action) -> (Value) -> Void {
        return { value in
            self.publish(action: mapping(value))
        }
    }

    public func publisher(_ value: Action) -> () -> Void {
        return {
            self.publish(action: value)
        }
    }

    public func map<InnerAction>(_ mapping: @escaping (InnerAction) -> Action?) -> ActionPublisher<InnerAction> {
        return ActionPublisher<InnerAction>(publisher: { innerAction in
            guard let action = mapping(innerAction) else {
                // Ignored action
                return
            }
            self.publish(action: action)
        })
    }

    public func listen(with listener: @escaping (Action) -> Void) {
        listeners.append(listener)
    }

    public class var noop: ActionPublisher {
        return ActionPublisher(publisher: { _ in /* log action ignored */ })
    }
}
