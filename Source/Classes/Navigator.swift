//
//  Navigator.swift
//
//  Created by Tadeas Kriz on 20/03/16.
//

import UIKit
import RxSwift

open struct Navigator {
    private let navigationController: UINavigationController

    open init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    open func present<C: UIViewController>(controller: C, animated: Bool = true) -> Observable<C> {
        let replay = ReplaySubject<Void>.create(bufferSize: 1)
        navigationController.present(controller, animated: animated, completion: { replay.onLast() })
        return replay.rewrite(with: controller)
    }

    open func dismiss(animated: Bool = true) -> Observable<Void> {
        let replay = ReplaySubject<Void>.create(bufferSize: 1)
        navigationController.dismiss(animated: animated, completion: { replay.onLast() })
        return replay
    }

    open func push(controller: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(controller, animated: animated)
    }

    open func pop(animated: Bool = true) -> UIViewController? {
        return navigationController.popViewController(animated: animated)
    }

    open func replace(with controller: UIViewController, animated: Bool = true) -> UIViewController? {
        var controllers = navigationController.viewControllers
        let current = controllers.popLast()
        controllers.append(controller)

        navigationController.setViewControllers(controllers, animated: animated)

        return current
    }

    open func popAllAndReplace(with controller: UIViewController) -> [UIViewController] {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        navigationController.view.layer.add(transition, forKey: nil)

        let replaced = replaceAll(with: controller, animated: false)

        return replaced
    }

    open func replaceAll(with controller: UIViewController, animated: Bool = true) -> [UIViewController] {
        let currentControllers = navigationController.viewControllers

        navigationController.setViewControllers([controller], animated: animated)
        
        return currentControllers
    }

    open static func branchedNavigation(controller: UIViewController,
                                          closeButtonTitle: String? = "Close") -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: controller)
        if let closeButtonTitle = closeButtonTitle {
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: closeButtonTitle, style: .done, target: navigationController, action: #selector(UINavigationController.dismiss(animated:completion:))) // { _ in
//                navigationController.dismissViewControllerAnimated(true, completion: nil)
//            }
        }
        return navigationController
    }
}
