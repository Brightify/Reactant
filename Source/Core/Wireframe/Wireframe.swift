//
//  Wireframe.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public protocol Wireframe {
}

extension Wireframe {

    /**
     * Method used for flexible and convenient **UIViewController** initializing without the need to pass UINavigationController around.
     * 
     * As well as giving you an easy way to interact with navigation controller through **provider.navigation**, `create(factory:)` also lets you define a *reaction* using the controller without you having to initialize it beforehand. Both approaches are used in the simplified example below.
     *
     * To gain access to this function, your wireframe needs to conform to the `Wireframe` protocol.
     *
     * ## Example
     * From Wireframe:
     * ```
     * private func login() -> LoginController {
     *   return create { provider in
     *     let dependencies = LoginController.Dependencies(accountService: module.accountService)
     *     let reactions = LoginController.Reactions(
     *       promptTouchID: {
     *         provider.controller?.present(self.touchIDPrompt())
     *       },
     *       enterApplication: {
     *         provider.navigation?.replaceAll(with: self.mainScreen())
     *       },
     *       openPasswordRecovery: { email in
     *         provider.navigation?.push(controller: self.passwordRecovery(email: email))
     *       }
     *     )
     *   return LoginController(dependencies: dependencies, reactions: reactions)
     *   }
     * }
     * ```
     *
     * - NOTE: For more info see: [Dependencies and everything about them](TODO), [Reactions, how do they work?](TODO), [Properties for flexible passing of variables to controllers](TODO)
     */
    public func create<T>(factory: (FutureControllerProvider<T>) -> T) -> T {
        let futureControllerProvider = FutureControllerProvider<T>()
        let controller = factory(futureControllerProvider)
        futureControllerProvider.controller = controller
        return controller
    }
    
    /**
     * Used when you need a navigation controller embedded inside a controller that is already inside a navigation controller and is supposed to have a close button.
     */
    public func branchNavigation(controller: UIViewController, closeButtonTitle: String?) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: controller)
        if let closeButtonTitle = closeButtonTitle {
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: closeButtonTitle, style: .done) { [weak navigationController] in
                navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        return navigationController
    }

    /**
     * Used when you need a navigation controller embedded inside a controller that is already inside a navigation controller and is supposed to have a close button.
     */
    public func branchNavigation<S, T>(controller: ControllerBase<S, T>) -> UINavigationController {
        let closeButtonTitle = controller.configuration.get(valueFor: Properties.closeButtonTitle)
        return branchNavigation(controller: controller, closeButtonTitle: closeButtonTitle)
    }
}
#endif
