//
//  Wireframe.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit
#endif

public protocol Wireframe {
}

extension Wireframe {

    public func create<T>(factory: (FutureControllerProvider<T>) -> T) -> T {
        let futureControllerProvider = FutureControllerProvider<T>()
        let controller = factory(futureControllerProvider)
        futureControllerProvider.controller = controller
        return controller
    }

    #if os(iOS)
    public func branchNavigation(controller: UIViewController, closeButtonTitle: String?) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: controller)
        if let closeButtonTitle = closeButtonTitle {
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: closeButtonTitle, style: .done) { _ in
                navigationController.dismiss(animated: true, completion: nil)
            }
        }
        return navigationController
    }

    public func branchNavigation<S, T>(controller: ControllerBase<S, T>) -> UINavigationController {
        let closeButtonTitle = controller.configuration.get(valueFor: Properties.closeButtonTitle)
        return branchNavigation(controller: controller, closeButtonTitle: closeButtonTitle)
    }
    #endif
}
