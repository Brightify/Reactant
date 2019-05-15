//
//  ActionMapper.swift
//  Reactant
//
//  Created by Tadeas Kriz on 18/08/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public final class ActionMapper<ACTION> {
    private let performAction: (ACTION) -> Void
    internal var tokens: [ObservationToken] = []

    public init(performAction: @escaping (ACTION) -> Void) {
        self.performAction = performAction
    }

    public func map<C: Composable>(from component: C, using mapping: @escaping (C.Action) -> ACTION) {
        let token = component.observeAction { [performAction] action in
            performAction(mapping(action))
        }

        track(token: token)
    }

    public func passthrough<C: Composable>(from component: C) where C.Action == ACTION {
        let token = component.observeAction { [performAction] action in
            performAction(action)
        }

        track(token: token)
    }

    #if os(iOS)
    public func map(control: Platform.Control, to action: @autoclosure @escaping () -> ACTION) {
        map(control: control, for: .touchUpInside, to: action())
    }
    #elseif os(tvOS)
    public func map(control: Platform.Control, to action: @autoclosure @escaping () -> ACTION) {
        map(control: control, for: .primaryActionTriggered, to: action)
    }
    #elseif os(macOS)
    public func map(control: Platform.Control, to action: @autoclosure @escaping () -> ACTION) {

    }
    #endif

    internal func track(token: ObservationToken) {
        tokens.append(token)
    }
}

// MARK: UIControl mapping
#if canImport(UIKit)
extension ActionMapper {
    private class ControlActionDelegate {
        private weak var control: UIControl?
        private let event: UIControl.Event
        private let performAction: () -> Void

        init(for control: UIControl,
             event: UIControl.Event,
             performAction: @escaping () -> Void) {
            self.control = control
            self.event = event
            self.performAction = performAction

            control.addTarget(self, action: #selector(actionPerformed), for: event)
        }

        @objc
        func actionPerformed() {
            performAction()
        }

        func stopDelegating() {
            control?.removeTarget(self, action: #selector(actionPerformed), for: event)
        }

        deinit {
            stopDelegating()
        }
    }

    public func map(control: UIControl, for event: UIControl.Event, to action: @autoclosure @escaping () -> ACTION) {
        let delegate = ControlActionDelegate(for: control, event: event) { [performAction] in
            performAction(action())
        }

        let token = ObservationToken(onStop: {
            delegate.stopDelegating()
        })

        track(token: token)
    }
}
#endif
