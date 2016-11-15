//
//  Wireframe.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

public class Wireframe {
}

extension Wireframe {
    
    public func create<T>(factory: (FutureControllerProvider<T>) -> T) -> T {
        let futureControllerProvider = FutureControllerProvider<T>()
        let controller = factory(futureControllerProvider)
        futureControllerProvider.controller = controller
        return controller
    }
    
    public func brancheNavigation(controller: UIViewController,
                                          closeButtonTitle: String? = ReactantConfiguration.global.closeButtonTitle) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: controller)
        if let closeButtonTitle = closeButtonTitle {
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: closeButtonTitle, style: .done) { _ in
                navigationController.dismiss(animated: true, completion: nil)
            }
        }
        return navigationController
    }
}
