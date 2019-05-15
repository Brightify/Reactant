//
//  Driven.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import UIKit

public class ActionSource<Action> {
    private var observers: [(Action) -> Void] = []

    public init() { }

    public func perform(action: Action) {
        for observer in observers {
            observer(action)
        }
    }

    internal func observe(with observer: @escaping (Action) -> Void) {
        observers.append(observer)
    }
}

extension DrivenPresenter {
    public func present<C: DrivenController>(controller: C) -> C where C.Event == Event, C.PerformedAction == HandledAction {
        driver.register(listener: { [weak controller] in
            controller?.receive(event: $0)
        })
        controller.driver.register(listener: handle(action:))

        driver.unpause()
        controller.driver.unpause()

        return controller
    }

    public func present<C: DrivenController & PerformsNavigation>(controller: C, navigate: @escaping (C.NavigationRoute) -> Void) -> C where C.Event == Event, C.PerformedAction == HandledAction {
        driver.register(listener: { [weak controller] in
            controller?.receive(event: $0)
        })
        controller.driver.register(listener: handle(action:))
        controller.driver.register(listener: navigate)

        driver.unpause()
        controller.driver.unpause()

        return controller
    }

    public func embed(actionSource: ActionSource<HandledAction>, receivingEvents: @escaping (Event) -> Void) {
        fatalError()
    }
}

extension DrivenController {

}

public class DrivenNavigatingController<C: DrivenController & PerformsNavigation> {
    let driver: Drive<C>
    let controller: C

    init(driver: Drive<C>, controller: C) {
        self.driver = driver
        self.controller = controller
    }
}
