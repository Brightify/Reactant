//
//  ActionPublisher.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation


public class ActionPublisher<Action> {
    private let publisher: (Action) -> Void

    public init(publisher: @escaping (Action) -> Void) {
        self.publisher = publisher
    }

    public func publish(action: Action) {
        publisher(action)
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

    public func map<InnerAction>(_ mapping: @escaping (InnerAction) -> Action) -> ActionPublisher<InnerAction> {
        return ActionPublisher<InnerAction>(publisher: { innerAction in
            self.publish(action: mapping(innerAction))
        })
    }

    public class var noop: ActionPublisher {
        return ActionPublisher(publisher: { _ in /* log action ignored */ })
    }
}
