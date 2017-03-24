//
//  MainWireframe.swift
//  Reactant
//
//  Created by Matous Hybl on 3/24/17.
//  Copyright © 2017 Brightify s.r.o. All rights reserved.
//

import Reactant

class MainWireframe: Wireframe {

    private let dependencyModule: DependencyModule

    init(dependencyModule: DependencyModule) {
        self.dependencyModule = dependencyModule
    }

    func entrypoint() -> UIViewController {
        return UINavigationController(rootViewController: mainController())
    }

    private func mainController() -> UIViewController {
        return create { provider in
            let reactions = MainViewController.Reactions(openTable: {
                provider.navigation?.push(controller: self.tableViewController())
            })

            return MainViewController(reactions: reactions)
        }
    }

    private func tableViewController() -> UIViewController {
        return create { provider in
            let dependencies = TableViewController.Dependencies(nameService: dependencyModule.nameService)
            let reactions = TableViewController.Reactions(displayName: { name in
                provider.navigation?.present(controller: self.nameAlertController(name: name))
            })
            return TableViewController(dependencies: dependencies, reactions: reactions)
        }
    }

    private func nameAlertController(name: String) -> UIViewController {
        let controller = UIAlertController(title: "This is a name", message: name, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { _ in controller.dismiss() }))
        return controller
    }
}
