//
//  Driver.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

public class DriveFactory<T> {
    private let factory: (Drive<T>) -> T

    public init(factory: @escaping (Drive<T>) -> T) {
        self.factory = factory
    }

    public func build(drive: Drive<T>) -> T {
        return factory(drive)
    }
}

public class Drive<T> {
    private var pauseQueue: [Any]? = nil

    internal var listeners: [ObjectIdentifier: (Any) -> Void] = [:]

    public func pause() {
        pauseQueue = []
    }

    public func unpause() {
        guard let pauseQueue = pauseQueue else {
            return
        }

        #warning("FIXME: This might result in events coming out of order if pushing an event results in an event.")
        self.pauseQueue = nil

        for event in pauseQueue {
            forcePush(value: event)
        }
    }

    public func paused<Result>(do work: () throws -> Result) rethrows -> Result {
        pause()
        defer { unpause() }

        return try work()
    }

    private func registerAny<T>(listener: @escaping (T) -> Void) {
        let identifier = ObjectIdentifier(T.self)
        listeners[identifier] = { value in
            guard let castValue = value as? T else { return }
            listener(castValue)
        }
    }

    private func push(value: Any) {
        if pauseQueue != nil {
            pauseQueue?.append(value)
        } else {
            forcePush(value: value)
        }
    }

    private func forcePush(value: Any) {
        for listener in listeners.values {
            listener(value)
        }
    }
}

extension Drive where T: DrivenController {
    internal func register(listener: @escaping (T.PerformedAction) -> Void) {
        registerAny(listener: listener)
    }

    public func perform(action: T.PerformedAction) {
        push(value: action)
    }
}

extension Drive where T: DrivenPresenter {
    internal func register(listener: @escaping (T.Event) -> Void) {
        registerAny(listener: listener)
    }

    public func submit(event: T.Event) {
        push(value: event)
    }
}

extension Drive where T: PerformsNavigation {
    internal func register(listener: @escaping (T.NavigationRoute) -> Void) {
        registerAny(listener: listener)
    }

    public func navigate(to route: T.NavigationRoute) {
        push(value: route)
    }
}
