//
//  Navigator.swift
//
//  Created by Tadeas Kriz on 20/03/16.
//

import UIKit
import RxSwift

public struct Navigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func present<C: UIViewController>(controller: C, animated: Bool = true) -> Observable<C> {
        let replay = ReplaySubject<Void>.create(bufferSize: 1)
        navigationController.presentViewController(controller, animated: animated, completion: { replay.onLast() })
        return replay.rewrite(controller)
    }

    public func dismiss(animated animated: Bool = true) -> Observable<Void> {
        let replay = ReplaySubject<Void>.create(bufferSize: 1)
        navigationController.dismissViewControllerAnimated(animated, completion: { replay.onLast() })
        return replay
    }

    public func push(controller: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(controller, animated: animated)
    }

    public func pop(animated animated: Bool = true) -> UIViewController? {
        return navigationController.popViewControllerAnimated(animated)
    }

    public func replace(with controller: UIViewController, animated: Bool = true) -> UIViewController? {
        var controllers = navigationController.viewControllers ?? []
        let current = controllers.popLast()
        controllers.append(controller)

        navigationController.setViewControllers(controllers, animated: animated)

        return current
    }

    public func popAllAndReplace(with controller: UIViewController) -> [UIViewController] {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        navigationController.view.layer.addAnimation(transition, forKey: nil)

        let replaced = replaceAll(with: controller, animated: false)

        return replaced
    }

    public func replaceAll(with controller: UIViewController, animated: Bool = true) -> [UIViewController] {
        let currentControllers = navigationController.viewControllers

        navigationController.setViewControllers([controller], animated: animated)
        
        return currentControllers
    }

    public static func branchedNavigation(controller: UIViewController,
                                          closeButtonTitle: String? = "Close") -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: controller)
        if let closeButtonTitle = closeButtonTitle {
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: closeButtonTitle, style: .Done) { _ in
                navigationController.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        return navigationController
    }
}
